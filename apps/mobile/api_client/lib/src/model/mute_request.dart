//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'mute_request.g.dart';

/// MuteRequest
///
/// Properties:
/// * [minutes] 
@BuiltValue()
abstract class MuteRequest implements Built<MuteRequest, MuteRequestBuilder> {
  @BuiltValueField(wireName: r'minutes')
  int? get minutes;

  MuteRequest._();

  factory MuteRequest([void updates(MuteRequestBuilder b)]) = _$MuteRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MuteRequestBuilder b) => b
      ..minutes = 60;

  @BuiltValueSerializer(custom: true)
  static Serializer<MuteRequest> get serializer => _$MuteRequestSerializer();
}

class _$MuteRequestSerializer implements PrimitiveSerializer<MuteRequest> {
  @override
  final Iterable<Type> types = const [MuteRequest, _$MuteRequest];

  @override
  final String wireName = r'MuteRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MuteRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.minutes != null) {
      yield r'minutes';
      yield serializers.serialize(
        object.minutes,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MuteRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MuteRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.minutes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MuteRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MuteRequestBuilder();
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

