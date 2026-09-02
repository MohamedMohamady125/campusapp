//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'run_order_create_request.g.dart';

/// RunOrderCreateRequest
///
/// Properties:
/// * [dropoff] 
/// * [orderText] 
@BuiltValue()
abstract class RunOrderCreateRequest implements Built<RunOrderCreateRequest, RunOrderCreateRequestBuilder> {
  @BuiltValueField(wireName: r'dropoff')
  String get dropoff;

  @BuiltValueField(wireName: r'order_text')
  String get orderText;

  RunOrderCreateRequest._();

  factory RunOrderCreateRequest([void updates(RunOrderCreateRequestBuilder b)]) = _$RunOrderCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RunOrderCreateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RunOrderCreateRequest> get serializer => _$RunOrderCreateRequestSerializer();
}

class _$RunOrderCreateRequestSerializer implements PrimitiveSerializer<RunOrderCreateRequest> {
  @override
  final Iterable<Type> types = const [RunOrderCreateRequest, _$RunOrderCreateRequest];

  @override
  final String wireName = r'RunOrderCreateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RunOrderCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'dropoff';
    yield serializers.serialize(
      object.dropoff,
      specifiedType: const FullType(String),
    );
    yield r'order_text';
    yield serializers.serialize(
      object.orderText,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RunOrderCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RunOrderCreateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'dropoff':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.dropoff = valueDes;
          break;
        case r'order_text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.orderText = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RunOrderCreateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RunOrderCreateRequestBuilder();
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

