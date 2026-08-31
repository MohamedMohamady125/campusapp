import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';
import 'package:campusconnect/features/messaging/data/conversations_repository.dart';
import 'package:campusconnect/features/tutoring/data/tutoring_repository.dart';
import 'package:campusconnect/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_auth.dart';
import 'helpers/fake_conversations.dart';
import 'helpers/fake_flags.dart';

CourseResponse _course() => CourseResponse(
  (b) => b
    ..id = 'crs-1'
    ..code = 'CS250'
    ..title = 'Data Structures'
    ..department = 'CS',
);

RankedTutorResponse _ranked(String name, double score) => RankedTutorResponse(
  (b) => b
    ..score = score
    ..reputationNorm = score
    ..recencyNorm = 0.5
    ..responsivenessNorm = 0.5
    ..tutor.replace(
      UserPublicResponse(
        (u) => u
          ..id = 'u-$name'
          ..displayName = name
          ..ratingCount = 20
          ..reputationScore = 4.8
          ..createdAt = DateTime.utc(2026),
      ),
    )
    ..offering.replace(
      OfferingResponse(
        (o) => o
          ..id = 'off-$name'
          ..tutorId = 'u-$name'
          ..gradeReceived = 'A'
          ..termTaken = 'Fall 2025'
          ..blurb = 'Happy to help with trees and graphs.'
          ..active = true
          ..createdAt = DateTime.utc(2026)
          ..course.replace(_course()),
      ),
    ),
);

class _FakeTutoringRepository implements TutoringRepository {
  String? lastCourseQuery;
  String? lastRankedCourse;

  @override
  Future<List<CourseResponse>> autocompleteCourses(String query) async {
    lastCourseQuery = query;
    return [_course()];
  }

  @override
  Future<List<RankedTutorResponse>> rankedTutors(String courseCode) async {
    lastRankedCourse = courseCode;
    return [_ranked('Amr Tutor', 0.9), _ranked('Bella Tutor', 0.7)];
  }
}

void main() {
  late _FakeTutoringRepository tutoring;
  late FakeConversationsRepository conversations;

  Widget app() {
    tutoring = _FakeTutoringRepository();
    conversations = FakeConversationsRepository();
    return ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(
          () => FakeAuthController(authedState()),
        ),
        tutoringRepositoryProvider.overrideWithValue(tutoring),
        conversationsRepositoryProvider.overrideWithValue(conversations),
        ...shellOverrides(),
      ],
      child: const CampusConnectApp(),
    );
  }

  Future<void> openTutors(WidgetTester tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tutors'));
    await tester.pumpAndSettle();
  }

  testWidgets('J2: course search shows ranked tutors', (tester) async {
    await openTutors(tester);

    await tester.enterText(find.byType(TextField), 'CS2');
    await tester.pumpAndSettle();
    expect(tutoring.lastCourseQuery, 'CS2');
    expect(find.text('Data Structures'), findsOneWidget);

    await tester.tap(find.text('CS250'));
    await tester.pumpAndSettle();

    expect(tutoring.lastRankedCourse, 'CS250');
    expect(find.text('Amr Tutor'), findsOneWidget);
    expect(find.text('Bella Tutor'), findsOneWidget);
    // ReputationChip renders value and count separately (spec §4.2).
    expect(find.text('4.8'), findsNWidgets(2));
    expect(find.text(' · 20'), findsNWidgets(2));
    expect(find.text('CS250 · A · Fall 2025'), findsNWidgets(2));
  });

  testWidgets('J2: message tutor opens a conversation thread', (
    tester,
  ) async {
    await openTutors(tester);
    await tester.enterText(find.byType(TextField), 'CS250');
    await tester.pumpAndSettle();
    await tester.tap(find.text('CS250').last);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Message').first);
    await tester.pumpAndSettle();

    // Landed on the thread screen for the created conversation.
    expect(find.text('Amr Tutor'), findsOneWidget); // app bar title
    expect(find.byTooltip('Send'), findsOneWidget);
  });

  testWidgets('short query keeps the guidance empty state', (tester) async {
    await openTutors(tester);
    await tester.enterText(find.byType(TextField), 'C');
    await tester.pumpAndSettle();
    expect(find.textContaining('Type a course code'), findsOneWidget);
    expect(tutoring.lastCourseQuery, isNull);
  });

  testWidgets('ranked tutors meets a11y tap-target guidelines', (
    tester,
  ) async {
    await openTutors(tester);
    await tester.enterText(find.byType(TextField), 'CS250');
    await tester.pumpAndSettle();
    await tester.tap(find.text('CS250').last);
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  });
}
