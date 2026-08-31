//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:campus_api/src/model/rating_context.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'rating_response.g.dart';

/// RatingResponse
///
/// Properties:
/// * [comment] 
/// * [contextId] 
/// * [contextType] 
/// * [createdAt] 
/// * [id] 
/// * [ratedUserId] 
/// * [raterId] 
/// * [stars] 
@BuiltValue()
abstract class RatingResponse implements Built<RatingResponse, RatingResponseBuilder> {
  @BuiltValueField(wireName: r'comment')
  String? get comment;

  @BuiltValueField(wireName: r'context_id')
  String get contextId;

  @BuiltValueField(wireName: r'context_type')
  RatingContext get contextType;
  // enum contextTypeEnum {  listing,  tutoring,  run,  };

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'rated_user_id')
  String get ratedUserId;

  @BuiltValueField(wireName: r'rater_id')
  String get raterId;

  @BuiltValueField(wireName: r'stars')
  int get stars;

  RatingResponse._();

  factory RatingResponse([void updates(RatingResponseBuilder b)]) = _$RatingResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RatingResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RatingResponse> get serializer => _$RatingResponseSerializer();
}

class _$RatingResponseSerializer implements PrimitiveSerializer<RatingResponse> {
  @override
  final Iterable<Type> types = const [RatingResponse, _$RatingResponse];

  @override
  final String wireName = r'RatingResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RatingResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'comment';
    yield object.comment == null ? null : serializers.serialize(
      object.comment,
      specifiedType: const FullType.nullable(String),
    );
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
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'rated_user_id';
    yield serializers.serialize(
      object.ratedUserId,
      specifiedType: const FullType(String),
    );
    yield r'rater_id';
    yield serializers.serialize(
      object.raterId,
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
    RatingResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RatingResponseBuilder result,
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
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'rated_user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ratedUserId = valueDes;
          break;
        case r'rater_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.raterId = valueDes;
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
  RatingResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RatingResponseBuilder();
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

