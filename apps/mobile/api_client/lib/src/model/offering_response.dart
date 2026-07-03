//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:campus_api/src/model/course_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'offering_response.g.dart';

/// OfferingResponse
///
/// Properties:
/// * [active] 
/// * [blurb] 
/// * [course] 
/// * [createdAt] 
/// * [gradeReceived] 
/// * [id] 
/// * [termTaken] 
/// * [tutorId] 
@BuiltValue()
abstract class OfferingResponse implements Built<OfferingResponse, OfferingResponseBuilder> {
  @BuiltValueField(wireName: r'active')
  bool get active;

  @BuiltValueField(wireName: r'blurb')
  String? get blurb;

  @BuiltValueField(wireName: r'course')
  CourseResponse get course;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'grade_received')
  String get gradeReceived;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'term_taken')
  String get termTaken;

  @BuiltValueField(wireName: r'tutor_id')
  String get tutorId;

  OfferingResponse._();

  factory OfferingResponse([void updates(OfferingResponseBuilder b)]) = _$OfferingResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OfferingResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OfferingResponse> get serializer => _$OfferingResponseSerializer();
}

class _$OfferingResponseSerializer implements PrimitiveSerializer<OfferingResponse> {
  @override
  final Iterable<Type> types = const [OfferingResponse, _$OfferingResponse];

  @override
  final String wireName = r'OfferingResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OfferingResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'active';
    yield serializers.serialize(
      object.active,
      specifiedType: const FullType(bool),
    );
    yield r'blurb';
    yield object.blurb == null ? null : serializers.serialize(
      object.blurb,
      specifiedType: const FullType.nullable(String),
    );
    yield r'course';
    yield serializers.serialize(
      object.course,
      specifiedType: const FullType(CourseResponse),
    );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'grade_received';
    yield serializers.serialize(
      object.gradeReceived,
      specifiedType: const FullType(String),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'term_taken';
    yield serializers.serialize(
      object.termTaken,
      specifiedType: const FullType(String),
    );
    yield r'tutor_id';
    yield serializers.serialize(
      object.tutorId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OfferingResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OfferingResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'active':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.active = valueDes;
          break;
        case r'blurb':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.blurb = valueDes;
          break;
        case r'course':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CourseResponse),
          ) as CourseResponse;
          result.course.replace(valueDes);
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'grade_received':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.gradeReceived = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'term_taken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.termTaken = valueDes;
          break;
        case r'tutor_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tutorId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OfferingResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OfferingResponseBuilder();
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

