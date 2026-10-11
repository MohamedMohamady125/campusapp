//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'actual_price_submit_request.g.dart';

/// Runner enters the real receipt price after buying (settle-up truth-up).
///
/// Properties:
/// * [actualPriceCents] 
@BuiltValue()
abstract class ActualPriceSubmitRequest implements Built<ActualPriceSubmitRequest, ActualPriceSubmitRequestBuilder> {
  @BuiltValueField(wireName: r'actual_price_cents')
  int get actualPriceCents;

  ActualPriceSubmitRequest._();

  factory ActualPriceSubmitRequest([void updates(ActualPriceSubmitRequestBuilder b)]) = _$ActualPriceSubmitRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ActualPriceSubmitRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ActualPriceSubmitRequest> get serializer => _$ActualPriceSubmitRequestSerializer();
}

class _$ActualPriceSubmitRequestSerializer implements PrimitiveSerializer<ActualPriceSubmitRequest> {
  @override
  final Iterable<Type> types = const [ActualPriceSubmitRequest, _$ActualPriceSubmitRequest];

  @override
  final String wireName = r'ActualPriceSubmitRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ActualPriceSubmitRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'actual_price_cents';
    yield serializers.serialize(
      object.actualPriceCents,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ActualPriceSubmitRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ActualPriceSubmitRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'actual_price_cents':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.actualPriceCents = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ActualPriceSubmitRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ActualPriceSubmitRequestBuilder();
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

