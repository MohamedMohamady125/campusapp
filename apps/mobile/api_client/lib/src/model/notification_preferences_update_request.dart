//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:campus_api/src/model/notification_preference_item.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_preferences_update_request.g.dart';

/// NotificationPreferencesUpdateRequest
///
/// Properties:
/// * [preferences] 
@BuiltValue()
abstract class NotificationPreferencesUpdateRequest implements Built<NotificationPreferencesUpdateRequest, NotificationPreferencesUpdateRequestBuilder> {
  @BuiltValueField(wireName: r'preferences')
  BuiltList<NotificationPreferenceItem> get preferences;

  NotificationPreferencesUpdateRequest._();

  factory NotificationPreferencesUpdateRequest([void updates(NotificationPreferencesUpdateRequestBuilder b)]) = _$NotificationPreferencesUpdateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationPreferencesUpdateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationPreferencesUpdateRequest> get serializer => _$NotificationPreferencesUpdateRequestSerializer();
}

class _$NotificationPreferencesUpdateRequestSerializer implements PrimitiveSerializer<NotificationPreferencesUpdateRequest> {
  @override
  final Iterable<Type> types = const [NotificationPreferencesUpdateRequest, _$NotificationPreferencesUpdateRequest];

  @override
  final String wireName = r'NotificationPreferencesUpdateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationPreferencesUpdateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'preferences';
    yield serializers.serialize(
      object.preferences,
      specifiedType: const FullType(BuiltList, [FullType(NotificationPreferenceItem)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationPreferencesUpdateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationPreferencesUpdateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'preferences':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(NotificationPreferenceItem)]),
          ) as BuiltList<NotificationPreferenceItem>;
          result.preferences.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NotificationPreferencesUpdateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationPreferencesUpdateRequestBuilder();
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

