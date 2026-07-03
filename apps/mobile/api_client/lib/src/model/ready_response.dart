//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ready_response.g.dart';

/// ReadyResponse
///
/// Properties:
/// * [database] 
/// * [redis] 
/// * [status] 
@BuiltValue()
abstract class ReadyResponse implements Built<ReadyResponse, ReadyResponseBuilder> {
  @BuiltValueField(wireName: r'database')
  bool get database;

  @BuiltValueField(wireName: r'redis')
  bool get redis;

  @BuiltValueField(wireName: r'status')
  ReadyResponseStatusEnum get status;
  // enum statusEnum {  ok,  degraded,  };

  ReadyResponse._();

  factory ReadyResponse([void updates(ReadyResponseBuilder b)]) = _$ReadyResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReadyResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReadyResponse> get serializer => _$ReadyResponseSerializer();
}

class _$ReadyResponseSerializer implements PrimitiveSerializer<ReadyResponse> {
  @override
  final Iterable<Type> types = const [ReadyResponse, _$ReadyResponse];

  @override
  final String wireName = r'ReadyResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReadyResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'database';
    yield serializers.serialize(
      object.database,
      specifiedType: const FullType(bool),
    );
    yield r'redis';
    yield serializers.serialize(
      object.redis,
      specifiedType: const FullType(bool),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ReadyResponseStatusEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReadyResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReadyResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'database':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.database = valueDes;
          break;
        case r'redis':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.redis = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReadyResponseStatusEnum),
          ) as ReadyResponseStatusEnum;
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
  ReadyResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReadyResponseBuilder();
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

class ReadyResponseStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ok')
  static const ReadyResponseStatusEnum ok = _$readyResponseStatusEnum_ok;
  @BuiltValueEnumConst(wireName: r'degraded')
  static const ReadyResponseStatusEnum degraded = _$readyResponseStatusEnum_degraded;

  static Serializer<ReadyResponseStatusEnum> get serializer => _$readyResponseStatusEnumSerializer;

  const ReadyResponseStatusEnum._(String name): super(name);

  static BuiltSet<ReadyResponseStatusEnum> get values => _$readyResponseStatusEnumValues;
  static ReadyResponseStatusEnum valueOf(String name) => _$readyResponseStatusEnumValueOf(name);
}

