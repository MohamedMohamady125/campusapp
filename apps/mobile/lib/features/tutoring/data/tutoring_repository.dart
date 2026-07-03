import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/network/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tutoring reads via the generated client (spec §4.1 tutoring).
class TutoringRepository {
  TutoringRepository(this._api);

  final CampusApi _api;

  TutoringApi get _tutoring => _api.getTutoringApi();

  Future<List<CourseResponse>> autocompleteCourses(String query) async {
    final res = await _tutoring.autocompleteCoursesApiV1CoursesGet(q: query);
    return res.data!.toList();
  }

  /// Ranked tutors for a course code (§5.1 server-side scoring).
  Future<List<RankedTutorResponse>> rankedTutors(String courseCode) async {
    final res = await _tutoring.rankedTutorsApiV1TutoringTutorsGet(
      course: courseCode,
    );
    return res.data!.items.toList();
  }
}

final tutoringRepositoryProvider = Provider<TutoringRepository>(
  (ref) => TutoringRepository(ref.watch(campusApiProvider)),
);
