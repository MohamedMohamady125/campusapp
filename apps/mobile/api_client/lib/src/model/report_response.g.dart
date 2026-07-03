// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReportResponse extends ReportResponse {
  @override
  final DateTime createdAt;
  @override
  final String? handledById;
  @override
  final String id;
  @override
  final String reason;
  @override
  final String reporterId;
  @override
  final ReportStatus status;
  @override
  final String targetId;
  @override
  final ReportTargetType targetType;

  factory _$ReportResponse([void Function(ReportResponseBuilder)? updates]) =>
      (ReportResponseBuilder()..update(updates))._build();

  _$ReportResponse._(
      {required this.createdAt,
      this.handledById,
      required this.id,
      required this.reason,
      required this.reporterId,
      required this.status,
      required this.targetId,
      required this.targetType})
      : super._();
  @override
  ReportResponse rebuild(void Function(ReportResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReportResponseBuilder toBuilder() => ReportResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReportResponse &&
        createdAt == other.createdAt &&
        handledById == other.handledById &&
        id == other.id &&
        reason == other.reason &&
        reporterId == other.reporterId &&
        status == other.status &&
        targetId == other.targetId &&
        targetType == other.targetType;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, handledById.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, reporterId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, targetId.hashCode);
    _$hash = $jc(_$hash, targetType.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReportResponse')
          ..add('createdAt', createdAt)
          ..add('handledById', handledById)
          ..add('id', id)
          ..add('reason', reason)
          ..add('reporterId', reporterId)
          ..add('status', status)
          ..add('targetId', targetId)
          ..add('targetType', targetType))
        .toString();
  }
}

class ReportResponseBuilder
    implements Builder<ReportResponse, ReportResponseBuilder> {
  _$ReportResponse? _$v;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _handledById;
  String? get handledById => _$this._handledById;
  set handledById(String? handledById) => _$this._handledById = handledById;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  String? _reporterId;
  String? get reporterId => _$this._reporterId;
  set reporterId(String? reporterId) => _$this._reporterId = reporterId;

  ReportStatus? _status;
  ReportStatus? get status => _$this._status;
  set status(ReportStatus? status) => _$this._status = status;

  String? _targetId;
  String? get targetId => _$this._targetId;
  set targetId(String? targetId) => _$this._targetId = targetId;

  ReportTargetType? _targetType;
  ReportTargetType? get targetType => _$this._targetType;
  set targetType(ReportTargetType? targetType) =>
      _$this._targetType = targetType;

  ReportResponseBuilder() {
    ReportResponse._defaults(this);
  }

  ReportResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _createdAt = $v.createdAt;
      _handledById = $v.handledById;
      _id = $v.id;
      _reason = $v.reason;
      _reporterId = $v.reporterId;
      _status = $v.status;
      _targetId = $v.targetId;
      _targetType = $v.targetType;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReportResponse other) {
    _$v = other as _$ReportResponse;
  }

  @override
  void update(void Function(ReportResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReportResponse build() => _build();

  _$ReportResponse _build() {
    final _$result = _$v ??
        _$ReportResponse._(
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'ReportResponse', 'createdAt'),
          handledById: handledById,
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ReportResponse', 'id'),
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'ReportResponse', 'reason'),
          reporterId: BuiltValueNullFieldError.checkNotNull(
              reporterId, r'ReportResponse', 'reporterId'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'ReportResponse', 'status'),
          targetId: BuiltValueNullFieldError.checkNotNull(
              targetId, r'ReportResponse', 'targetId'),
          targetType: BuiltValueNullFieldError.checkNotNull(
              targetType, r'ReportResponse', 'targetType'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
