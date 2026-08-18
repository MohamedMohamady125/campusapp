// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mute_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MuteRequest extends MuteRequest {
  @override
  final int? minutes;
  @override
  final String reason;

  factory _$MuteRequest([void Function(MuteRequestBuilder)? updates]) =>
      (MuteRequestBuilder()..update(updates))._build();

  _$MuteRequest._({this.minutes, required this.reason}) : super._();
  @override
  MuteRequest rebuild(void Function(MuteRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MuteRequestBuilder toBuilder() => MuteRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MuteRequest &&
        minutes == other.minutes &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, minutes.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MuteRequest')
          ..add('minutes', minutes)
          ..add('reason', reason))
        .toString();
  }
}

class MuteRequestBuilder implements Builder<MuteRequest, MuteRequestBuilder> {
  _$MuteRequest? _$v;

  int? _minutes;
  int? get minutes => _$this._minutes;
  set minutes(int? minutes) => _$this._minutes = minutes;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  MuteRequestBuilder() {
    MuteRequest._defaults(this);
  }

  MuteRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _minutes = $v.minutes;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MuteRequest other) {
    _$v = other as _$MuteRequest;
  }

  @override
  void update(void Function(MuteRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MuteRequest build() => _build();

  _$MuteRequest _build() {
    final _$result = _$v ??
        _$MuteRequest._(
          minutes: minutes,
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'MuteRequest', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
