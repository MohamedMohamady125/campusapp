//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'offering_create_request.g.dart';

/// OfferingCreateRequest
///
/// Properties:
/// * [blurb] 
/// * [courseId] 
/// * [gradeReceived] 
/// * [termTaken] 
@BuiltValue()
abstract class OfferingCreateRequest implements Built<OfferingCreateRequest, OfferingCreateRequestBuilder> {
  @BuiltValueField(wireName: r'blurb')
  String? get blurb;

  @BuiltValueField(wireName: r'course_id')
  String get courseId;

  @BuiltValueField(wireName: r'grade_received')
  OfferingCreateRequestGradeReceivedEnum get gradeReceived;
  // enum gradeReceivedEnum {  A+,  A,  A-,  B+,  B,  B-,  };

  @BuiltValueField(wireName: r'term_taken')
  String get termTaken;

  OfferingCreateRequest._();

  factory OfferingCreateRequest([void updates(OfferingCreateRequestBuilder b)]) = _$OfferingCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OfferingCreateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OfferingCreateRequest> get serializer => _$OfferingCreateRequestSerializer();
}

class _$OfferingCreateRequestSerializer implements PrimitiveSerializer<OfferingCreateRequest> {
  @override
  final Iterable<Type> types = const [OfferingCreateRequest, _$OfferingCreateRequest];

  @override
  final String wireName = r'OfferingCreateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OfferingCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.blurb != null) {
      yield r'blurb';
      yield serializers.serialize(
        object.blurb,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'course_id';
    yield serializers.serialize(
      object.courseId,
      specifiedType: const FullType(String),
    );
    yield r'grade_received';
    yield serializers.serialize(
      object.gradeReceived,
      specifiedType: const FullType(OfferingCreateRequestGradeReceivedEnum),
    );
    yield r'term_taken';
    yield serializers.serialize(
      object.termTaken,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OfferingCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OfferingCreateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'blurb':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.blurb = valueDes;
          break;
        case r'course_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.courseId = valueDes;
          break;
        case r'grade_received':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OfferingCreateRequestGradeReceivedEnum),
          ) as OfferingCreateRequestGradeReceivedEnum;
          result.gradeReceived = valueDes;
          break;
        case r'term_taken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.termTaken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OfferingCreateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OfferingCreateRequestBuilder();
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

class OfferingCreateRequestGradeReceivedEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'A+')
  static const OfferingCreateRequestGradeReceivedEnum aPlus = _$offeringCreateRequestGradeReceivedEnum_aPlus;
  @BuiltValueEnumConst(wireName: r'A')
  static const OfferingCreateRequestGradeReceivedEnum A = _$offeringCreateRequestGradeReceivedEnum_A;
  @BuiltValueEnumConst(wireName: r'A-')
  static const OfferingCreateRequestGradeReceivedEnum A_ = _$offeringCreateRequestGradeReceivedEnum_A_;
  @BuiltValueEnumConst(wireName: r'B+')
  static const OfferingCreateRequestGradeReceivedEnum bPlus = _$offeringCreateRequestGradeReceivedEnum_bPlus;
  @BuiltValueEnumConst(wireName: r'B')
  static const OfferingCreateRequestGradeReceivedEnum B = _$offeringCreateRequestGradeReceivedEnum_B;
  @BuiltValueEnumConst(wireName: r'B-')
  static const OfferingCreateRequestGradeReceivedEnum B_ = _$offeringCreateRequestGradeReceivedEnum_B_;

  static Serializer<OfferingCreateRequestGradeReceivedEnum> get serializer => _$offeringCreateRequestGradeReceivedEnumSerializer;

  const OfferingCreateRequestGradeReceivedEnum._(String name): super(name);

  static BuiltSet<OfferingCreateRequestGradeReceivedEnum> get values => _$offeringCreateRequestGradeReceivedEnumValues;
  static OfferingCreateRequestGradeReceivedEnum valueOf(String name) => _$offeringCreateRequestGradeReceivedEnumValueOf(name);
}

