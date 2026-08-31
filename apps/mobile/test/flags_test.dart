import 'dart:typed_data';

import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/flags/flags_provider.dart';
import 'package:campusconnect/core/network/api_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Adapter that fails every request — simulates a flaky boot.
class _FailingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test(
    'flags default to the food-runs tab only when the flags call fails',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://flags.test'))
        ..httpClientAdapter = _FailingAdapter();
      final container = ProviderContainer(
        overrides: [campusApiProvider.overrideWithValue(CampusApi(dio: dio))],
      );
      addTearDown(container.dispose);

      final controller = container.read(flagsProvider.notifier);
      await controller.refresh(); // deterministic failed load

      expect(container.read(flagsProvider), {kTabFoodRuns});
      expect(controller.isEnabled(kTabMarketplace), isFalse);
      expect(controller.isEnabled(kTabFoodRuns), isTrue);
    },
  );
}
