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
      (ref, q) => ref
          .watch(tutoringRepositoryProvider)
          .autocompleteCourses(q),
    );

final AutoDisposeFutureProviderFamily<
  List<RankedTutorResponse>,
  String
>
rankedTutorsProvider = FutureProvider.autoDispose
    .family<List<RankedTutorResponse>, String>(
      (ref, code) => ref
          .watch(tutoringRepositoryProvider)
          .rankedTutors(code),
    );

/// Tutor search (J2, spec §6.4): course combobox →
/// ranked tutor cards → "Message" reuses M5 messaging.
class TutorSearchScreen extends ConsumerStatefulWidget {
  const TutorSearchScreen({super.key});

  @override
  ConsumerState<TutorSearchScreen> createState() =>
      _TutorSearchScreenState();
}

class _TutorSearchScreenState
    extends ConsumerState<TutorSearchScreen> {
  final _search = TextEditingController();
  String _query = '';
  CourseResponse? _selected;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _messageTutor(
    RankedTutorResponse ranked,
  ) async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Tutor'),
      ),
      body: Column(
        children: [
          // -- Search field --
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: _search,
              textCapitalization:
                  TextCapitalization.characters,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: scheme.onSurfaceVariant,
                ),
                hintText: 'Search by course code, e.g. CS250',
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
      return _RankedTutors(
        course: selected,
        onMessage: _messageTutor,
      );
    }
    if (_query.length < 2) {
      return _InitialHint();
    }
    final suggestions =
        ref.watch(courseSuggestionsProvider(_query));
    return suggestions.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (_, _) => const EmptyState(
        icon: Icons.cloud_off,
        title: 'Could not search courses',
        message: 'Check your connection and try again.',
      ),
      data: (courses) => courses.isEmpty
          ? const EmptyState(
              icon: Icons.school_outlined,
              title: 'No matching courses',
              message:
                  'Try the department prefix, e.g. CS or MATH.',
            )
          : _CourseSuggestionsList(
              courses: courses,
              onSelect: (course) => setState(() {
                _selected = course;
                _search.text = course.code;
              }),
            ),
    );
  }
}

// -- Initial hint illustration --

class _InitialHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_rounded,
                size: 44,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Find peer tutors',
              style: text.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Type a course code like CS250 to see '
              'ranked tutors who aced it.',
              style: text.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// -- Course suggestion list --

class _CourseSuggestionsList extends StatelessWidget {
  const _CourseSuggestionsList({
    required this.courses,
    required this.onSelect,
  });

  final List<CourseResponse> courses;
  final ValueChanged<CourseResponse> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      itemCount: courses.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final course = courses[i];
        return FadeSlideIn(
          index: i,
          child: PressableScale(
            onTap: () => onSelect(course),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(
                  AppRadius.lg,
                ),
                border: Border.all(
                  color: scheme.outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(
                        AppRadius.md,
                      ),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 20,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.code,
                          style: text.titleSmall,
                        ),
                        const SizedBox(
                          height: AppSpacing.xs,
                        ),
                        Text(
                          course.title,
                          style: text.bodySmall?.copyWith(
                            color:
                                scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// -- Ranked tutors list --

class _RankedTutors extends ConsumerWidget {
  const _RankedTutors({
    required this.course,
    required this.onMessage,
  });

  final CourseResponse course;
  final Future<void> Function(RankedTutorResponse) onMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutors =
        ref.watch(rankedTutorsProvider(course.code));
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return tutors.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (_, _) => EmptyState(
        icon: Icons.cloud_off,
        title: 'Could not load tutors',
        message: 'Check your connection and try again.',
        actionLabel: 'Retry',
        onAction: () => ref.invalidate(
          rankedTutorsProvider(course.code),
        ),
      ),
      data: (items) => items.isEmpty
          ? EmptyState(
              icon: Icons.school_outlined,
              title: 'No tutors for ${course.code} yet',
              message:
                  'Took it and did well? Offer to tutor '
                  'from your profile.',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              itemCount: items.length + 1,
              itemBuilder: (context, i) {
                // Header showing course + count.
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color:
                                scheme.primaryContainer,
                            borderRadius:
                                BorderRadius.circular(
                              AppRadius.pill,
                            ),
                          ),
                          child: Text(
                            course.code,
                            style:
                                text.labelLarge?.copyWith(
                              color: scheme
                                  .onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: AppSpacing.sm,
                        ),
                        Text(
                          '${items.length} '
                          'tutor${items.length == 1 ? '' : 's'}',
                          style: text.bodySmall?.copyWith(
                            color:
                                scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return FadeSlideIn(
                  index: i - 1,
                  child: _TutorCard(
                    ranked: items[i - 1],
                    rank: i,
                    onMessage: onMessage,
                  ),
                );
              },
            ),
    );
  }
}

// -- Professional tutor card --

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
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: PressableScale(
        onTap: () => onMessage(ranked).ignore(),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius:
                BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: scheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: avatar + info + grade chip
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // Rank-badged avatar
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            scheme.primaryContainer,
                        foregroundColor:
                            scheme.onPrimaryContainer,
                        child: Text(
                          tutor.displayName.isEmpty
                              ? '?'
                              : tutor.displayName[0]
                                  .toUpperCase(),
                          style: text.titleMedium
                              ?.copyWith(
                            color:
                                scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: scheme
                                  .surfaceContainerLow,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$rank',
                            style: text.labelSmall
                                ?.copyWith(
                              color: scheme.onPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Name + reputation
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          tutor.displayName,
                          style: text.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                          height: AppSpacing.xs,
                        ),
                        // Stars + rating
                        Row(
                          children: [
                            ..._buildStars(
                              tutor.reputationScore
                                  .toDouble(),
                              scheme,
                            ),
                            const SizedBox(
                              width: AppSpacing.xs,
                            ),
                            Text(
                              tutor.reputationScore
                                  .toStringAsFixed(1),
                              style:
                                  text.labelMedium
                                      ?.copyWith(
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                            const SizedBox(
                              width: AppSpacing.xs,
                            ),
                            Text(
                              '(${tutor.ratingCount})',
                              style:
                                  text.bodySmall?.copyWith(
                                color: scheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Grade + term chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs + 2,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(
                        AppRadius.pill,
                      ),
                    ),
                    child: Text(
                      offering.gradeReceived,
                      style: text.labelMedium?.copyWith(
                        color:
                            scheme.onSecondaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              // Term taken
              Padding(
                padding: const EdgeInsets.only(
                  left: 60, // aligns with name column
                  top: AppSpacing.xs,
                ),
                child: Text(
                  'Took it ${offering.termTaken}',
                  style: text.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),

              // Blurb
              if (offering.blurb?.isNotEmpty ?? false) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  offering.blurb!,
                  style: text.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              // Message button
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () =>
                      onMessage(ranked).ignore(),
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 18,
                  ),
                  label: Text(
                    'Message '
                    '${tutor.displayName.split(' ').first}',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStars(
    double score,
    ColorScheme scheme,
  ) {
    const starColor = Color(0xFFF59E0B);
    final fullStars = score.floor();
    final hasHalf = (score - fullStars) >= 0.5;
    return List.generate(5, (i) {
      if (i < fullStars) {
        return const Icon(
          Icons.star_rounded,
          size: 16,
          color: starColor,
        );
      }
      if (i == fullStars && hasHalf) {
        return const Icon(
          Icons.star_half_rounded,
          size: 16,
          color: starColor,
        );
      }
      return Icon(
        Icons.star_outline_rounded,
        size: 16,
        color: scheme.outlineVariant,
      );
    });
  }
}
