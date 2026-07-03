//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_preference_item.g.dart';

/// NotificationPreferenceItem
///
/// Properties:
/// * [enabled] 
/// * [type] 
@BuiltValue()
abstract class NotificationPreferenceItem implements Built<NotificationPreferenceItem, NotificationPreferenceItemBuilder> {
  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  @BuiltValueField(wireName: r'type')
  String get type;

  NotificationPreferenceItem._();

  factory NotificationPreferenceItem([void updates(NotificationPreferenceItemBuilder b)]) = _$NotificationPreferenceItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationPreferenceItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationPreferenceItem> get serializer => _$NotificationPreferenceItemSerializer();
}

class _$NotificationPreferenceItemSerializer implements PrimitiveSerializer<NotificationPreferenceItem> {
  @override
  final Iterable<Type> types = const [NotificationPreferenceItem, _$NotificationPreferenceItem];

  @override
  final String wireName = r'NotificationPreferenceItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationPreferenceItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'enabled';
    yield serializers.serialize(
      object.enabled,
      specifiedType: const FullType(bool),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationPreferenceItem object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationPreferenceItemBuilder result,
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
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.type = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NotificationPreferenceItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationPreferenceItemBuilder();
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

