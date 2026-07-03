//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:campus_api/src/model/ranked_tutor_response.dart';
import 'package:campus_api/src/model/course_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tutor_search_response.g.dart';

/// TutorSearchResponse
///
/// Properties:
/// * [course] 
/// * [items] 
@BuiltValue()
abstract class TutorSearchResponse implements Built<TutorSearchResponse, TutorSearchResponseBuilder> {
  @BuiltValueField(wireName: r'course')
  CourseResponse get course;

  @BuiltValueField(wireName: r'items')
  BuiltList<RankedTutorResponse> get items;

  TutorSearchResponse._();

  factory TutorSearchResponse([void updates(TutorSearchResponseBuilder b)]) = _$TutorSearchResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TutorSearchResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TutorSearchResponse> get serializer => _$TutorSearchResponseSerializer();
}

class _$TutorSearchResponseSerializer implements PrimitiveSerializer<TutorSearchResponse> {
  @override
  final Iterable<Type> types = const [TutorSearchResponse, _$TutorSearchResponse];

  @override
  final String wireName = r'TutorSearchResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TutorSearchResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'course';
    yield serializers.serialize(
      object.course,
      specifiedType: const FullType(CourseResponse),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(RankedTutorResponse)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TutorSearchResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TutorSearchResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'course':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CourseResponse),
          ) as CourseResponse;
          result.course.replace(valueDes);
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(RankedTutorResponse)]),
          ) as BuiltList<RankedTutorResponse>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TutorSearchResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TutorSearchResponseBuilder();
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

