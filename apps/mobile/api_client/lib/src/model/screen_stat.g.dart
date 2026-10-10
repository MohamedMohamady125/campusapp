// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screen_stat.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ScreenStat extends ScreenStat {
  @override
  final num avgSeconds;
  @override
  final String screen;
  @override
  final num totalMinutes;
  @override
  final int uniqueUsers;
  @override
  final int views;

  factory _$ScreenStat([void Function(ScreenStatBuilder)? updates]) =>
      (ScreenStatBuilder()..update(updates))._build();

  _$ScreenStat._(
      {required this.avgSeconds,
      required this.screen,
      required this.totalMinutes,
      required this.uniqueUsers,
      required this.views})
      : super._();
  @override
  ScreenStat rebuild(void Function(ScreenStatBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ScreenStatBuilder toBuilder() => ScreenStatBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ScreenStat &&
        avgSeconds == other.avgSeconds &&
        screen == other.screen &&
        totalMinutes == other.totalMinutes &&
        uniqueUsers == other.uniqueUsers &&
        views == other.views;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, avgSeconds.hashCode);
    _$hash = $jc(_$hash, screen.hashCode);
    _$hash = $jc(_$hash, totalMinutes.hashCode);
    _$hash = $jc(_$hash, uniqueUsers.hashCode);
    _$hash = $jc(_$hash, views.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ScreenStat')
          ..add('avgSeconds', avgSeconds)
          ..add('screen', screen)
          ..add('totalMinutes', totalMinutes)
          ..add('uniqueUsers', uniqueUsers)
          ..add('views', views))
        .toString();
  }
}

class ScreenStatBuilder implements Builder<ScreenStat, ScreenStatBuilder> {
  _$ScreenStat? _$v;

  num? _avgSeconds;
  num? get avgSeconds => _$this._avgSeconds;
  set avgSeconds(num? avgSeconds) => _$this._avgSeconds = avgSeconds;

  String? _screen;
  String? get screen => _$this._screen;
  set screen(String? screen) => _$this._screen = screen;

  num? _totalMinutes;
  num? get totalMinutes => _$this._totalMinutes;
  set totalMinutes(num? totalMinutes) => _$this._totalMinutes = totalMinutes;

  int? _uniqueUsers;
  int? get uniqueUsers => _$this._uniqueUsers;
  set uniqueUsers(int? uniqueUsers) => _$this._uniqueUsers = uniqueUsers;

  int? _views;
  int? get views => _$this._views;
  set views(int? views) => _$this._views = views;

  ScreenStatBuilder() {
    ScreenStat._defaults(this);
  }

  ScreenStatBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _avgSeconds = $v.avgSeconds;
      _screen = $v.screen;
      _totalMinutes = $v.totalMinutes;
      _uniqueUsers = $v.uniqueUsers;
      _views = $v.views;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ScreenStat other) {
    _$v = other as _$ScreenStat;
  }

  @override
  void update(void Function(ScreenStatBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ScreenStat build() => _build();

  _$ScreenStat _build() {
    final _$result = _$v ??
        _$ScreenStat._(
          avgSeconds: BuiltValueNullFieldError.checkNotNull(
              avgSeconds, r'ScreenStat', 'avgSeconds'),
          screen: BuiltValueNullFieldError.checkNotNull(
              screen, r'ScreenStat', 'screen'),
          totalMinutes: BuiltValueNullFieldError.checkNotNull(
              totalMinutes, r'ScreenStat', 'totalMinutes'),
          uniqueUsers: BuiltValueNullFieldError.checkNotNull(
              uniqueUsers, r'ScreenStat', 'uniqueUsers'),
          views: BuiltValueNullFieldError.checkNotNull(
              views, r'ScreenStat', 'views'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
