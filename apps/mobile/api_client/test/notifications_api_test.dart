import 'package:test/test.dart';
import 'package:campus_api/campus_api.dart';


/// tests for NotificationsApi
void main() {
  final instance = CampusApi().getNotificationsApi();

  group(NotificationsApi, () {
    // List Notifications
    //
    //Future<NotificationPageResponse> listNotificationsApiV1NotificationsGet({ String cursor, int limit }) async
    test('test listNotificationsApiV1NotificationsGet', () async {
      // TODO
    });

    // Mark Notifications Read
    //
    //Future markNotificationsReadApiV1NotificationsReadPost(NotificationsReadRequest notificationsReadRequest) async
    test('test markNotificationsReadApiV1NotificationsReadPost', () async {
      // TODO
    });

    // Update Preferences
    //
    //Future<BuiltList<NotificationPreferenceItem>> updatePreferencesApiV1NotificationsPreferencesPatch(NotificationPreferencesUpdateRequest notificationPreferencesUpdateRequest) async
    test('test updatePreferencesApiV1NotificationsPreferencesPatch', () async {
      // TODO
    });

  });
}
