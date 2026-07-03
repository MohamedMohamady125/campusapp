import 'package:test/test.dart';
import 'package:campus_api/campus_api.dart';


/// tests for UsersApi
void main() {
  final instance = CampusApi().getUsersApi();

  group(UsersApi, () {
    // Get Me
    //
    //Future<UserMeResponse> getMeApiV1UsersMeGet() async
    test('test getMeApiV1UsersMeGet', () async {
      // TODO
    });

    // Get Public Profile
    //
    //Future<UserPublicResponse> getPublicProfileApiV1UsersUserIdGet(String userId) async
    test('test getPublicProfileApiV1UsersUserIdGet', () async {
      // TODO
    });

    // Update Me
    //
    //Future<UserMeResponse> updateMeApiV1UsersMePatch(UserUpdateRequest userUpdateRequest) async
    test('test updateMeApiV1UsersMePatch', () async {
      // TODO
    });

  });
}
