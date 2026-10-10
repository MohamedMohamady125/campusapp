//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'device_unregister_request.g.dart';

/// DeviceUnregisterRequest
///
/// Properties:
/// * [token] 
@BuiltValue()
abstract class DeviceUnregisterRequest implements Built<DeviceUnregisterRequest, DeviceUnregisterRequestBuilder> {
  @BuiltValueField(wireName: r'token')
  String get token;

  DeviceUnregisterRequest._();

  factory DeviceUnregisterRequest([void updates(DeviceUnregisterRequestBuilder b)]) = _$DeviceUnregisterRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeviceUnregisterRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeviceUnregisterRequest> get serializer => _$DeviceUnregisterRequestSerializer();
}

class _$DeviceUnregisterRequestSerializer implements PrimitiveSerializer<DeviceUnregisterRequest> {
  @override
  final Iterable<Type> types = const [DeviceUnregisterRequest, _$DeviceUnregisterRequest];

  @override
  final String wireName = r'DeviceUnregisterRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeviceUnregisterRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'token';
    yield serializers.serialize(
      object.token,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DeviceUnregisterRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DeviceUnregisterRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.token = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeviceUnregisterRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeviceUnregisterRequestBuilder();
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

