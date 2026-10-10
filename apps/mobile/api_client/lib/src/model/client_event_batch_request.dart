//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:campus_api/src/model/client_event_in.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'client_event_batch_request.g.dart';

/// ClientEventBatchRequest
///
/// Properties:
/// * [events] 
/// * [platform] 
/// * [sessionId] 
@BuiltValue()
abstract class ClientEventBatchRequest implements Built<ClientEventBatchRequest, ClientEventBatchRequestBuilder> {
  @BuiltValueField(wireName: r'events')
  BuiltList<ClientEventIn> get events;

  @BuiltValueField(wireName: r'platform')
  ClientEventBatchRequestPlatformEnum get platform;
  // enum platformEnum {  ios,  android,  web,  };

  @BuiltValueField(wireName: r'session_id')
  String get sessionId;

  ClientEventBatchRequest._();

  factory ClientEventBatchRequest([void updates(ClientEventBatchRequestBuilder b)]) = _$ClientEventBatchRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ClientEventBatchRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ClientEventBatchRequest> get serializer => _$ClientEventBatchRequestSerializer();
}

class _$ClientEventBatchRequestSerializer implements PrimitiveSerializer<ClientEventBatchRequest> {
  @override
  final Iterable<Type> types = const [ClientEventBatchRequest, _$ClientEventBatchRequest];

  @override
  final String wireName = r'ClientEventBatchRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ClientEventBatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'events';
    yield serializers.serialize(
      object.events,
      specifiedType: const FullType(BuiltList, [FullType(ClientEventIn)]),
    );
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(ClientEventBatchRequestPlatformEnum),
    );
    yield r'session_id';
    yield serializers.serialize(
      object.sessionId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ClientEventBatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ClientEventBatchRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'events':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ClientEventIn)]),
          ) as BuiltList<ClientEventIn>;
          result.events.replace(valueDes);
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ClientEventBatchRequestPlatformEnum),
          ) as ClientEventBatchRequestPlatformEnum;
          result.platform = valueDes;
          break;
        case r'session_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sessionId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ClientEventBatchRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ClientEventBatchRequestBuilder();
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

class ClientEventBatchRequestPlatformEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ios')
  static const ClientEventBatchRequestPlatformEnum ios = _$clientEventBatchRequestPlatformEnum_ios;
  @BuiltValueEnumConst(wireName: r'android')
  static const ClientEventBatchRequestPlatformEnum android = _$clientEventBatchRequestPlatformEnum_android;
  @BuiltValueEnumConst(wireName: r'web')
  static const ClientEventBatchRequestPlatformEnum web = _$clientEventBatchRequestPlatformEnum_web;

  static Serializer<ClientEventBatchRequestPlatformEnum> get serializer => _$clientEventBatchRequestPlatformEnumSerializer;

  const ClientEventBatchRequestPlatformEnum._(String name): super(name);

  static BuiltSet<ClientEventBatchRequestPlatformEnum> get values => _$clientEventBatchRequestPlatformEnumValues;
  static ClientEventBatchRequestPlatformEnum valueOf(String name) => _$clientEventBatchRequestPlatformEnumValueOf(name);
}

