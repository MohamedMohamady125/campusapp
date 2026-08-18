import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/error/api_error.dart';
import 'package:campusconnect/design_system/components/course_code_chip.dart';
import 'package:campusconnect/design_system/components/empty_state.dart';
import 'package:campusconnect/design_system/components/fade_slide_in.dart';
import 'package:campusconnect/design_system/components/pressable.dart';
import 'package:campusconnect/design_system/components/skeletons/skeletons.dart';
import 'package:campusconnect/design_system/components/tutor_card.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:campusconnect/features/messaging/data/conversations_repository.dart';
import 'package:campusconnect/features/notifications/presentation/notification_bell.dart';
import 'package:campusconnect/features/tutoring/data/tutoring_repository.dart';
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

/// Tutor search (spec §12.5–12.6): course-code search → confirmed course →
/// ranked tutor cards with rank reasons and the ranking explainer (P5).
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
    final tokens = context.tokens;
    final colors = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a tutor'),
        actions: const [NotificationBell()],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.space4,
              tokens.space3,
              tokens.space4,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _search,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Course code (e.g. CS250)',
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
                SizedBox(height: tokens.space2),
                // Ambient trust line (spec §4.1).
                Text(
                  'Everyone here is a verified student.',
                  style: context.text.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: tokens.space2),
              ],
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
    if (_query.length < 2) return const _InitialHint();
    final suggestions = ref.watch(courseSuggestionsProvider(_query));
    return suggestions.when(
      loading: () => ListView(
        children: const [ListRowSkeleton(), ListRowSkeleton()],
      ),
      error: (_, _) => EmptyState(
        icon: Icons.cloud_off,
        title: "Couldn't search courses",
        body: 'Check your connection and try again.',
        actionLabel: 'Retry',
        onAction: () => ref.invalidate(courseSuggestionsProvider(_query)),
      ),
      data: (courses) => courses.isEmpty
          ? const EmptyState(
              icon: Icons.school_outlined,
              title: "We don't know that course code",
              body: 'Check the code, or try the department prefix.',
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

class _InitialHint extends StatelessWidget {
  const _InitialHint();

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.school_outlined,
      title: 'Find a tutor',
      body:
          'Type a course code like CS250 to see ranked '
          'tutors who took it and did well.',
    );
  }
}

class _CourseSuggestionsList extends StatelessWidget {
  const _CourseSuggestionsList({
    required this.courses,
    required this.onSelect,
  });

  final List<CourseResponse> courses;
  final ValueChanged<CourseResponse> onSelect;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space4,
        vertical: tokens.space2,
      ),
      itemCount: courses.length,
      separatorBuilder: (_, _) => SizedBox(height: tokens.space2),
      itemBuilder: (context, i) {
        final course = courses[i];
        return Pressable(
          onTap: () => onSelect(course),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(tokens.space3),
              child: Row(
                children: [
                  CourseCodeChip(code: course.code),
                  SizedBox(width: tokens.space3),
                  Expanded(
                    child: Text(
                      course.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyMedium,
                    ),
                  ),
                  Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RankedTutors extends ConsumerWidget {
  const _RankedTutors({required this.course, required this.onMessage});

  final CourseResponse course;
  final Future<void> Function(RankedTutorResponse) onMessage;

  /// Ranking explainer sheet (spec §4.4) — the algorithm, in plain language.
  static Future<void> _showRankingSheet(BuildContext context) {
    final tokens = context.tokens;
    return showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          tokens.space4,
          0,
          tokens.space4,
          tokens.space6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How we rank tutors', style: context.text.titleMedium),
            SizedBox(height: tokens.space3),
            Text(
              'We rank by three things: their overall reputation on '
              'CampusConnect (the biggest factor), how recently they took '
              'the course, and how quickly they usually reply. New tutors '
              "start with a neutral score, so they aren't buried — they "
              "just haven't proven anything yet.",
              style: context.text.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  /// Plain-language rank reason (spec §4.4) — never raw percentages.
  static String _rankReason(RankedTutorResponse ranked, String courseCode) {
    final offering = ranked.offering;
    if (ranked.tutor.ratingCount >= 5) {
      return 'Top-rated for $courseCode';
    }
    return 'Took $courseCode ${offering.termTaken} · '
        '${offering.gradeReceived}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutors = ref.watch(rankedTutorsProvider(course.code));
    final tokens = context.tokens;
    final colors = context.colors;
    return tutors.when(
      loading: () => ListView(
        children: const [
          ListRowSkeleton(height: 120),
          ListRowSkeleton(height: 120),
          ListRowSkeleton(height: 120),
        ],
      ),
      error: (_, _) => EmptyState(
        icon: Icons.cloud_off,
        title: "Couldn't load tutors",
        body: 'Check your connection and try again.',
        actionLabel: 'Retry',
        onAction: () => ref.invalidate(rankedTutorsProvider(course.code)),
      ),
      data: (items) => items.isEmpty
          ? EmptyState(
              icon: Icons.school_outlined,
              title: 'No tutors for ${course.code} yet',
              body: 'Took this course? You could tutor it.',
              actionLabel: 'Offer to tutor',
              onAction: () => context.go('/profile'),
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.space4,
                vertical: tokens.space3,
              ),
              itemCount: items.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: tokens.space3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${course.code} · ${course.title}',
                          style: context.text.titleSmall,
                        ),
                        SizedBox(height: tokens.space1),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${items.length} '
                                'tutor${items.length == 1 ? '' : 's'} '
                                'on campus',
                                style: context.text.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                            // Persistent, not dismissible (spec §12.6).
                            TextButton(
                              onPressed: () => _showRankingSheet(context),
                              child: const Text('How are tutors ranked?'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                final ranked = items[i - 1];
                final tutor = ranked.tutor;
                final offering = ranked.offering;
                return FadeSlideIn(
                  index: i - 1,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: tokens.space3),
                    child: TutorCard(
                      name: tutor.displayName,
                      courseSignal:
                          '${course.code} · '
                          '${offering.gradeReceived} · ${offering.termTaken}',
                      rankReason: _rankReason(ranked, course.code),
                      rating: tutor.ratingCount > 0
                          ? tutor.reputationScore.toDouble()
                          : null,
                      ratingCount: tutor.ratingCount,
                      onTap: () => onMessage(ranked).ignore(),
                      onMessage: () => onMessage(ranked).ignore(),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
