//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:campus_api/src/model/rating_context.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'rating_create_request.g.dart';

/// RatingCreateRequest
///
/// Properties:
/// * [comment] 
/// * [contextId] 
/// * [contextType] 
/// * [ratedUserId] 
/// * [stars] 
@BuiltValue()
abstract class RatingCreateRequest implements Built<RatingCreateRequest, RatingCreateRequestBuilder> {
  @BuiltValueField(wireName: r'comment')
  String? get comment;

  @BuiltValueField(wireName: r'context_id')
  String get contextId;

  @BuiltValueField(wireName: r'context_type')
  RatingContext get contextType;
  // enum contextTypeEnum {  listing,  tutoring,  };

  @BuiltValueField(wireName: r'rated_user_id')
  String get ratedUserId;

  @BuiltValueField(wireName: r'stars')
  int get stars;

  RatingCreateRequest._();

  factory RatingCreateRequest([void updates(RatingCreateRequestBuilder b)]) = _$RatingCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RatingCreateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RatingCreateRequest> get serializer => _$RatingCreateRequestSerializer();
}

class _$RatingCreateRequestSerializer implements PrimitiveSerializer<RatingCreateRequest> {
  @override
  final Iterable<Type> types = const [RatingCreateRequest, _$RatingCreateRequest];

  @override
  final String wireName = r'RatingCreateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RatingCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.comment != null) {
      yield r'comment';
      yield serializers.serialize(
        object.comment,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'context_id';
    yield serializers.serialize(
      object.contextId,
      specifiedType: const FullType(String),
    );
    yield r'context_type';
    yield serializers.serialize(
      object.contextType,
      specifiedType: const FullType(RatingContext),
    );
    yield r'rated_user_id';
    yield serializers.serialize(
      object.ratedUserId,
      specifiedType: const FullType(String),
    );
    yield r'stars';
    yield serializers.serialize(
      object.stars,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RatingCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RatingCreateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'comment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.comment = valueDes;
          break;
        case r'context_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.contextId = valueDes;
          break;
        case r'context_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RatingContext),
          ) as RatingContext;
          result.contextType = valueDes;
          break;
        case r'rated_user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ratedUserId = valueDes;
          break;
        case r'stars':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.stars = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RatingCreateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RatingCreateRequestBuilder();
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

