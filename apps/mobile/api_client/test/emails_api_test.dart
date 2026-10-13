import 'package:test/test.dart';
import 'package:campus_api/campus_api.dart';


/// tests for EmailsApi
void main() {
  final instance = CampusApi().getEmailsApi();

  group(EmailsApi, () {
    // Unsubscribe
    //
    //Future<String> unsubscribeApiV1EmailsUnsubscribeGet(String token) async
    test('test unsubscribeApiV1EmailsUnsubscribeGet', () async {
      // TODO
    });

  });
}
