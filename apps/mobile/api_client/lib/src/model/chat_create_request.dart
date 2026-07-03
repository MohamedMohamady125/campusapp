//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:campus_api/src/model/chat_visibility.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'chat_create_request.g.dart';

/// ChatCreateRequest
///
/// Properties:
/// * [description] 
/// * [memberCap] 
/// * [name] 
/// * [visibility] 
@BuiltValue()
abstract class ChatCreateRequest implements Built<ChatCreateRequest, ChatCreateRequestBuilder> {
  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'member_cap')
  int? get memberCap;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'visibility')
  ChatVisibility? get visibility;
  // enum visibilityEnum {  open,  request,  private,  };

  ChatCreateRequest._();

  factory ChatCreateRequest([void updates(ChatCreateRequestBuilder b)]) = _$ChatCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChatCreateRequestBuilder b) => b
      ..memberCap = 500
      ..visibility = ChatVisibility.open;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChatCreateRequest> get serializer => _$ChatCreateRequestSerializer();
}

class _$ChatCreateRequestSerializer implements PrimitiveSerializer<ChatCreateRequest> {
  @override
  final Iterable<Type> types = const [ChatCreateRequest, _$ChatCreateRequest];

  @override
  final String wireName = r'ChatCreateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChatCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.memberCap != null) {
      yield r'member_cap';
      yield serializers.serialize(
        object.memberCap,
        specifiedType: const FullType(int),
      );
    }
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.visibility != null) {
      yield r'visibility';
      yield serializers.serialize(
        object.visibility,
        specifiedType: const FullType(ChatVisibility),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ChatCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChatCreateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        case r'member_cap':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.memberCap = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
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
  ChatCreateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChatCreateRequestBuilder();
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

