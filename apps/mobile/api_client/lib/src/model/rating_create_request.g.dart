// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RatingCreateRequest extends RatingCreateRequest {
  @override
  final String? comment;
  @override
  final String contextId;
  @override
  final RatingContext contextType;
  @override
  final String ratedUserId;
  @override
  final int stars;

  factory _$RatingCreateRequest(
          [void Function(RatingCreateRequestBuilder)? updates]) =>
      (RatingCreateRequestBuilder()..update(updates))._build();

  _$RatingCreateRequest._(
      {this.comment,
      required this.contextId,
      required this.contextType,
      required this.ratedUserId,
      required this.stars})
      : super._();
  @override
  RatingCreateRequest rebuild(
          void Function(RatingCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RatingCreateRequestBuilder toBuilder() =>
      RatingCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RatingCreateRequest &&
        comment == other.comment &&
        contextId == other.contextId &&
        contextType == other.contextType &&
        ratedUserId == other.ratedUserId &&
        stars == other.stars;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, comment.hashCode);
    _$hash = $jc(_$hash, contextId.hashCode);
    _$hash = $jc(_$hash, contextType.hashCode);
    _$hash = $jc(_$hash, ratedUserId.hashCode);
    _$hash = $jc(_$hash, stars.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RatingCreateRequest')
          ..add('comment', comment)
          ..add('contextId', contextId)
          ..add('contextType', contextType)
          ..add('ratedUserId', ratedUserId)
          ..add('stars', stars))
        .toString();
  }
}

class RatingCreateRequestBuilder
    implements Builder<RatingCreateRequest, RatingCreateRequestBuilder> {
  _$RatingCreateRequest? _$v;

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

  String? _ratedUserId;
  String? get ratedUserId => _$this._ratedUserId;
  set ratedUserId(String? ratedUserId) => _$this._ratedUserId = ratedUserId;

  int? _stars;
  int? get stars => _$this._stars;
  set stars(int? stars) => _$this._stars = stars;

  RatingCreateRequestBuilder() {
    RatingCreateRequest._defaults(this);
  }

  RatingCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _comment = $v.comment;
      _contextId = $v.contextId;
      _contextType = $v.contextType;
      _ratedUserId = $v.ratedUserId;
      _stars = $v.stars;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RatingCreateRequest other) {
    _$v = other as _$RatingCreateRequest;
  }

  @override
  void update(void Function(RatingCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RatingCreateRequest build() => _build();

  _$RatingCreateRequest _build() {
    final _$result = _$v ??
        _$RatingCreateRequest._(
          comment: comment,
          contextId: BuiltValueNullFieldError.checkNotNull(
              contextId, r'RatingCreateRequest', 'contextId'),
          contextType: BuiltValueNullFieldError.checkNotNull(
              contextType, r'RatingCreateRequest', 'contextType'),
          ratedUserId: BuiltValueNullFieldError.checkNotNull(
              ratedUserId, r'RatingCreateRequest', 'ratedUserId'),
          stars: BuiltValueNullFieldError.checkNotNull(
              stars, r'RatingCreateRequest', 'stars'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
