// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_public_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserPublicResponse extends UserPublicResponse {
  @override
  final String? avatarKey;
  @override
  final String? bio;
  @override
  final DateTime createdAt;
  @override
  final String displayName;
  @override
  final String id;
  @override
  final String? major;
  @override
  final int ratingCount;
  @override
  final num reputationScore;
  @override
  final String? year;

  factory _$UserPublicResponse(
          [void Function(UserPublicResponseBuilder)? updates]) =>
      (UserPublicResponseBuilder()..update(updates))._build();

  _$UserPublicResponse._(
      {this.avatarKey,
      this.bio,
      required this.createdAt,
      required this.displayName,
      required this.id,
      this.major,
      required this.ratingCount,
      required this.reputationScore,
      this.year})
      : super._();
  @override
  UserPublicResponse rebuild(
          void Function(UserPublicResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserPublicResponseBuilder toBuilder() =>
      UserPublicResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserPublicResponse &&
        avatarKey == other.avatarKey &&
        bio == other.bio &&
        createdAt == other.createdAt &&
        displayName == other.displayName &&
        id == other.id &&
        major == other.major &&
        ratingCount == other.ratingCount &&
        reputationScore == other.reputationScore &&
        year == other.year;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, avatarKey.hashCode);
    _$hash = $jc(_$hash, bio.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, major.hashCode);
    _$hash = $jc(_$hash, ratingCount.hashCode);
    _$hash = $jc(_$hash, reputationScore.hashCode);
    _$hash = $jc(_$hash, year.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserPublicResponse')
          ..add('avatarKey', avatarKey)
          ..add('bio', bio)
          ..add('createdAt', createdAt)
          ..add('displayName', displayName)
          ..add('id', id)
          ..add('major', major)
          ..add('ratingCount', ratingCount)
          ..add('reputationScore', reputationScore)
          ..add('year', year))
        .toString();
  }
}

class UserPublicResponseBuilder
    implements Builder<UserPublicResponse, UserPublicResponseBuilder> {
  _$UserPublicResponse? _$v;

  String? _avatarKey;
  String? get avatarKey => _$this._avatarKey;
  set avatarKey(String? avatarKey) => _$this._avatarKey = avatarKey;

  String? _bio;
  String? get bio => _$this._bio;
  set bio(String? bio) => _$this._bio = bio;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _major;
  String? get major => _$this._major;
  set major(String? major) => _$this._major = major;

  int? _ratingCount;
  int? get ratingCount => _$this._ratingCount;
  set ratingCount(int? ratingCount) => _$this._ratingCount = ratingCount;

  num? _reputationScore;
  num? get reputationScore => _$this._reputationScore;
  set reputationScore(num? reputationScore) =>
      _$this._reputationScore = reputationScore;

  String? _year;
  String? get year => _$this._year;
  set year(String? year) => _$this._year = year;

  UserPublicResponseBuilder() {
    UserPublicResponse._defaults(this);
  }

  UserPublicResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _avatarKey = $v.avatarKey;
      _bio = $v.bio;
      _createdAt = $v.createdAt;
      _displayName = $v.displayName;
      _id = $v.id;
      _major = $v.major;
      _ratingCount = $v.ratingCount;
      _reputationScore = $v.reputationScore;
      _year = $v.year;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserPublicResponse other) {
    _$v = other as _$UserPublicResponse;
  }

  @override
  void update(void Function(UserPublicResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserPublicResponse build() => _build();

  _$UserPublicResponse _build() {
    final _$result = _$v ??
        _$UserPublicResponse._(
          avatarKey: avatarKey,
          bio: bio,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'UserPublicResponse', 'createdAt'),
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName, r'UserPublicResponse', 'displayName'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'UserPublicResponse', 'id'),
          major: major,
          ratingCount: BuiltValueNullFieldError.checkNotNull(
              ratingCount, r'UserPublicResponse', 'ratingCount'),
          reputationScore: BuiltValueNullFieldError.checkNotNull(
              reputationScore, r'UserPublicResponse', 'reputationScore'),
          year: year,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
