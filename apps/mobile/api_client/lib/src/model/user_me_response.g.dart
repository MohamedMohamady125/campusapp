// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_me_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserMeResponse extends UserMeResponse {
  @override
  final String? avatarKey;
  @override
  final String? bio;
  @override
  final DateTime createdAt;
  @override
  final String displayName;
  @override
  final String email;
  @override
  final String id;
  @override
  final String? major;
  @override
  final BuiltList<PaymentMethod> paymentMethods;
  @override
  final int ratingCount;
  @override
  final num reputationScore;
  @override
  final UserRole role;
  @override
  final String? year;

  factory _$UserMeResponse([void Function(UserMeResponseBuilder)? updates]) =>
      (UserMeResponseBuilder()..update(updates))._build();

  _$UserMeResponse._(
      {this.avatarKey,
      this.bio,
      required this.createdAt,
      required this.displayName,
      required this.email,
      required this.id,
      this.major,
      required this.paymentMethods,
      required this.ratingCount,
      required this.reputationScore,
      required this.role,
      this.year})
      : super._();
  @override
  UserMeResponse rebuild(void Function(UserMeResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserMeResponseBuilder toBuilder() => UserMeResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserMeResponse &&
        avatarKey == other.avatarKey &&
        bio == other.bio &&
        createdAt == other.createdAt &&
        displayName == other.displayName &&
        email == other.email &&
        id == other.id &&
        major == other.major &&
        paymentMethods == other.paymentMethods &&
        ratingCount == other.ratingCount &&
        reputationScore == other.reputationScore &&
        role == other.role &&
        year == other.year;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, avatarKey.hashCode);
    _$hash = $jc(_$hash, bio.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, major.hashCode);
    _$hash = $jc(_$hash, paymentMethods.hashCode);
    _$hash = $jc(_$hash, ratingCount.hashCode);
    _$hash = $jc(_$hash, reputationScore.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, year.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserMeResponse')
          ..add('avatarKey', avatarKey)
          ..add('bio', bio)
          ..add('createdAt', createdAt)
          ..add('displayName', displayName)
          ..add('email', email)
          ..add('id', id)
          ..add('major', major)
          ..add('paymentMethods', paymentMethods)
          ..add('ratingCount', ratingCount)
          ..add('reputationScore', reputationScore)
          ..add('role', role)
          ..add('year', year))
        .toString();
  }
}

class UserMeResponseBuilder
    implements Builder<UserMeResponse, UserMeResponseBuilder> {
  _$UserMeResponse? _$v;

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

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _major;
  String? get major => _$this._major;
  set major(String? major) => _$this._major = major;

  ListBuilder<PaymentMethod>? _paymentMethods;
  ListBuilder<PaymentMethod> get paymentMethods =>
      _$this._paymentMethods ??= ListBuilder<PaymentMethod>();
  set paymentMethods(ListBuilder<PaymentMethod>? paymentMethods) =>
      _$this._paymentMethods = paymentMethods;

  int? _ratingCount;
  int? get ratingCount => _$this._ratingCount;
  set ratingCount(int? ratingCount) => _$this._ratingCount = ratingCount;

  num? _reputationScore;
  num? get reputationScore => _$this._reputationScore;
  set reputationScore(num? reputationScore) =>
      _$this._reputationScore = reputationScore;

  UserRole? _role;
  UserRole? get role => _$this._role;
  set role(UserRole? role) => _$this._role = role;

  String? _year;
  String? get year => _$this._year;
  set year(String? year) => _$this._year = year;

  UserMeResponseBuilder() {
    UserMeResponse._defaults(this);
  }

  UserMeResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _avatarKey = $v.avatarKey;
      _bio = $v.bio;
      _createdAt = $v.createdAt;
      _displayName = $v.displayName;
      _email = $v.email;
      _id = $v.id;
      _major = $v.major;
      _paymentMethods = $v.paymentMethods.toBuilder();
      _ratingCount = $v.ratingCount;
      _reputationScore = $v.reputationScore;
      _role = $v.role;
      _year = $v.year;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserMeResponse other) {
    _$v = other as _$UserMeResponse;
  }

  @override
  void update(void Function(UserMeResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserMeResponse build() => _build();

  _$UserMeResponse _build() {
    _$UserMeResponse _$result;
    try {
      _$result = _$v ??
          _$UserMeResponse._(
            avatarKey: avatarKey,
            bio: bio,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'UserMeResponse', 'createdAt'),
            displayName: BuiltValueNullFieldError.checkNotNull(
                displayName, r'UserMeResponse', 'displayName'),
            email: BuiltValueNullFieldError.checkNotNull(
                email, r'UserMeResponse', 'email'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'UserMeResponse', 'id'),
            major: major,
            paymentMethods: paymentMethods.build(),
            ratingCount: BuiltValueNullFieldError.checkNotNull(
                ratingCount, r'UserMeResponse', 'ratingCount'),
            reputationScore: BuiltValueNullFieldError.checkNotNull(
                reputationScore, r'UserMeResponse', 'reputationScore'),
            role: BuiltValueNullFieldError.checkNotNull(
                role, r'UserMeResponse', 'role'),
            year: year,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'paymentMethods';
        paymentMethods.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'UserMeResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
