// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RatingResponse extends RatingResponse {
  @override
  final String? comment;
  @override
  final String contextId;
  @override
  final RatingContext contextType;
  @override
  final DateTime createdAt;
  @override
  final String id;
  @override
  final String ratedUserId;
  @override
  final String raterId;
  @override
  final int stars;

  factory _$RatingResponse([void Function(RatingResponseBuilder)? updates]) =>
      (RatingResponseBuilder()..update(updates))._build();

  _$RatingResponse._(
      {this.comment,
      required this.contextId,
      required this.contextType,
      required this.createdAt,
      required this.id,
      required this.ratedUserId,
      required this.raterId,
      required this.stars})
      : super._();
  @override
  RatingResponse rebuild(void Function(RatingResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RatingResponseBuilder toBuilder() => RatingResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RatingResponse &&
        comment == other.comment &&
        contextId == other.contextId &&
        contextType == other.contextType &&
        createdAt == other.createdAt &&
        id == other.id &&
        ratedUserId == other.ratedUserId &&
        raterId == other.raterId &&
        stars == other.stars;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, comment.hashCode);
    _$hash = $jc(_$hash, contextId.hashCode);
    _$hash = $jc(_$hash, contextType.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, ratedUserId.hashCode);
    _$hash = $jc(_$hash, raterId.hashCode);
    _$hash = $jc(_$hash, stars.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RatingResponse')
          ..add('comment', comment)
          ..add('contextId', contextId)
          ..add('contextType', contextType)
          ..add('createdAt', createdAt)
          ..add('id', id)
          ..add('ratedUserId', ratedUserId)
          ..add('raterId', raterId)
          ..add('stars', stars))
        .toString();
  }
}

class RatingResponseBuilder
    implements Builder<RatingResponse, RatingResponseBuilder> {
  _$RatingResponse? _$v;

  String? _comment;
  String? get comment => _$this._comment;
  set comment(String? comment) => _$this._comment = comment;

  String? _contextId;
  String? get contextId => _$this._contextId;
  set contextId(String? contextId) => _$this._contextId = contextId;

  RatingContext? _contextType;
  RatingContext? get contextType => _$this._contextType;
  set contextType(RatingContext? contextType) =>
      _$this._contextType = contextType;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _ratedUserId;
  String? get ratedUserId => _$this._ratedUserId;
  set ratedUserId(String? ratedUserId) => _$this._ratedUserId = ratedUserId;

  String? _raterId;
  String? get raterId => _$this._raterId;
  set raterId(String? raterId) => _$this._raterId = raterId;

  int? _stars;
  int? get stars => _$this._stars;
  set stars(int? stars) => _$this._stars = stars;

  RatingResponseBuilder() {
    RatingResponse._defaults(this);
  }

  RatingResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _comment = $v.comment;
      _contextId = $v.contextId;
      _contextType = $v.contextType;
      _createdAt = $v.createdAt;
      _id = $v.id;
      _ratedUserId = $v.ratedUserId;
      _raterId = $v.raterId;
      _stars = $v.stars;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RatingResponse other) {
    _$v = other as _$RatingResponse;
  }

  @override
  void update(void Function(RatingResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RatingResponse build() => _build();

  _$RatingResponse _build() {
    final _$result = _$v ??
        _$RatingResponse._(
          comment: comment,
          contextId: BuiltValueNullFieldError.checkNotNull(
              contextId, r'RatingResponse', 'contextId'),
          contextType: BuiltValueNullFieldError.checkNotNull(
              contextType, r'RatingResponse', 'contextType'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'RatingResponse', 'createdAt'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'RatingResponse', 'id'),
          ratedUserId: BuiltValueNullFieldError.checkNotNull(
              ratedUserId, r'RatingResponse', 'ratedUserId'),
          raterId: BuiltValueNullFieldError.checkNotNull(
              raterId, r'RatingResponse', 'raterId'),
          stars: BuiltValueNullFieldError.checkNotNull(
              stars, r'RatingResponse', 'stars'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
