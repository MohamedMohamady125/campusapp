//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:campus_api/src/model/run_user_summary.dart';
import 'package:built_collection/built_collection.dart';
import 'package:campus_api/src/model/run_status.dart';
import 'package:campus_api/src/model/run_order_response.dart';
import 'package:campus_api/src/model/food_spot_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'run_response.g.dart';

/// RunResponse
///
/// Properties:
/// * [acceptedCount] 
/// * [conversationId] 
/// * [createdAt] 
/// * [deliverySpot] 
/// * [feeCents] 
/// * [foodSpot] 
/// * [id] 
/// * [leavingAt] 
/// * [myOrder] 
/// * [note] 
/// * [orders] 
/// * [paysWithDiningDollars] 
/// * [pendingCount] 
/// * [prepayRequired] 
/// * [runner] 
/// * [spotsMax] 
/// * [status] 
@BuiltValue()
abstract class RunResponse implements Built<RunResponse, RunResponseBuilder> {
  @BuiltValueField(wireName: r'accepted_count')
  int get acceptedCount;

  @BuiltValueField(wireName: r'conversation_id')
  String? get conversationId;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'delivery_spot')
  String get deliverySpot;

  @BuiltValueField(wireName: r'fee_cents')
  int get feeCents;

  @BuiltValueField(wireName: r'food_spot')
  FoodSpotResponse get foodSpot;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'leaving_at')
  DateTime get leavingAt;

  @BuiltValueField(wireName: r'my_order')
  RunOrderResponse? get myOrder;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'orders')
  BuiltList<RunOrderResponse>? get orders;

  @BuiltValueField(wireName: r'pays_with_dining_dollars')
  bool get paysWithDiningDollars;

  @BuiltValueField(wireName: r'pending_count')
  int get pendingCount;

  @BuiltValueField(wireName: r'prepay_required')
  bool get prepayRequired;

  @BuiltValueField(wireName: r'runner')
  RunUserSummary get runner;

  @BuiltValueField(wireName: r'spots_max')
  int get spotsMax;

  @BuiltValueField(wireName: r'status')
  RunStatus get status;
  // enum statusEnum {  open,  locked,  at_store,  delivering,  done,  expired,  cancelled,  };

  RunResponse._();

  factory RunResponse([void updates(RunResponseBuilder b)]) = _$RunResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RunResponseBuilder b) => b
      ..orders = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<RunResponse> get serializer => _$RunResponseSerializer();
}

class _$RunResponseSerializer implements PrimitiveSerializer<RunResponse> {
  @override
  final Iterable<Type> types = const [RunResponse, _$RunResponse];

  @override
  final String wireName = r'RunResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RunResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'accepted_count';
    yield serializers.serialize(
      object.acceptedCount,
      specifiedType: const FullType(int),
    );
    yield r'conversation_id';
    yield object.conversationId == null ? null : serializers.serialize(
      object.conversationId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'delivery_spot';
    yield serializers.serialize(
      object.deliverySpot,
      specifiedType: const FullType(String),
    );
    yield r'fee_cents';
    yield serializers.serialize(
      object.feeCents,
      specifiedType: const FullType(int),
    );
    yield r'food_spot';
    yield serializers.serialize(
      object.foodSpot,
      specifiedType: const FullType(FoodSpotResponse),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'leaving_at';
    yield serializers.serialize(
      object.leavingAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.myOrder != null) {
      yield r'my_order';
      yield serializers.serialize(
        object.myOrder,
        specifiedType: const FullType.nullable(RunOrderResponse),
      );
    }
    yield r'note';
    yield object.note == null ? null : serializers.serialize(
      object.note,
      specifiedType: const FullType.nullable(String),
    );
    if (object.orders != null) {
      yield r'orders';
      yield serializers.serialize(
        object.orders,
        specifiedType: const FullType(BuiltList, [FullType(RunOrderResponse)]),
      );
    }
    yield r'pays_with_dining_dollars';
    yield serializers.serialize(
      object.paysWithDiningDollars,
      specifiedType: const FullType(bool),
    );
    yield r'pending_count';
    yield serializers.serialize(
      object.pendingCount,
      specifiedType: const FullType(int),
    );
    yield r'prepay_required';
    yield serializers.serialize(
      object.prepayRequired,
      specifiedType: const FullType(bool),
    );
    yield r'runner';
    yield serializers.serialize(
      object.runner,
      specifiedType: const FullType(RunUserSummary),
    );
    yield r'spots_max';
    yield serializers.serialize(
      object.spotsMax,
      specifiedType: const FullType(int),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(RunStatus),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RunResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RunResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'accepted_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.acceptedCount = valueDes;
          break;
        case r'conversation_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.conversationId = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'delivery_spot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deliverySpot = valueDes;
          break;
        case r'fee_cents':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.feeCents = valueDes;
          break;
        case r'food_spot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FoodSpotResponse),
          ) as FoodSpotResponse;
          result.foodSpot.replace(valueDes);
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'leaving_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.leavingAt = valueDes;
          break;
        case r'my_order':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(RunOrderResponse),
          ) as RunOrderResponse?;
          if (valueDes == null) continue;
          result.myOrder.replace(valueDes);
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'orders':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(RunOrderResponse)]),
          ) as BuiltList<RunOrderResponse>;
          result.orders.replace(valueDes);
          break;
        case r'pays_with_dining_dollars':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.paysWithDiningDollars = valueDes;
          break;
        case r'pending_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pendingCount = valueDes;
          break;
        case r'prepay_required':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.prepayRequired = valueDes;
          break;
        case r'runner':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RunUserSummary),
          ) as RunUserSummary;
          result.runner.replace(valueDes);
          break;
        case r'spots_max':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.spotsMax = valueDes;
          break;
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
  RunResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RunResponseBuilder();
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

