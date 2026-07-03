// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_role.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UserRole _$student = const UserRole._('student');
const UserRole _$moderator = const UserRole._('moderator');
const UserRole _$admin = const UserRole._('admin');

UserRole _$valueOf(String name) {
  switch (name) {
    case 'student':
      return _$student;
    case 'moderator':
      return _$moderator;
    case 'admin':
      return _$admin;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<UserRole> _$values = BuiltSet<UserRole>(const <UserRole>[
  _$student,
  _$moderator,
  _$admin,
]);

class _$UserRoleMeta {
  const _$UserRoleMeta();
  UserRole get student => _$student;
  UserRole get moderator => _$moderator;
  UserRole get admin => _$admin;
  UserRole valueOf(String name) => _$valueOf(name);
  BuiltSet<UserRole> get values => _$values;
}

abstract class _$UserRoleMixin {
  // ignore: non_constant_identifier_names
  _$UserRoleMeta get UserRole => const _$UserRoleMeta();
}

Serializer<UserRole> _$userRoleSerializer = _$UserRoleSerializer();

class _$UserRoleSerializer implements PrimitiveSerializer<UserRole> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'student': 'student',
    'moderator': 'moderator',
    'admin': 'admin',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'student': 'student',
    'moderator': 'moderator',
    'admin': 'admin',
  };

  @override
  final Iterable<Type> types = const <Type>[UserRole];
  @override
  final String wireName = 'UserRole';

  @override
  Object serialize(Serializers serializers, UserRole object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  UserRole deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      UserRole.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
