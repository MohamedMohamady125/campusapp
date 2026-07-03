import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/core/theme/app_theme.dart';
import 'package:campusconnect/features/messaging/data/conversations_repository.dart';
import 'package:campusconnect/features/tutoring/data/tutoring_repository.dart';
import 'package:campusconnect/shared/widgets/empty_state.dart';
import 'package:campusconnect/shared/widgets/motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final AutoDisposeFutureProviderFamily<List<CourseResponse>, String>
courseSuggestionsProvider = FutureProvider.autoDispose
    .family<List<CourseResponse>, String>(
      (ref, q) => ref.watch(tutoringRepositoryProvider).autocompleteCourses(q),
    );

final AutoDisposeFutureProviderFamily<List<RankedTutorResponse>, String>
rankedTutorsProvider = FutureProvider.autoDispose
    .family<List<RankedTutorResponse>, String>(
      (ref, code) => ref.watch(tutoringRepositoryProvider).rankedTutors(code),
    );

/// Tutor search (J2, spec §6.4): course combobox → ranked tutor cards →
/// "Message" reuses M5 messaging.
class TutorSearchScreen extends ConsumerStatefulWidget {
  const TutorSearchScreen({super.key});

  @override
  ConsumerState<TutorSearchScreen> createState() => _TutorSearchScreenState();
}

class _TutorSearchScreenState extends ConsumerState<TutorSearchScreen> {
  final _search = TextEditingController();
  String _query = '';
  CourseResponse? _selected;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _messageTutor(RankedTutorResponse ranked) async {
    try {
      final convo = await ref
          .read(conversationsRepositoryProvider)
          .openConversation(
            recipientId: ranked.tutor.id,
            contextType: ConversationContext.tutoring,
            contextId: ranked.offering.id,
          );
      if (mounted) {
        context.go(
          '/chats/conversation/${convo.id}',
          extra: ranked.tutor.displayName,
        );
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find a tutor')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: TextField(
              controller: _search,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Course code, e.g. CS250',
                suffixIcon: _selected == null
                    ? null
                    : IconButton(
                        tooltip: 'Clear course',
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() {
                          _selected = null;
                          _query = '';
                          _search.clear();
                        }),
                      ),
              ),
              onChanged: (q) => setState(() {
                _query = q.trim();
                _selected = null;
              }),
            ),
          ),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    final selected = _selected;
    if (selected != null) {
      return _RankedTutors(course: selected, onMessage: _messageTutor);
    }
    if (_query.length < 2) {
      return const EmptyState(
        icon: Icons.school_outlined,
        title: 'Search by course code',
        message: 'Type a course like CS250 to see ranked peer tutors.',
      );
    }
    final suggestions = ref.watch(courseSuggestionsProvider(_query));
    return suggestions.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const EmptyState(
        icon: Icons.cloud_off,
        title: 'Could not search courses',
        message: 'Check your connection and try again.',
      ),
      data: (courses) => courses.isEmpty
          ? const EmptyState(
              icon: Icons.school_outlined,
              title: 'No matching courses',
              message: 'Try the department prefix, e.g. CS or MATH.',
            )
          : ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, i) {
                final course = courses[i];
                return ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: Text(course.code),
                  subtitle: Text(course.title),
                  onTap: () => setState(() {
                    _selected = course;
                    _search.text = course.code;
                  }),
                );
              },
            ),
    );
  }
}

class _RankedTutors extends ConsumerWidget {
  const _RankedTutors({required this.course, required this.onMessage});

  final CourseResponse course;
  final Future<void> Function(RankedTutorResponse) onMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutors = ref.watch(rankedTutorsProvider(course.code));
    return tutors.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => EmptyState(
        icon: Icons.cloud_off,
        title: 'Could not load tutors',
        message: 'Check your connection and try again.',
        actionLabel: 'Retry',
        onAction: () => ref.invalidate(rankedTutorsProvider(course.code)),
      ),
      data: (items) => items.isEmpty
          ? EmptyState(
              icon: Icons.school_outlined,
              title: 'No tutors for ${course.code} yet',
              message:
                  'Took it and did well? Offer to tutor from your profile.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: items.length,
              itemBuilder: (context, i) => FadeSlideIn(
                index: i,
                child: _TutorCard(
                  ranked: items[i],
                  rank: i + 1,
                  onMessage: onMessage,
                ),
              ),
            ),
    );
  }
}

class _TutorCard extends StatelessWidget {
  const _TutorCard({
    required this.ranked,
    required this.rank,
    required this.onMessage,
  });

  final RankedTutorResponse ranked;
  final int rank;
  final Future<void> Function(RankedTutorResponse) onMessage;

  @override
  Widget build(BuildContext context) {
    final tutor = ranked.tutor;
    final offering = ranked.offering;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Rank-forward: badge over avatar (design brief §patterns).
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      backgroundColor: scheme.primaryContainer,
                      foregroundColor: scheme.onPrimaryContainer,
                      child: Text(
                        tutor.displayName.isEmpty
                            ? '?'
                            : tutor.displayName[0].toUpperCase(),
                      ),
                    ),
                    Positioned(
                      right: -4,
                      top: -4,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: scheme.surface, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: Text(
                            '$rank',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: scheme.onPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tutor.displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '${tutor.reputationScore.toStringAsFixed(1)}'
                            ' (${tutor.ratingCount})',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    '${offering.gradeReceived} · ${offering.termTaken}',
                  ),
                ),
              ],
            ),
            if (offering.blurb?.isNotEmpty ?? false) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                offering.blurb!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: () => onMessage(ranked).ignore(),
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: Text('Message ${tutor.displayName.split(' ').first}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
