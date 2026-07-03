//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:campus_api/src/model/rating_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'rating_page_response.g.dart';

/// RatingPageResponse
///
/// Properties:
/// * [items] 
/// * [nextCursor] 
@BuiltValue()
abstract class RatingPageResponse implements Built<RatingPageResponse, RatingPageResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<RatingResponse> get items;

  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  RatingPageResponse._();

  factory RatingPageResponse([void updates(RatingPageResponseBuilder b)]) = _$RatingPageResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RatingPageResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RatingPageResponse> get serializer => _$RatingPageResponseSerializer();
}

class _$RatingPageResponseSerializer implements PrimitiveSerializer<RatingPageResponse> {
  @override
  final Iterable<Type> types = const [RatingPageResponse, _$RatingPageResponse];

  @override
  final String wireName = r'RatingPageResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RatingPageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(RatingResponse)]),
    );
    yield r'next_cursor';
    yield object.nextCursor == null ? null : serializers.serialize(
      object.nextCursor,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RatingPageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RatingPageResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(RatingResponse)]),
          ) as BuiltList<RatingResponse>;
          result.items.replace(valueDes);
          break;
        case r'next_cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nextCursor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RatingPageResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RatingPageResponseBuilder();
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

