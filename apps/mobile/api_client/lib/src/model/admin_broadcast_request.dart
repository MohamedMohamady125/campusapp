//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_broadcast_request.g.dart';

/// Staff announcement: free-form title/body, optional email targeting.
///
/// Properties:
/// * [body] 
/// * [emails] 
/// * [title] 
@BuiltValue()
abstract class AdminBroadcastRequest implements Built<AdminBroadcastRequest, AdminBroadcastRequestBuilder> {
  @BuiltValueField(wireName: r'body')
  String? get body;

  @BuiltValueField(wireName: r'emails')
  BuiltList<String>? get emails;

  @BuiltValueField(wireName: r'title')
  String get title;

  AdminBroadcastRequest._();

  factory AdminBroadcastRequest([void updates(AdminBroadcastRequestBuilder b)]) = _$AdminBroadcastRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminBroadcastRequestBuilder b) => b
      ..body = '';

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminBroadcastRequest> get serializer => _$AdminBroadcastRequestSerializer();
}

class _$AdminBroadcastRequestSerializer implements PrimitiveSerializer<AdminBroadcastRequest> {
  @override
  final Iterable<Type> types = const [AdminBroadcastRequest, _$AdminBroadcastRequest];

  @override
  final String wireName = r'AdminBroadcastRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminBroadcastRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.body != null) {
      yield r'body';
      yield serializers.serialize(
        object.body,
        specifiedType: const FullType(String),
      );
    }
    if (object.emails != null) {
      yield r'emails';
      yield serializers.serialize(
        object.emails,
        specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
      );
    }
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminBroadcastRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminBroadcastRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'body':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.body = valueDes;
          break;
        case r'emails':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.emails.replace(valueDes);
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminBroadcastRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminBroadcastRequestBuilder();
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


