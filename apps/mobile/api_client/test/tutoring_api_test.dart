import 'package:test/test.dart';
import 'package:campus_api/campus_api.dart';


/// tests for TutoringApi
void main() {
  final instance = CampusApi().getTutoringApi();

  group(TutoringApi, () {
    // Autocomplete Courses
    //
    //Future<BuiltList<CourseResponse>> autocompleteCoursesApiV1CoursesGet(String q) async
    test('test autocompleteCoursesApiV1CoursesGet', () async {
      // TODO
    });

    // Cancel Tutor Premium
    //
    //Future<SubscriptionResponse> cancelTutorPremiumApiV1TutoringPremiumSubscriptionDelete() async
    test('test cancelTutorPremiumApiV1TutoringPremiumSubscriptionDelete', () async {
      // TODO
    });

    // Create Offering
    //
    //Future<OfferingResponse> createOfferingApiV1TutoringOfferingsPost(OfferingCreateRequest offeringCreateRequest) async
    test('test createOfferingApiV1TutoringOfferingsPost', () async {
      // TODO
    });

    // Delete Offering
    //
    //Future deleteOfferingApiV1TutoringOfferingsOfferingIdDelete(String offeringId) async
    test('test deleteOfferingApiV1TutoringOfferingsOfferingIdDelete', () async {
      // TODO
    });

    // Ranked Tutors
    //
    //Future<TutorSearchResponse> rankedTutorsApiV1TutoringTutorsGet(String course) async
    test('test rankedTutorsApiV1TutoringTutorsGet', () async {
      // TODO
    });

    // Subscribe Tutor Premium
    //
    // Tutor premium rail (spec §13.2) — 403 FEATURE_DISABLED while the flag is off.
    //
    //Future<SubscriptionResponse> subscribeTutorPremiumApiV1TutoringPremiumSubscriptionPost() async
    test('test subscribeTutorPremiumApiV1TutoringPremiumSubscriptionPost', () async {
      // TODO
    });

  });
}
