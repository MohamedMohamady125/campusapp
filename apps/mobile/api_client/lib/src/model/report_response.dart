//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:campus_api/src/model/report_target_type.dart';
import 'package:campus_api/src/model/report_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'report_response.g.dart';

/// ReportResponse
///
/// Properties:
/// * [createdAt] 
/// * [handledById] 
/// * [id] 
/// * [reason] 
/// * [reporterId] 
/// * [status] 
/// * [targetId] 
/// * [targetType] 
@BuiltValue()
abstract class ReportResponse implements Built<ReportResponse, ReportResponseBuilder> {
  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'handled_by_id')
  String? get handledById;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  @BuiltValueField(wireName: r'reporter_id')
  String get reporterId;

  @BuiltValueField(wireName: r'status')
  ReportStatus get status;
  // enum statusEnum {  open,  reviewing,  actioned,  dismissed,  };

  @BuiltValueField(wireName: r'target_id')
  String get targetId;

  @BuiltValueField(wireName: r'target_type')
  ReportTargetType get targetType;
  // enum targetTypeEnum {  listing,  message,  chat_message,  user,  };

  ReportResponse._();

  factory ReportResponse([void updates(ReportResponseBuilder b)]) = _$ReportResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReportResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReportResponse> get serializer => _$ReportResponseSerializer();
}

class _$ReportResponseSerializer implements PrimitiveSerializer<ReportResponse> {
  @override
  final Iterable<Type> types = const [ReportResponse, _$ReportResponse];

  @override
  final String wireName = r'ReportResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReportResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'handled_by_id';
    yield object.handledById == null ? null : serializers.serialize(
      object.handledById,
      specifiedType: const FullType.nullable(String),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
    yield r'reporter_id';
    yield serializers.serialize(
      object.reporterId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ReportStatus),
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
    ReportResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReportResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'handled_by_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.handledById = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        case r'reporter_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reporterId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReportStatus),
          ) as ReportStatus;
          result.status = valueDes;
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
  ReportResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReportResponseBuilder();
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

