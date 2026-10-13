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
/// * [dropoffLocationId] 
/// * [itemPriceCents] 
/// * [orderText] 
@BuiltValue()
abstract class RunOrderCreateRequest implements Built<RunOrderCreateRequest, RunOrderCreateRequestBuilder> {
  @BuiltValueField(wireName: r'dropoff_location_id')
  String get dropoffLocationId;

  @BuiltValueField(wireName: r'item_price_cents')
  int? get itemPriceCents;

  @BuiltValueField(wireName: r'order_text')
  String get orderText;

  RunOrderCreateRequest._();

  factory RunOrderCreateRequest([void updates(RunOrderCreateRequestBuilder b)]) = _$RunOrderCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RunOrderCreateRequestBuilder b) => b
      ..itemPriceCents = 0;

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
    yield r'dropoff_location_id';
    yield serializers.serialize(
      object.dropoffLocationId,
      specifiedType: const FullType(String),
    );
    if (object.itemPriceCents != null) {
      yield r'item_price_cents';
      yield serializers.serialize(
        object.itemPriceCents,
        specifiedType: const FullType(int),
      );
    }
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
        case r'dropoff_location_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.dropoffLocationId = valueDes;
          break;
        case r'item_price_cents':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.itemPriceCents = valueDes;
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


