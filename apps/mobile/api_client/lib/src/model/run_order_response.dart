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
/// * [dropoffLat] 
/// * [dropoffLng] 
/// * [id] 
/// * [orderText] 
/// * [paymentNote] 
/// * [paymentProofUrl] 
/// * [paymentSubmittedAt] 
/// * [ratedByMe] 
/// * [requester] 
/// * [runId] 
/// * [status] 
@BuiltValue()
abstract class RunOrderResponse implements Built<RunOrderResponse, RunOrderResponseBuilder> {
  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'dropoff')
  String get dropoff;

  @BuiltValueField(wireName: r'dropoff_lat')
  num? get dropoffLat;

  @BuiltValueField(wireName: r'dropoff_lng')
  num? get dropoffLng;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'order_text')
  String get orderText;

  @BuiltValueField(wireName: r'payment_note')
  String? get paymentNote;

  @BuiltValueField(wireName: r'payment_proof_url')
  String? get paymentProofUrl;

  @BuiltValueField(wireName: r'payment_submitted_at')
  DateTime? get paymentSubmittedAt;

  @BuiltValueField(wireName: r'rated_by_me')
  bool? get ratedByMe;

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
  static void _defaults(RunOrderResponseBuilder b) => b
      ..ratedByMe = false;

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
    if (object.dropoffLat != null) {
      yield r'dropoff_lat';
      yield serializers.serialize(
        object.dropoffLat,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.dropoffLng != null) {
      yield r'dropoff_lng';
      yield serializers.serialize(
        object.dropoffLng,
        specifiedType: const FullType.nullable(num),
      );
    }
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
    if (object.paymentNote != null) {
      yield r'payment_note';
      yield serializers.serialize(
        object.paymentNote,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.paymentProofUrl != null) {
      yield r'payment_proof_url';
      yield serializers.serialize(
        object.paymentProofUrl,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.paymentSubmittedAt != null) {
      yield r'payment_submitted_at';
      yield serializers.serialize(
        object.paymentSubmittedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.ratedByMe != null) {
      yield r'rated_by_me';
      yield serializers.serialize(
        object.ratedByMe,
        specifiedType: const FullType(bool),
      );
    }
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
        case r'dropoff_lat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.dropoffLat = valueDes;
          break;
        case r'dropoff_lng':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.dropoffLng = valueDes;
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
        case r'payment_note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.paymentNote = valueDes;
          break;
        case r'payment_proof_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.paymentProofUrl = valueDes;
          break;
        case r'payment_submitted_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.paymentSubmittedAt = valueDes;
          break;
        case r'rated_by_me':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.ratedByMe = valueDes;
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

