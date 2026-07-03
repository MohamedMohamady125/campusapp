//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:campus_api/src/model/report_target_type.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'report_create_request.g.dart';

/// ReportCreateRequest
///
/// Properties:
/// * [reason] 
/// * [targetId] 
/// * [targetType] 
@BuiltValue()
abstract class ReportCreateRequest implements Built<ReportCreateRequest, ReportCreateRequestBuilder> {
  @BuiltValueField(wireName: r'reason')
  String get reason;

  @BuiltValueField(wireName: r'target_id')
  String get targetId;

  @BuiltValueField(wireName: r'target_type')
  ReportTargetType get targetType;
  // enum targetTypeEnum {  listing,  message,  chat_message,  user,  };

  ReportCreateRequest._();

  factory ReportCreateRequest([void updates(ReportCreateRequestBuilder b)]) = _$ReportCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReportCreateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReportCreateRequest> get serializer => _$ReportCreateRequestSerializer();
}

class _$ReportCreateRequestSerializer implements PrimitiveSerializer<ReportCreateRequest> {
  @override
  final Iterable<Type> types = const [ReportCreateRequest, _$ReportCreateRequest];

  @override
  final String wireName = r'ReportCreateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReportCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
    yield r'target_id';
    yield serializers.serialize(
      object.targetId,
      specifiedType: const FullType(String),
    );
    yield r'target_type';
    yield serializers.serialize(
      object.targetType,
      specifiedType: const FullType(ReportTargetType),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReportCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReportCreateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        case r'target_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.targetId = valueDes;
          break;
        case r'target_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReportTargetType),
          ) as ReportTargetType;
          result.targetType = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReportCreateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReportCreateRequestBuilder();
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

