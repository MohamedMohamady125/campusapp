//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'run_create_request.g.dart';

/// RunCreateRequest
///
/// Properties:
/// * [feeCents] 
/// * [foodSpotId] 
/// * [leavingAt] 
/// * [note] 
/// * [prepayRequired] 
/// * [spotsMax] 
@BuiltValue()
abstract class RunCreateRequest implements Built<RunCreateRequest, RunCreateRequestBuilder> {
  @BuiltValueField(wireName: r'fee_cents')
  int? get feeCents;

  @BuiltValueField(wireName: r'food_spot_id')
  String get foodSpotId;

  @BuiltValueField(wireName: r'leaving_at')
  DateTime get leavingAt;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'prepay_required')
  bool? get prepayRequired;

  @BuiltValueField(wireName: r'spots_max')
  int? get spotsMax;

  RunCreateRequest._();

  factory RunCreateRequest([void updates(RunCreateRequestBuilder b)]) = _$RunCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RunCreateRequestBuilder b) => b
      ..feeCents = 0
      ..prepayRequired = false
      ..spotsMax = 3;

  @BuiltValueSerializer(custom: true)
  static Serializer<RunCreateRequest> get serializer => _$RunCreateRequestSerializer();
}

class _$RunCreateRequestSerializer implements PrimitiveSerializer<RunCreateRequest> {
  @override
  final Iterable<Type> types = const [RunCreateRequest, _$RunCreateRequest];

  @override
  final String wireName = r'RunCreateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RunCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.feeCents != null) {
      yield r'fee_cents';
      yield serializers.serialize(
        object.feeCents,
        specifiedType: const FullType(int),
      );
    }
    yield r'food_spot_id';
    yield serializers.serialize(
      object.foodSpotId,
      specifiedType: const FullType(String),
    );
    yield r'leaving_at';
    yield serializers.serialize(
      object.leavingAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.prepayRequired != null) {
      yield r'prepay_required';
      yield serializers.serialize(
        object.prepayRequired,
        specifiedType: const FullType(bool),
      );
    }
    if (object.spotsMax != null) {
      yield r'spots_max';
      yield serializers.serialize(
        object.spotsMax,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RunCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RunCreateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'fee_cents':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.feeCents = valueDes;
          break;
        case r'food_spot_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.foodSpotId = valueDes;
          break;
        case r'leaving_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.leavingAt = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'prepay_required':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.prepayRequired = valueDes;
          break;
        case r'spots_max':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.spotsMax = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RunCreateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RunCreateRequestBuilder();
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

