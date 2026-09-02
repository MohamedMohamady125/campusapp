//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:campus_api/src/model/run_user_summary.dart';
import 'package:campus_api/src/model/run_order_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'run_order_response.g.dart';

/// RunOrderResponse
///
/// Properties:
/// * [createdAt] 
/// * [dropoff] 
/// * [id] 
/// * [orderText] 
/// * [requester] 
/// * [runId] 
/// * [status] 
@BuiltValue()
abstract class RunOrderResponse implements Built<RunOrderResponse, RunOrderResponseBuilder> {
  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'dropoff')
  String get dropoff;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'order_text')
  String get orderText;

  @BuiltValueField(wireName: r'requester')
  RunUserSummary get requester;

  @BuiltValueField(wireName: r'run_id')
  String get runId;

  @BuiltValueField(wireName: r'status')
  RunOrderStatus get status;
  // enum statusEnum {  requested,  accepted,  declined,  cancelled,  delivered,  received,  no_show,  };

  RunOrderResponse._();

  factory RunOrderResponse([void updates(RunOrderResponseBuilder b)]) = _$RunOrderResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RunOrderResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RunOrderResponse> get serializer => _$RunOrderResponseSerializer();
}

class _$RunOrderResponseSerializer implements PrimitiveSerializer<RunOrderResponse> {
  @override
  final Iterable<Type> types = const [RunOrderResponse, _$RunOrderResponse];

  @override
  final String wireName = r'RunOrderResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RunOrderResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'dropoff';
    yield serializers.serialize(
      object.dropoff,
      specifiedType: const FullType(String),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'order_text';
    yield serializers.serialize(
      object.orderText,
      specifiedType: const FullType(String),
    );
    yield r'requester';
    yield serializers.serialize(
      object.requester,
      specifiedType: const FullType(RunUserSummary),
    );
    yield r'run_id';
    yield serializers.serialize(
      object.runId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(RunOrderStatus),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RunOrderResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RunOrderResponseBuilder result,
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
        case r'dropoff':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.dropoff = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'order_text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.orderText = valueDes;
          break;
        case r'requester':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RunUserSummary),
          ) as RunUserSummary;
          result.requester.replace(valueDes);
          break;
        case r'run_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.runId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RunOrderStatus),
          ) as RunOrderStatus;
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
  RunOrderResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RunOrderResponseBuilder();
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

