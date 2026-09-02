//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'run_location_update_request.g.dart';

/// One GPS ping from the runner's device.
///
/// Properties:
/// * [lat] 
/// * [lng] 
@BuiltValue()
abstract class RunLocationUpdateRequest implements Built<RunLocationUpdateRequest, RunLocationUpdateRequestBuilder> {
  @BuiltValueField(wireName: r'lat')
  num get lat;

  @BuiltValueField(wireName: r'lng')
  num get lng;

  RunLocationUpdateRequest._();

  factory RunLocationUpdateRequest([void updates(RunLocationUpdateRequestBuilder b)]) = _$RunLocationUpdateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RunLocationUpdateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RunLocationUpdateRequest> get serializer => _$RunLocationUpdateRequestSerializer();
}

class _$RunLocationUpdateRequestSerializer implements PrimitiveSerializer<RunLocationUpdateRequest> {
  @override
  final Iterable<Type> types = const [RunLocationUpdateRequest, _$RunLocationUpdateRequest];

  @override
  final String wireName = r'RunLocationUpdateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RunLocationUpdateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'lat';
    yield serializers.serialize(
      object.lat,
      specifiedType: const FullType(num),
    );
    yield r'lng';
    yield serializers.serialize(
      object.lng,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RunLocationUpdateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RunLocationUpdateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'lat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.lat = valueDes;
          break;
        case r'lng':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.lng = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RunLocationUpdateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RunLocationUpdateRequestBuilder();
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

