//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:campus_api/src/model/offering_response.dart';
import 'package:campus_api/src/model/user_public_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ranked_tutor_response.g.dart';

/// RankedTutorResponse
///
/// Properties:
/// * [offering] 
/// * [premium] 
/// * [recencyNorm] 
/// * [reputationNorm] 
/// * [responsivenessNorm] 
/// * [score] 
/// * [tutor] 
@BuiltValue()
abstract class RankedTutorResponse implements Built<RankedTutorResponse, RankedTutorResponseBuilder> {
  @BuiltValueField(wireName: r'offering')
  OfferingResponse get offering;

  @BuiltValueField(wireName: r'premium')
  bool? get premium;

  @BuiltValueField(wireName: r'recency_norm')
  num get recencyNorm;

  @BuiltValueField(wireName: r'reputation_norm')
  num get reputationNorm;

  @BuiltValueField(wireName: r'responsiveness_norm')
  num get responsivenessNorm;

  @BuiltValueField(wireName: r'score')
  num get score;

  @BuiltValueField(wireName: r'tutor')
  UserPublicResponse get tutor;

  RankedTutorResponse._();

  factory RankedTutorResponse([void updates(RankedTutorResponseBuilder b)]) = _$RankedTutorResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RankedTutorResponseBuilder b) => b
      ..premium = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<RankedTutorResponse> get serializer => _$RankedTutorResponseSerializer();
}

class _$RankedTutorResponseSerializer implements PrimitiveSerializer<RankedTutorResponse> {
  @override
  final Iterable<Type> types = const [RankedTutorResponse, _$RankedTutorResponse];

  @override
  final String wireName = r'RankedTutorResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RankedTutorResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'offering';
    yield serializers.serialize(
      object.offering,
      specifiedType: const FullType(OfferingResponse),
    );
    if (object.premium != null) {
      yield r'premium';
      yield serializers.serialize(
        object.premium,
        specifiedType: const FullType(bool),
      );
    }
    yield r'recency_norm';
    yield serializers.serialize(
      object.recencyNorm,
      specifiedType: const FullType(num),
    );
    yield r'reputation_norm';
    yield serializers.serialize(
      object.reputationNorm,
      specifiedType: const FullType(num),
    );
    yield r'responsiveness_norm';
    yield serializers.serialize(
      object.responsivenessNorm,
      specifiedType: const FullType(num),
    );
    yield r'score';
    yield serializers.serialize(
      object.score,
      specifiedType: const FullType(num),
    );
    yield r'tutor';
    yield serializers.serialize(
      object.tutor,
      specifiedType: const FullType(UserPublicResponse),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RankedTutorResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RankedTutorResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'offering':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OfferingResponse),
          ) as OfferingResponse;
          result.offering.replace(valueDes);
          break;
        case r'premium':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.premium = valueDes;
          break;
        case r'recency_norm':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.recencyNorm = valueDes;
          break;
        case r'reputation_norm':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.reputationNorm = valueDes;
          break;
        case r'responsiveness_norm':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.responsivenessNorm = valueDes;
          break;
        case r'score':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.score = valueDes;
          break;
        case r'tutor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UserPublicResponse),
          ) as UserPublicResponse;
          result.tutor.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RankedTutorResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RankedTutorResponseBuilder();
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

