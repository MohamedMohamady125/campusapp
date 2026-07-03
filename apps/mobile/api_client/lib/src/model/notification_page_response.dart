//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:campus_api/src/model/notification_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_page_response.g.dart';

/// NotificationPageResponse
///
/// Properties:
/// * [items] 
/// * [nextCursor] 
/// * [unreadCount] 
@BuiltValue()
abstract class NotificationPageResponse implements Built<NotificationPageResponse, NotificationPageResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<NotificationResponse> get items;

  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  @BuiltValueField(wireName: r'unread_count')
  int get unreadCount;

  NotificationPageResponse._();

  factory NotificationPageResponse([void updates(NotificationPageResponseBuilder b)]) = _$NotificationPageResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationPageResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationPageResponse> get serializer => _$NotificationPageResponseSerializer();
}

class _$NotificationPageResponseSerializer implements PrimitiveSerializer<NotificationPageResponse> {
  @override
  final Iterable<Type> types = const [NotificationPageResponse, _$NotificationPageResponse];

  @override
  final String wireName = r'NotificationPageResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationPageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(NotificationResponse)]),
    );
    yield r'next_cursor';
    yield object.nextCursor == null ? null : serializers.serialize(
      object.nextCursor,
      specifiedType: const FullType.nullable(String),
    );
    yield r'unread_count';
    yield serializers.serialize(
      object.unreadCount,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationPageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationPageResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(NotificationResponse)]),
          ) as BuiltList<NotificationResponse>;
          result.items.replace(valueDes);
          break;
        case r'next_cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nextCursor = valueDes;
          break;
        case r'unread_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.unreadCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NotificationPageResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationPageResponseBuilder();
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

