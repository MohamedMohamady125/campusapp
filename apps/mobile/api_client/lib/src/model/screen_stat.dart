//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'screen_stat.g.dart';

/// ScreenStat
///
/// Properties:
/// * [avgSeconds] 
/// * [screen] 
/// * [totalMinutes] 
/// * [uniqueUsers] 
/// * [views] 
@BuiltValue()
abstract class ScreenStat implements Built<ScreenStat, ScreenStatBuilder> {
  @BuiltValueField(wireName: r'avg_seconds')
  num get avgSeconds;

  @BuiltValueField(wireName: r'screen')
  String get screen;

  @BuiltValueField(wireName: r'total_minutes')
  num get totalMinutes;

  @BuiltValueField(wireName: r'unique_users')
  int get uniqueUsers;

  @BuiltValueField(wireName: r'views')
  int get views;

  ScreenStat._();

  factory ScreenStat([void updates(ScreenStatBuilder b)]) = _$ScreenStat;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ScreenStatBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ScreenStat> get serializer => _$ScreenStatSerializer();
}

class _$ScreenStatSerializer implements PrimitiveSerializer<ScreenStat> {
  @override
  final Iterable<Type> types = const [ScreenStat, _$ScreenStat];

  @override
  final String wireName = r'ScreenStat';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ScreenStat object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'avg_seconds';
    yield serializers.serialize(
      object.avgSeconds,
      specifiedType: const FullType(num),
    );
    yield r'screen';
    yield serializers.serialize(
      object.screen,
      specifiedType: const FullType(String),
    );
    yield r'total_minutes';
    yield serializers.serialize(
      object.totalMinutes,
      specifiedType: const FullType(num),
    );
    yield r'unique_users';
    yield serializers.serialize(
      object.uniqueUsers,
      specifiedType: const FullType(int),
    );
    yield r'views';
    yield serializers.serialize(
      object.views,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ScreenStat object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ScreenStatBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'avg_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.avgSeconds = valueDes;
          break;
        case r'screen':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.screen = valueDes;
          break;
        case r'total_minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.totalMinutes = valueDes;
          break;
        case r'unique_users':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.uniqueUsers = valueDes;
          break;
        case r'views':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.views = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ScreenStat deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ScreenStatBuilder();
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


