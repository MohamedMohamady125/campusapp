//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notifications_read_request.g.dart';

/// NotificationsReadRequest
///
/// Properties:
/// * [ids] 
@BuiltValue()
abstract class NotificationsReadRequest implements Built<NotificationsReadRequest, NotificationsReadRequestBuilder> {
  @BuiltValueField(wireName: r'ids')
  BuiltList<String>? get ids;

  NotificationsReadRequest._();

  factory NotificationsReadRequest([void updates(NotificationsReadRequestBuilder b)]) = _$NotificationsReadRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationsReadRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationsReadRequest> get serializer => _$NotificationsReadRequestSerializer();
}

class _$NotificationsReadRequestSerializer implements PrimitiveSerializer<NotificationsReadRequest> {
  @override
  final Iterable<Type> types = const [NotificationsReadRequest, _$NotificationsReadRequest];

  @override
  final String wireName = r'NotificationsReadRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationsReadRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.ids != null) {
      yield r'ids';
      yield serializers.serialize(
        object.ids,
        specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationsReadRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationsReadRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.ids.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NotificationsReadRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationsReadRequestBuilder();
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

