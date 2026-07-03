// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReportCreateRequest extends ReportCreateRequest {
  @override
  final String reason;
  @override
  final String targetId;
  @override
  final ReportTargetType targetType;

  factory _$ReportCreateRequest(
          [void Function(ReportCreateRequestBuilder)? updates]) =>
      (ReportCreateRequestBuilder()..update(updates))._build();

  _$ReportCreateRequest._(
      {required this.reason, required this.targetId, required this.targetType})
      : super._();
  @override
  ReportCreateRequest rebuild(
          void Function(ReportCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReportCreateRequestBuilder toBuilder() =>
      ReportCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReportCreateRequest &&
        reason == other.reason &&
        targetId == other.targetId &&
        targetType == other.targetType;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, targetId.hashCode);
    _$hash = $jc(_$hash, targetType.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReportCreateRequest')
          ..add('reason', reason)
          ..add('targetId', targetId)
          ..add('targetType', targetType))
        .toString();
  }
}

class ReportCreateRequestBuilder
    implements Builder<ReportCreateRequest, ReportCreateRequestBuilder> {
  _$ReportCreateRequest? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  String? _targetId;
  String? get targetId => _$this._targetId;
  set targetId(String? targetId) => _$this._targetId = targetId;

  ReportTargetType? _targetType;
  ReportTargetType? get targetType => _$this._targetType;
  set targetType(ReportTargetType? targetType) =>
      _$this._targetType = targetType;

  ReportCreateRequestBuilder() {
    ReportCreateRequest._defaults(this);
  }

  ReportCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _targetId = $v.targetId;
      _targetType = $v.targetType;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReportCreateRequest other) {
    _$v = other as _$ReportCreateRequest;
  }

  @override
  void update(void Function(ReportCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReportCreateRequest build() => _build();

  _$ReportCreateRequest _build() {
    final _$result = _$v ??
        _$ReportCreateRequest._(
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'ReportCreateRequest', 'reason'),
          targetId: BuiltValueNullFieldError.checkNotNull(
              targetId, r'ReportCreateRequest', 'targetId'),
          targetType: BuiltValueNullFieldError.checkNotNull(
              targetType, r'ReportCreateRequest', 'targetType'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
