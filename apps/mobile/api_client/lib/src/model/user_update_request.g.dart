// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_update_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserUpdateRequest extends UserUpdateRequest {
  @override
  final String? bio;
  @override
  final String? displayName;
  @override
  final String? major;
  @override
  final String? venmoHandle;
  @override
  final String? year;

  factory _$UserUpdateRequest(
          [void Function(UserUpdateRequestBuilder)? updates]) =>
      (UserUpdateRequestBuilder()..update(updates))._build();

  _$UserUpdateRequest._(
      {this.bio, this.displayName, this.major, this.venmoHandle, this.year})
      : super._();
  @override
  UserUpdateRequest rebuild(void Function(UserUpdateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserUpdateRequestBuilder toBuilder() =>
      UserUpdateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserUpdateRequest &&
        bio == other.bio &&
        displayName == other.displayName &&
        major == other.major &&
        venmoHandle == other.venmoHandle &&
        year == other.year;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, bio.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, major.hashCode);
    _$hash = $jc(_$hash, venmoHandle.hashCode);
    _$hash = $jc(_$hash, year.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserUpdateRequest')
          ..add('bio', bio)
          ..add('displayName', displayName)
          ..add('major', major)
          ..add('venmoHandle', venmoHandle)
          ..add('year', year))
        .toString();
  }
}

class UserUpdateRequestBuilder
    implements Builder<UserUpdateRequest, UserUpdateRequestBuilder> {
  _$UserUpdateRequest? _$v;

  String? _bio;
  String? get bio => _$this._bio;
  set bio(String? bio) => _$this._bio = bio;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _major;
  String? get major => _$this._major;
  set major(String? major) => _$this._major = major;

  String? _venmoHandle;
  String? get venmoHandle => _$this._venmoHandle;
  set venmoHandle(String? venmoHandle) => _$this._venmoHandle = venmoHandle;

  String? _year;
  String? get year => _$this._year;
  set year(String? year) => _$this._year = year;

  UserUpdateRequestBuilder() {
    UserUpdateRequest._defaults(this);
  }

  UserUpdateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _bio = $v.bio;
      _displayName = $v.displayName;
      _major = $v.major;
      _venmoHandle = $v.venmoHandle;
      _year = $v.year;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserUpdateRequest other) {
    _$v = other as _$UserUpdateRequest;
  }

  @override
  void update(void Function(UserUpdateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserUpdateRequest build() => _build();

  _$UserUpdateRequest _build() {
    final _$result = _$v ??
        _$UserUpdateRequest._(
          bio: bio,
          displayName: displayName,
          major: major,
          venmoHandle: venmoHandle,
          year: year,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
