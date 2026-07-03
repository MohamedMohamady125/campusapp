//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:campus_api/src/model/daily_metric_item.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'metrics_response.g.dart';

/// MetricsResponse
///
/// Properties:
/// * [daily] 
/// * [totals] 
@BuiltValue()
abstract class MetricsResponse implements Built<MetricsResponse, MetricsResponseBuilder> {
  @BuiltValueField(wireName: r'daily')
  BuiltList<DailyMetricItem> get daily;

  @BuiltValueField(wireName: r'totals')
  BuiltMap<String, int> get totals;

  MetricsResponse._();

  factory MetricsResponse([void updates(MetricsResponseBuilder b)]) = _$MetricsResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MetricsResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MetricsResponse> get serializer => _$MetricsResponseSerializer();
}

class _$MetricsResponseSerializer implements PrimitiveSerializer<MetricsResponse> {
  @override
  final Iterable<Type> types = const [MetricsResponse, _$MetricsResponse];

  @override
  final String wireName = r'MetricsResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MetricsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'daily';
    yield serializers.serialize(
      object.daily,
      specifiedType: const FullType(BuiltList, [FullType(DailyMetricItem)]),
    );
    yield r'totals';
    yield serializers.serialize(
      object.totals,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType(int)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MetricsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MetricsResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'daily':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(DailyMetricItem)]),
          ) as BuiltList<DailyMetricItem>;
          result.daily.replace(valueDes);
          break;
        case r'totals':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(int)]),
          ) as BuiltMap<String, int>;
          result.totals.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MetricsResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MetricsResponseBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

