//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'flag_item.g.dart';

/// FlagItem
///
/// Properties:
/// * [enabled] 
/// * [key] 
/// * [rolloutPercent] 
@BuiltValue()
abstract class FlagItem implements Built<FlagItem, FlagItemBuilder> {
  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  @BuiltValueField(wireName: r'key')
  String get key;

  @BuiltValueField(wireName: r'rollout_percent')
  int get rolloutPercent;

  FlagItem._();

  factory FlagItem([void updates(FlagItemBuilder b)]) = _$FlagItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FlagItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FlagItem> get serializer => _$FlagItemSerializer();
}

class _$FlagItemSerializer implements PrimitiveSerializer<FlagItem> {
  @override
  final Iterable<Type> types = const [FlagItem, _$FlagItem];

  @override
  final String wireName = r'FlagItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FlagItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'enabled';
    yield serializers.serialize(
      object.enabled,
      specifiedType: const FullType(bool),
    );
    yield r'key';
    yield serializers.serialize(
      object.key,
      specifiedType: const FullType(String),
    );
    yield r'rollout_percent';
    yield serializers.serialize(
      object.rolloutPercent,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FlagItem object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FlagItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enabled = valueDes;
          break;
        case r'key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.key = valueDes;
          break;
        case r'rollout_percent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.rolloutPercent = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FlagItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FlagItemBuilder();
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

