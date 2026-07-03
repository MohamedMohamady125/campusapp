// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mute_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MuteRequest extends MuteRequest {
  @override
  final int? minutes;

  factory _$MuteRequest([void Function(MuteRequestBuilder)? updates]) =>
      (MuteRequestBuilder()..update(updates))._build();

  _$MuteRequest._({this.minutes}) : super._();
  @override
  MuteRequest rebuild(void Function(MuteRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MuteRequestBuilder toBuilder() => MuteRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MuteRequest && minutes == other.minutes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, minutes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MuteRequest')
          ..add('minutes', minutes))
        .toString();
  }
}

class MuteRequestBuilder implements Builder<MuteRequest, MuteRequestBuilder> {
  _$MuteRequest? _$v;

  int? _minutes;
  int? get minutes => _$this._minutes;
  set minutes(int? minutes) => _$this._minutes = minutes;

  MuteRequestBuilder() {
    MuteRequest._defaults(this);
  }

  MuteRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _minutes = $v.minutes;
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
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
