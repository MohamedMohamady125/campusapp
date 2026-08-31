// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_status_update_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RunStatusUpdateRequest extends RunStatusUpdateRequest {
  @override
  final RunStatus status;

  factory _$RunStatusUpdateRequest(
          [void Function(RunStatusUpdateRequestBuilder)? updates]) =>
      (RunStatusUpdateRequestBuilder()..update(updates))._build();

  _$RunStatusUpdateRequest._({required this.status}) : super._();
  @override
  RunStatusUpdateRequest rebuild(
          void Function(RunStatusUpdateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RunStatusUpdateRequestBuilder toBuilder() =>
      RunStatusUpdateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RunStatusUpdateRequest && status == other.status;
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
    return (newBuiltValueToStringHelper(r'RunStatusUpdateRequest')
          ..add('status', status))
        .toString();
  }
}

class RunStatusUpdateRequestBuilder
    implements Builder<RunStatusUpdateRequest, RunStatusUpdateRequestBuilder> {
  _$RunStatusUpdateRequest? _$v;

  RunStatus? _status;
  RunStatus? get status => _$this._status;
  set status(RunStatus? status) => _$this._status = status;

  RunStatusUpdateRequestBuilder() {
    RunStatusUpdateRequest._defaults(this);
  }

  RunStatusUpdateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RunStatusUpdateRequest other) {
    _$v = other as _$RunStatusUpdateRequest;
  }

  @override
  void update(void Function(RunStatusUpdateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RunStatusUpdateRequest build() => _build();

  _$RunStatusUpdateRequest _build() {
    final _$result = _$v ??
        _$RunStatusUpdateRequest._(
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'RunStatusUpdateRequest', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
