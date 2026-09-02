//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:campus_api/src/model/payment_method.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'run_user_summary.g.dart';

/// Trust card shown on every run/order: identity + portable reputation.
///
/// Properties:
/// * [displayName] 
/// * [id] 
/// * [paymentMethods] 
/// * [ratingCount] 
/// * [reputationScore] 
@BuiltValue()
abstract class RunUserSummary implements Built<RunUserSummary, RunUserSummaryBuilder> {
  @BuiltValueField(wireName: r'display_name')
  String get displayName;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'payment_methods')
  BuiltList<PaymentMethod>? get paymentMethods;

  @BuiltValueField(wireName: r'rating_count')
  int get ratingCount;

  @BuiltValueField(wireName: r'reputation_score')
  num get reputationScore;

  RunUserSummary._();

  factory RunUserSummary([void updates(RunUserSummaryBuilder b)]) = _$RunUserSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RunUserSummaryBuilder b) => b
      ..paymentMethods = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<RunUserSummary> get serializer => _$RunUserSummarySerializer();
}

class _$RunUserSummarySerializer implements PrimitiveSerializer<RunUserSummary> {
  @override
  final Iterable<Type> types = const [RunUserSummary, _$RunUserSummary];

  @override
  final String wireName = r'RunUserSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RunUserSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'display_name';
    yield serializers.serialize(
      object.displayName,
      specifiedType: const FullType(String),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    if (object.paymentMethods != null) {
      yield r'payment_methods';
      yield serializers.serialize(
        object.paymentMethods,
        specifiedType: const FullType(BuiltList, [FullType(PaymentMethod)]),
      );
    }
    yield r'rating_count';
    yield serializers.serialize(
      object.ratingCount,
      specifiedType: const FullType(int),
    );
    yield r'reputation_score';
    yield serializers.serialize(
      object.reputationScore,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RunUserSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RunUserSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'display_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'payment_methods':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(PaymentMethod)]),
          ) as BuiltList<PaymentMethod>;
          result.paymentMethods.replace(valueDes);
          break;
        case r'rating_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.ratingCount = valueDes;
          break;
        case r'reputation_score':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.reputationScore = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RunUserSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RunUserSummaryBuilder();
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

