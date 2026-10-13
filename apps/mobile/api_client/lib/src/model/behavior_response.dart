//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:campus_api/src/model/event_stat.dart';
import 'package:built_collection/built_collection.dart';
import 'package:campus_api/src/model/screen_stat.dart';
import 'package:campus_api/src/model/behavior_day.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'behavior_response.g.dart';

/// BehaviorResponse
///
/// Properties:
/// * [daily] 
/// * [days] 
/// * [screens] 
/// * [topEvents] 
@BuiltValue()
abstract class BehaviorResponse implements Built<BehaviorResponse, BehaviorResponseBuilder> {
  @BuiltValueField(wireName: r'daily')
  BuiltList<BehaviorDay> get daily;

  @BuiltValueField(wireName: r'days')
  int get days;

  @BuiltValueField(wireName: r'screens')
  BuiltList<ScreenStat> get screens;

  @BuiltValueField(wireName: r'top_events')
  BuiltList<EventStat> get topEvents;

  BehaviorResponse._();

  factory BehaviorResponse([void updates(BehaviorResponseBuilder b)]) = _$BehaviorResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BehaviorResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BehaviorResponse> get serializer => _$BehaviorResponseSerializer();
}

class _$BehaviorResponseSerializer implements PrimitiveSerializer<BehaviorResponse> {
  @override
  final Iterable<Type> types = const [BehaviorResponse, _$BehaviorResponse];

  @override
  final String wireName = r'BehaviorResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BehaviorResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'daily';
    yield serializers.serialize(
      object.daily,
      specifiedType: const FullType(BuiltList, [FullType(BehaviorDay)]),
    );
    yield r'days';
    yield serializers.serialize(
      object.days,
      specifiedType: const FullType(int),
    );
    yield r'screens';
    yield serializers.serialize(
      object.screens,
      specifiedType: const FullType(BuiltList, [FullType(ScreenStat)]),
    );
    yield r'top_events';
    yield serializers.serialize(
      object.topEvents,
      specifiedType: const FullType(BuiltList, [FullType(EventStat)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BehaviorResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BehaviorResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'daily':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BehaviorDay)]),
          ) as BuiltList<BehaviorDay>;
          result.daily.replace(valueDes);
          break;
        case r'days':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.days = valueDes;
          break;
        case r'screens':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ScreenStat)]),
          ) as BuiltList<ScreenStat>;
          result.screens.replace(valueDes);
          break;
        case r'top_events':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(EventStat)]),
          ) as BuiltList<EventStat>;
          result.topEvents.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BehaviorResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BehaviorResponseBuilder();
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


