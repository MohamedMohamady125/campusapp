//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:campus_api/src/model/run_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'run_status_update_request.g.dart';

/// RunStatusUpdateRequest
///
/// Properties:
/// * [status] 
@BuiltValue()
abstract class RunStatusUpdateRequest implements Built<RunStatusUpdateRequest, RunStatusUpdateRequestBuilder> {
  @BuiltValueField(wireName: r'status')
  RunStatus get status;
  // enum statusEnum {  open,  locked,  at_store,  delivering,  done,  expired,  cancelled,  };

  RunStatusUpdateRequest._();

  factory RunStatusUpdateRequest([void updates(RunStatusUpdateRequestBuilder b)]) = _$RunStatusUpdateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RunStatusUpdateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RunStatusUpdateRequest> get serializer => _$RunStatusUpdateRequestSerializer();
}

class _$RunStatusUpdateRequestSerializer implements PrimitiveSerializer<RunStatusUpdateRequest> {
  @override
  final Iterable<Type> types = const [RunStatusUpdateRequest, _$RunStatusUpdateRequest];

  @override
  final String wireName = r'RunStatusUpdateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RunStatusUpdateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(RunStatus),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RunStatusUpdateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RunStatusUpdateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RunStatus),
          ) as RunStatus;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RunStatusUpdateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RunStatusUpdateRequestBuilder();
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

