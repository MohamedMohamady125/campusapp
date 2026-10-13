//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:campus_api/src/model/properties_value.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'client_event_in.g.dart';

/// A single client-side event (screen_view or a named action).
///
/// Properties:
/// * [durationMs] 
/// * [name] 
/// * [occurredAt] 
/// * [properties] 
/// * [screen] 
@BuiltValue()
abstract class ClientEventIn implements Built<ClientEventIn, ClientEventInBuilder> {
  @BuiltValueField(wireName: r'duration_ms')
  int? get durationMs;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'occurred_at')
  DateTime get occurredAt;

  @BuiltValueField(wireName: r'properties')
  BuiltMap<String, PropertiesValue?>? get properties;

  @BuiltValueField(wireName: r'screen')
  String? get screen;

  ClientEventIn._();

  factory ClientEventIn([void updates(ClientEventInBuilder b)]) = _$ClientEventIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ClientEventInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ClientEventIn> get serializer => _$ClientEventInSerializer();
}

class _$ClientEventInSerializer implements PrimitiveSerializer<ClientEventIn> {
  @override
  final Iterable<Type> types = const [ClientEventIn, _$ClientEventIn];

  @override
  final String wireName = r'ClientEventIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ClientEventIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.durationMs != null) {
      yield r'duration_ms';
      yield serializers.serialize(
        object.durationMs,
        specifiedType: const FullType.nullable(int),
      );
    }
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'occurred_at';
    yield serializers.serialize(
      object.occurredAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.properties != null) {
      yield r'properties';
      yield serializers.serialize(
        object.properties,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(PropertiesValue)]),
      );
    }
    if (object.screen != null) {
      yield r'screen';
      yield serializers.serialize(
        object.screen,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ClientEventIn object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ClientEventInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'duration_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.durationMs = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'occurred_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.occurredAt = valueDes;
          break;
        case r'properties':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(PropertiesValue)]),
          ) as BuiltMap<String, PropertiesValue?>?;
          if (valueDes == null) continue;
          result.properties.replace(valueDes);
          break;
        case r'screen':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.screen = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ClientEventIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ClientEventInBuilder();
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


