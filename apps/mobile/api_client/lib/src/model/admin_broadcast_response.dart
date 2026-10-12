//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_broadcast_response.g.dart';

/// AdminBroadcastResponse
///
/// Properties:
/// * [sent] 
/// * [unknownEmails] 
@BuiltValue()
abstract class AdminBroadcastResponse implements Built<AdminBroadcastResponse, AdminBroadcastResponseBuilder> {
  @BuiltValueField(wireName: r'sent')
  int get sent;

  @BuiltValueField(wireName: r'unknown_emails')
  BuiltList<String> get unknownEmails;

  AdminBroadcastResponse._();

  factory AdminBroadcastResponse([void updates(AdminBroadcastResponseBuilder b)]) = _$AdminBroadcastResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminBroadcastResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminBroadcastResponse> get serializer => _$AdminBroadcastResponseSerializer();
}

class _$AdminBroadcastResponseSerializer implements PrimitiveSerializer<AdminBroadcastResponse> {
  @override
  final Iterable<Type> types = const [AdminBroadcastResponse, _$AdminBroadcastResponse];

  @override
  final String wireName = r'AdminBroadcastResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminBroadcastResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'sent';
    yield serializers.serialize(
      object.sent,
      specifiedType: const FullType(int),
    );
    yield r'unknown_emails';
    yield serializers.serialize(
      object.unknownEmails,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminBroadcastResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminBroadcastResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sent = valueDes;
          break;
        case r'unknown_emails':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.unknownEmails.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminBroadcastResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminBroadcastResponseBuilder();
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

