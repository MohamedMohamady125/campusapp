import 'package:built_value/json_object.dart';
import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/features/notifications/presentation/notification_presenter.dart';
import 'package:flutter_test/flutter_test.dart';

NotificationResponse _notif(String type, Map<String, Object?> payload) =>
    NotificationResponse(
      (b) => b
        ..id = 'n-1'
        ..type = type
        ..createdAt = DateTime.utc(2026)
        ..payload.replace({
          for (final entry in payload.entries)
            entry.key: switch (entry.value) {
              null => null,
              final v => JsonObject(v),
            },
        }),
    );

void main() {
  group('run notification titles', () {
    test('run_request names the requester and the spot', () {
      final n = _notif('run_request', {
        'run_id': 'r-1',
        'requester_name': 'Maya',
        'spot_name': 'Chick-fil-A',
      });
      expect(notificationTitle(n), 'Maya wants in on your Chick-fil-A run');
    });

    test('run_request falls back gracefully without names', () {
      final n = _notif('run_request', {'run_id': 'r-1'});
      expect(notificationTitle(n), 'New order request');
    });

    test('run_request_accepted celebrates', () {
      final n = _notif('run_request_accepted', {
        'run_id': 'r-1',
        'spot_name': 'Chick-fil-A',
      });
      expect(
        notificationTitle(n),
        "You're in! Your Chick-fil-A order was accepted",
      );
    });

    test('run_request_declined is gentle', () {
      final n = _notif('run_request_declined', {
        'run_id': 'r-1',
        'spot_name': 'Chick-fil-A',
      });
      expect(
        notificationTitle(n),
        "The runner couldn't take your Chick-fil-A order",
      );
    });

    test('run_status maps each status to friendly copy', () {
      expect(
        notificationTitle(
          _notif('run_status', {
            'run_id': 'r-1',
            'run_status': 'at_store',
            'spot_name': 'Chick-fil-A',
          }),
        ),
        'Your runner is at Chick-fil-A',
      );
      expect(
        notificationTitle(
          _notif('run_status', {'run_id': 'r-1', 'run_status': 'delivering'}),
        ),
        'Your order is on its way',
      );
      expect(
        notificationTitle(
          _notif('run_status', {
            'run_id': 'r-1',
            'run_status': 'cancelled',
            'spot_name': 'Chick-fil-A',
          }),
        ),
        'The Chick-fil-A run was cancelled',
      );
    });

    test('run_completed prompts the rating', () {
      final n = _notif('run_completed', {'run_id': 'r-1'});
      expect(notificationTitle(n), 'Run complete — rate your runner');
    });

    test('run_order_withdrawn names the requester and spot', () {
      final n = _notif('run_order_withdrawn', {
        'run_id': 'r-1',
        'requester_name': 'Maya',
        'spot_name': 'Chick-fil-A',
      });
      expect(notificationTitle(n), 'Maya withdrew their Chick-fil-A order');
      expect(
        notificationTitle(_notif('run_order_withdrawn', {'run_id': 'r-1'})),
        'An order was withdrawn',
      );
    });

    test('run_settle_reminder is loud with exact dollars', () {
      final n = _notif('run_settle_reminder', {
        'run_id': 'r-1',
        'runner_name': 'Ben',
        'owed_cents': '1350',
      });
      expect(notificationTitle(n), r'Settle up — you still owe Ben $13.50');
      expect(
        notificationTitle(
          _notif('run_settle_reminder', {
            'run_id': 'r-1',
            'runner_name': 'Ben',
            'owed_cents': '400',
          }),
        ),
        r'Settle up — you still owe Ben $4',
      );
    });

    test('rating_received names the rater and stars', () {
      final n = _notif('rating_received', {
        'rating_id': 'rt-1',
        'rater_name': 'Maya',
        'stars': '5',
      });
      expect(notificationTitle(n), 'Maya rated you 5★');
    });
  });

  group('run notification routes', () {
    test('run types deep-link to the run detail', () {
      for (final type in [
        'run_request',
        'run_request_accepted',
        'run_request_declined',
        'run_status',
        'run_completed',
        'run_order_withdrawn',
        'run_settle_reminder',
      ]) {
        final route = notificationRoute(
          _notif(type, {'run_id': 'r-42', 'spot_name': 'Chick-fil-A'}),
        );
        expect(route, isNotNull, reason: type);
        expect(route!.$1, '/runs/run/r-42', reason: type);
      }
    });

    test('missing run_id yields no route (legacy-safe)', () {
      expect(notificationRoute(_notif('run_request', {})), isNull);
    });
  });
}
