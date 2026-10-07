//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'run_chat_context.g.dart';

/// Order + restaurant summary pinned atop a run chat (both parties).
///
/// Properties:
/// * [dropoff] 
/// * [feeCents] 
/// * [orderId] 
/// * [orderText] 
/// * [runId] 
/// * [spotImageUrl] 
/// * [spotName] 
@BuiltValue()
abstract class RunChatContext implements Built<RunChatContext, RunChatContextBuilder> {
  @BuiltValueField(wireName: r'dropoff')
  String get dropoff;

  @BuiltValueField(wireName: r'fee_cents')
  int get feeCents;

  @BuiltValueField(wireName: r'order_id')
  String get orderId;

  @BuiltValueField(wireName: r'order_text')
  String get orderText;

  @BuiltValueField(wireName: r'run_id')
  String get runId;

  @BuiltValueField(wireName: r'spot_image_url')
  String? get spotImageUrl;

  @BuiltValueField(wireName: r'spot_name')
  String get spotName;

  RunChatContext._();

  factory RunChatContext([void updates(RunChatContextBuilder b)]) = _$RunChatContext;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RunChatContextBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RunChatContext> get serializer => _$RunChatContextSerializer();
}

class _$RunChatContextSerializer implements PrimitiveSerializer<RunChatContext> {
  @override
  final Iterable<Type> types = const [RunChatContext, _$RunChatContext];

  @override
  final String wireName = r'RunChatContext';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RunChatContext object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'dropoff';
    yield serializers.serialize(
      object.dropoff,
      specifiedType: const FullType(String),
    );
    yield r'fee_cents';
    yield serializers.serialize(
      object.feeCents,
      specifiedType: const FullType(int),
    );
    yield r'order_id';
    yield serializers.serialize(
      object.orderId,
      specifiedType: const FullType(String),
    );
    yield r'order_text';
    yield serializers.serialize(
      object.orderText,
      specifiedType: const FullType(String),
    );
    yield r'run_id';
    yield serializers.serialize(
      object.runId,
      specifiedType: const FullType(String),
    );
    yield r'spot_image_url';
    yield object.spotImageUrl == null ? null : serializers.serialize(
      object.spotImageUrl,
      specifiedType: const FullType.nullable(String),
    );
    yield r'spot_name';
    yield serializers.serialize(
      object.spotName,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RunChatContext object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RunChatContextBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'dropoff':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.dropoff = valueDes;
          break;
        case r'fee_cents':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.feeCents = valueDes;
          break;
        case r'order_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.orderId = valueDes;
          break;
        case r'order_text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.orderText = valueDes;
          break;
        case r'run_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.runId = valueDes;
          break;
        case r'spot_image_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.spotImageUrl = valueDes;
          break;
        case r'spot_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.spotName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RunChatContext deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RunChatContextBuilder();
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

