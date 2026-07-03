import 'package:test/test.dart';
import 'package:campus_api/campus_api.dart';


/// tests for RatingsApi
void main() {
  final instance = CampusApi().getRatingsApi();

  group(RatingsApi, () {
    // Create Rating
    //
    //Future<RatingResponse> createRatingApiV1RatingsPost(RatingCreateRequest ratingCreateRequest) async
    test('test createRatingApiV1RatingsPost', () async {
      // TODO
    });

    // List User Ratings
    //
    //Future<RatingPageResponse> listUserRatingsApiV1UsersUserIdRatingsGet(String userId, { String cursor, int limit }) async
    test('test listUserRatingsApiV1UsersUserIdRatingsGet', () async {
      // TODO
    });

  });
}
