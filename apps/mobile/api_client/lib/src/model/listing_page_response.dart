//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:campus_api/src/model/listing_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'listing_page_response.g.dart';

/// ListingPageResponse
///
/// Properties:
/// * [items] 
/// * [nextCursor] 
@BuiltValue()
abstract class ListingPageResponse implements Built<ListingPageResponse, ListingPageResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<ListingResponse> get items;

  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  ListingPageResponse._();

  factory ListingPageResponse([void updates(ListingPageResponseBuilder b)]) = _$ListingPageResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListingPageResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListingPageResponse> get serializer => _$ListingPageResponseSerializer();
}

class _$ListingPageResponseSerializer implements PrimitiveSerializer<ListingPageResponse> {
  @override
  final Iterable<Type> types = const [ListingPageResponse, _$ListingPageResponse];

  @override
  final String wireName = r'ListingPageResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListingPageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(ListingResponse)]),
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
    ListingPageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ListingPageResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ListingResponse)]),
          ) as BuiltList<ListingResponse>;
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
  ListingPageResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListingPageResponseBuilder();
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

