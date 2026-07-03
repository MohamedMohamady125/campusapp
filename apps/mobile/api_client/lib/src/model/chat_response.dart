//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:campus_api/src/model/chat_visibility.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'chat_response.g.dart';

/// ChatResponse
///
/// Properties:
/// * [createdAt] 
/// * [createdById] 
/// * [description] 
/// * [id] 
/// * [memberCap] 
/// * [memberCount] 
/// * [name] 
/// * [slug] 
/// * [visibility] 
@BuiltValue()
abstract class ChatResponse implements Built<ChatResponse, ChatResponseBuilder> {
  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'created_by_id')
  String get createdById;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'member_cap')
  int get memberCap;

  @BuiltValueField(wireName: r'member_count')
  int get memberCount;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'slug')
  String get slug;

  @BuiltValueField(wireName: r'visibility')
  ChatVisibility get visibility;
  // enum visibilityEnum {  open,  request,  private,  };

  ChatResponse._();

  factory ChatResponse([void updates(ChatResponseBuilder b)]) = _$ChatResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChatResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChatResponse> get serializer => _$ChatResponseSerializer();
}

class _$ChatResponseSerializer implements PrimitiveSerializer<ChatResponse> {
  @override
  final Iterable<Type> types = const [ChatResponse, _$ChatResponse];

  @override
  final String wireName = r'ChatResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChatResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'created_by_id';
    yield serializers.serialize(
      object.createdById,
      specifiedType: const FullType(String),
    );
    yield r'description';
    yield object.description == null ? null : serializers.serialize(
      object.description,
      specifiedType: const FullType.nullable(String),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'member_cap';
    yield serializers.serialize(
      object.memberCap,
      specifiedType: const FullType(int),
    );
    yield r'member_count';
    yield serializers.serialize(
      object.memberCount,
      specifiedType: const FullType(int),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'slug';
    yield serializers.serialize(
      object.slug,
      specifiedType: const FullType(String),
    );
    yield r'visibility';
    yield serializers.serialize(
      object.visibility,
      specifiedType: const FullType(ChatVisibility),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ChatResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChatResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'created_by_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.createdById = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'member_cap':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.memberCap = valueDes;
          break;
        case r'member_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.memberCount = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'slug':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.slug = valueDes;
          break;
        case r'visibility':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ChatVisibility),
          ) as ChatVisibility;
          result.visibility = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ChatResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChatResponseBuilder();
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

