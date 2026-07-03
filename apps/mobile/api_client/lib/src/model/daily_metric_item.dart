//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:campus_api/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'daily_metric_item.g.dart';

/// DailyMetricItem
///
/// Properties:
/// * [day] 
/// * [name] 
/// * [value] 
@BuiltValue()
abstract class DailyMetricItem implements Built<DailyMetricItem, DailyMetricItemBuilder> {
  @BuiltValueField(wireName: r'day')
  Date get day;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'value')
  num get value;

  DailyMetricItem._();

  factory DailyMetricItem([void updates(DailyMetricItemBuilder b)]) = _$DailyMetricItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DailyMetricItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DailyMetricItem> get serializer => _$DailyMetricItemSerializer();
}

class _$DailyMetricItemSerializer implements PrimitiveSerializer<DailyMetricItem> {
  @override
  final Iterable<Type> types = const [DailyMetricItem, _$DailyMetricItem];

  @override
  final String wireName = r'DailyMetricItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DailyMetricItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'day';
    yield serializers.serialize(
      object.day,
      specifiedType: const FullType(Date),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'value';
    yield serializers.serialize(
      object.value,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DailyMetricItem object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DailyMetricItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'day':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.day = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.value = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DailyMetricItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DailyMetricItemBuilder();
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

