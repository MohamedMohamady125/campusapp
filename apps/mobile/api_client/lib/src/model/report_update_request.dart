//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:campus_api/src/model/report_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'report_update_request.g.dart';

/// ReportUpdateRequest
///
/// Properties:
/// * [status] 
@BuiltValue()
abstract class ReportUpdateRequest implements Built<ReportUpdateRequest, ReportUpdateRequestBuilder> {
  @BuiltValueField(wireName: r'status')
  ReportStatus get status;
  // enum statusEnum {  open,  reviewing,  actioned,  dismissed,  };

  ReportUpdateRequest._();

  factory ReportUpdateRequest([void updates(ReportUpdateRequestBuilder b)]) = _$ReportUpdateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReportUpdateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReportUpdateRequest> get serializer => _$ReportUpdateRequestSerializer();
}

class _$ReportUpdateRequestSerializer implements PrimitiveSerializer<ReportUpdateRequest> {
  @override
  final Iterable<Type> types = const [ReportUpdateRequest, _$ReportUpdateRequest];

  @override
  final String wireName = r'ReportUpdateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReportUpdateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ReportStatus),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReportUpdateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReportUpdateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReportStatus),
          ) as ReportStatus;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReportUpdateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReportUpdateRequestBuilder();
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

