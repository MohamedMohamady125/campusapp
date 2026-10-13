//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:campus_api/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'behavior_day.g.dart';

/// BehaviorDay
///
/// Properties:
/// * [activeUsers] 
/// * [day] 
/// * [events] 
/// * [sessions] 
@BuiltValue()
abstract class BehaviorDay implements Built<BehaviorDay, BehaviorDayBuilder> {
  @BuiltValueField(wireName: r'active_users')
  int get activeUsers;

  @BuiltValueField(wireName: r'day')
  Date get day;

  @BuiltValueField(wireName: r'events')
  int get events;

  @BuiltValueField(wireName: r'sessions')
  int get sessions;

  BehaviorDay._();

  factory BehaviorDay([void updates(BehaviorDayBuilder b)]) = _$BehaviorDay;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BehaviorDayBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BehaviorDay> get serializer => _$BehaviorDaySerializer();
}

class _$BehaviorDaySerializer implements PrimitiveSerializer<BehaviorDay> {
  @override
  final Iterable<Type> types = const [BehaviorDay, _$BehaviorDay];

  @override
  final String wireName = r'BehaviorDay';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BehaviorDay object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'active_users';
    yield serializers.serialize(
      object.activeUsers,
      specifiedType: const FullType(int),
    );
    yield r'day';
    yield serializers.serialize(
      object.day,
      specifiedType: const FullType(Date),
    );
    yield r'events';
    yield serializers.serialize(
      object.events,
      specifiedType: const FullType(int),
    );
    yield r'sessions';
    yield serializers.serialize(
      object.sessions,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BehaviorDay object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BehaviorDayBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'active_users':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.activeUsers = valueDes;
          break;
        case r'day':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.day = valueDes;
          break;
        case r'events':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.events = valueDes;
          break;
        case r'sessions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sessions = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BehaviorDay deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BehaviorDayBuilder();
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


