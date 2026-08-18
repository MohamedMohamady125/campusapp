//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ban_request.g.dart';

/// BanRequest
///
/// Properties:
/// * [reason] 
@BuiltValue()
abstract class BanRequest implements Built<BanRequest, BanRequestBuilder> {
  @BuiltValueField(wireName: r'reason')
  String? get reason;

  BanRequest._();

  factory BanRequest([void updates(BanRequestBuilder b)]) = _$BanRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BanRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BanRequest> get serializer => _$BanRequestSerializer();
}

class _$BanRequestSerializer implements PrimitiveSerializer<BanRequest> {
  @override
  final Iterable<Type> types = const [BanRequest, _$BanRequest];

  @override
  final String wireName = r'BanRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BanRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BanRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BanRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BanRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BanRequestBuilder();
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

