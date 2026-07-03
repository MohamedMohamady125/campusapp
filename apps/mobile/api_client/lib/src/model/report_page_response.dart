//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:campus_api/src/model/report_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'report_page_response.g.dart';

/// ReportPageResponse
///
/// Properties:
/// * [items] 
/// * [nextCursor] 
@BuiltValue()
abstract class ReportPageResponse implements Built<ReportPageResponse, ReportPageResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<ReportResponse> get items;

  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  ReportPageResponse._();

  factory ReportPageResponse([void updates(ReportPageResponseBuilder b)]) = _$ReportPageResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReportPageResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReportPageResponse> get serializer => _$ReportPageResponseSerializer();
}

class _$ReportPageResponseSerializer implements PrimitiveSerializer<ReportPageResponse> {
  @override
  final Iterable<Type> types = const [ReportPageResponse, _$ReportPageResponse];

  @override
  final String wireName = r'ReportPageResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReportPageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(ReportResponse)]),
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
    ReportPageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReportPageResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ReportResponse)]),
          ) as BuiltList<ReportResponse>;
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
  ReportPageResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReportPageResponseBuilder();
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

