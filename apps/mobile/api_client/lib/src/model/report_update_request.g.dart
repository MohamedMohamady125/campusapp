// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_update_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReportUpdateRequest extends ReportUpdateRequest {
  @override
  final ReportStatus status;

  factory _$ReportUpdateRequest(
          [void Function(ReportUpdateRequestBuilder)? updates]) =>
      (ReportUpdateRequestBuilder()..update(updates))._build();

  _$ReportUpdateRequest._({required this.status}) : super._();
  @override
  ReportUpdateRequest rebuild(
          void Function(ReportUpdateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReportUpdateRequestBuilder toBuilder() =>
      ReportUpdateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReportUpdateRequest && status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReportUpdateRequest')
          ..add('status', status))
        .toString();
  }
}

class ReportUpdateRequestBuilder
    implements Builder<ReportUpdateRequest, ReportUpdateRequestBuilder> {
  _$ReportUpdateRequest? _$v;

  ReportStatus? _status;
  ReportStatus? get status => _$this._status;
  set status(ReportStatus? status) => _$this._status = status;

  ReportUpdateRequestBuilder() {
    ReportUpdateRequest._defaults(this);
  }

  ReportUpdateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReportUpdateRequest other) {
    _$v = other as _$ReportUpdateRequest;
  }

  @override
  void update(void Function(ReportUpdateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReportUpdateRequest build() => _build();

  _$ReportUpdateRequest _build() {
    final _$result = _$v ??
        _$ReportUpdateRequest._(
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'ReportUpdateRequest', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
