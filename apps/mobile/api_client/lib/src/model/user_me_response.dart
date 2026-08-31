//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:campus_api/src/model/user_role.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_me_response.g.dart';

/// UserMeResponse
///
/// Properties:
/// * [avatarKey] 
/// * [bio] 
/// * [createdAt] 
/// * [displayName] 
/// * [email] 
/// * [id] 
/// * [major] 
/// * [ratingCount] 
/// * [reputationScore] 
/// * [role] 
/// * [venmoHandle] 
/// * [year] 
@BuiltValue()
abstract class UserMeResponse implements Built<UserMeResponse, UserMeResponseBuilder> {
  @BuiltValueField(wireName: r'avatar_key')
  String? get avatarKey;

  @BuiltValueField(wireName: r'bio')
  String? get bio;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'display_name')
  String get displayName;

  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'major')
  String? get major;

  @BuiltValueField(wireName: r'rating_count')
  int get ratingCount;

  @BuiltValueField(wireName: r'reputation_score')
  num get reputationScore;

  @BuiltValueField(wireName: r'role')
  UserRole get role;
  // enum roleEnum {  student,  moderator,  admin,  };

  @BuiltValueField(wireName: r'venmo_handle')
  String? get venmoHandle;

  @BuiltValueField(wireName: r'year')
  String? get year;

  UserMeResponse._();

  factory UserMeResponse([void updates(UserMeResponseBuilder b)]) = _$UserMeResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserMeResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserMeResponse> get serializer => _$UserMeResponseSerializer();
}

class _$UserMeResponseSerializer implements PrimitiveSerializer<UserMeResponse> {
  @override
  final Iterable<Type> types = const [UserMeResponse, _$UserMeResponse];

  @override
  final String wireName = r'UserMeResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserMeResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'avatar_key';
    yield object.avatarKey == null ? null : serializers.serialize(
      object.avatarKey,
      specifiedType: const FullType.nullable(String),
    );
    yield r'bio';
    yield object.bio == null ? null : serializers.serialize(
      object.bio,
      specifiedType: const FullType.nullable(String),
    );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'display_name';
    yield serializers.serialize(
      object.displayName,
      specifiedType: const FullType(String),
    );
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'major';
    yield object.major == null ? null : serializers.serialize(
      object.major,
      specifiedType: const FullType.nullable(String),
    );
    yield r'rating_count';
    yield serializers.serialize(
      object.ratingCount,
      specifiedType: const FullType(int),
    );
    yield r'reputation_score';
    yield serializers.serialize(
      object.reputationScore,
      specifiedType: const FullType(num),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(UserRole),
    );
    yield r'venmo_handle';
    yield object.venmoHandle == null ? null : serializers.serialize(
      object.venmoHandle,
      specifiedType: const FullType.nullable(String),
    );
    yield r'year';
    yield object.year == null ? null : serializers.serialize(
      object.year,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UserMeResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserMeResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'avatar_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.avatarKey = valueDes;
          break;
        case r'bio':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.bio = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'display_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'major':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.major = valueDes;
          break;
        case r'rating_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.ratingCount = valueDes;
          break;
        case r'reputation_score':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.reputationScore = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UserRole),
          ) as UserRole;
          result.role = valueDes;
          break;
        case r'venmo_handle':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.venmoHandle = valueDes;
          break;
        case r'year':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.year = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserMeResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserMeResponseBuilder();
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

