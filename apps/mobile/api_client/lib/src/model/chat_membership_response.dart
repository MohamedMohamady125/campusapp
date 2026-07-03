//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:campus_api/src/model/chat_role.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'chat_membership_response.g.dart';

/// ChatMembershipResponse
///
/// Properties:
/// * [bannedAt] 
/// * [chatId] 
/// * [mutedUntil] 
/// * [role] 
/// * [userId] 
@BuiltValue()
abstract class ChatMembershipResponse implements Built<ChatMembershipResponse, ChatMembershipResponseBuilder> {
  @BuiltValueField(wireName: r'banned_at')
  DateTime? get bannedAt;

  @BuiltValueField(wireName: r'chat_id')
  String get chatId;

  @BuiltValueField(wireName: r'muted_until')
  DateTime? get mutedUntil;

  @BuiltValueField(wireName: r'role')
  ChatRole get role;
  // enum roleEnum {  member,  mod,  owner,  };

  @BuiltValueField(wireName: r'user_id')
  String get userId;

  ChatMembershipResponse._();

  factory ChatMembershipResponse([void updates(ChatMembershipResponseBuilder b)]) = _$ChatMembershipResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChatMembershipResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChatMembershipResponse> get serializer => _$ChatMembershipResponseSerializer();
}

class _$ChatMembershipResponseSerializer implements PrimitiveSerializer<ChatMembershipResponse> {
  @override
  final Iterable<Type> types = const [ChatMembershipResponse, _$ChatMembershipResponse];

  @override
  final String wireName = r'ChatMembershipResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChatMembershipResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'banned_at';
    yield object.bannedAt == null ? null : serializers.serialize(
      object.bannedAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'chat_id';
    yield serializers.serialize(
      object.chatId,
      specifiedType: const FullType(String),
    );
    yield r'muted_until';
    yield object.mutedUntil == null ? null : serializers.serialize(
      object.mutedUntil,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(ChatRole),
    );
    yield r'user_id';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ChatMembershipResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChatMembershipResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'banned_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.bannedAt = valueDes;
          break;
        case r'chat_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.chatId = valueDes;
          break;
        case r'muted_until':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.mutedUntil = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ChatRole),
          ) as ChatRole;
          result.role = valueDes;
          break;
        case r'user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ChatMembershipResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChatMembershipResponseBuilder();
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

