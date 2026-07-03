//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'subscription_response.g.dart';

/// SubscriptionResponse
///
/// Properties:
/// * [currentPeriodEnd] 
/// * [id] 
/// * [plan] 
/// * [status] 
@BuiltValue()
abstract class SubscriptionResponse implements Built<SubscriptionResponse, SubscriptionResponseBuilder> {
  @BuiltValueField(wireName: r'current_period_end')
  DateTime get currentPeriodEnd;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'plan')
  String get plan;

  @BuiltValueField(wireName: r'status')
  String get status;

  SubscriptionResponse._();

  factory SubscriptionResponse([void updates(SubscriptionResponseBuilder b)]) = _$SubscriptionResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SubscriptionResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SubscriptionResponse> get serializer => _$SubscriptionResponseSerializer();
}

class _$SubscriptionResponseSerializer implements PrimitiveSerializer<SubscriptionResponse> {
  @override
  final Iterable<Type> types = const [SubscriptionResponse, _$SubscriptionResponse];

  @override
  final String wireName = r'SubscriptionResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SubscriptionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'current_period_end';
    yield serializers.serialize(
      object.currentPeriodEnd,
      specifiedType: const FullType(DateTime),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'plan';
    yield serializers.serialize(
      object.plan,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SubscriptionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SubscriptionResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'current_period_end':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.currentPeriodEnd = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'plan':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.plan = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
  SubscriptionResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SubscriptionResponseBuilder();
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

