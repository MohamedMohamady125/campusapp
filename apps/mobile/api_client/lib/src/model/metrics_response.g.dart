// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metrics_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MetricsResponse extends MetricsResponse {
  @override
  final BuiltList<DailyMetricItem> daily;
  @override
  final BuiltMap<String, int> totals;

  factory _$MetricsResponse([void Function(MetricsResponseBuilder)? updates]) =>
      (MetricsResponseBuilder()..update(updates))._build();

  _$MetricsResponse._({required this.daily, required this.totals}) : super._();
  @override
  MetricsResponse rebuild(void Function(MetricsResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MetricsResponseBuilder toBuilder() => MetricsResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MetricsResponse &&
        daily == other.daily &&
        totals == other.totals;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, daily.hashCode);
    _$hash = $jc(_$hash, totals.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MetricsResponse')
          ..add('daily', daily)
          ..add('totals', totals))
        .toString();
  }
}

class MetricsResponseBuilder
    implements Builder<MetricsResponse, MetricsResponseBuilder> {
  _$MetricsResponse? _$v;

  ListBuilder<DailyMetricItem>? _daily;
  ListBuilder<DailyMetricItem> get daily =>
      _$this._daily ??= ListBuilder<DailyMetricItem>();
  set daily(ListBuilder<DailyMetricItem>? daily) => _$this._daily = daily;

  MapBuilder<String, int>? _totals;
  MapBuilder<String, int> get totals =>
      _$this._totals ??= MapBuilder<String, int>();
  set totals(MapBuilder<String, int>? totals) => _$this._totals = totals;

  MetricsResponseBuilder() {
    MetricsResponse._defaults(this);
  }

  MetricsResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _daily = $v.daily.toBuilder();
      _totals = $v.totals.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MetricsResponse other) {
    _$v = other as _$MetricsResponse;
  }

  @override
  void update(void Function(MetricsResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MetricsResponse build() => _build();

  _$MetricsResponse _build() {
    _$MetricsResponse _$result;
    try {
      _$result = _$v ??
          _$MetricsResponse._(
            daily: daily.build(),
            totals: totals.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'daily';
        daily.build();
        _$failedField = 'totals';
        totals.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MetricsResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
