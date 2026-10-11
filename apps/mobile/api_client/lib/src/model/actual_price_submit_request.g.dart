// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actual_price_submit_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ActualPriceSubmitRequest extends ActualPriceSubmitRequest {
  @override
  final int actualPriceCents;

  factory _$ActualPriceSubmitRequest(
          [void Function(ActualPriceSubmitRequestBuilder)? updates]) =>
      (ActualPriceSubmitRequestBuilder()..update(updates))._build();

  _$ActualPriceSubmitRequest._({required this.actualPriceCents}) : super._();
  @override
  ActualPriceSubmitRequest rebuild(
          void Function(ActualPriceSubmitRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ActualPriceSubmitRequestBuilder toBuilder() =>
      ActualPriceSubmitRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ActualPriceSubmitRequest &&
        actualPriceCents == other.actualPriceCents;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, actualPriceCents.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ActualPriceSubmitRequest')
          ..add('actualPriceCents', actualPriceCents))
        .toString();
  }
}

class ActualPriceSubmitRequestBuilder
    implements
        Builder<ActualPriceSubmitRequest, ActualPriceSubmitRequestBuilder> {
  _$ActualPriceSubmitRequest? _$v;

  int? _actualPriceCents;
  int? get actualPriceCents => _$this._actualPriceCents;
  set actualPriceCents(int? actualPriceCents) =>
      _$this._actualPriceCents = actualPriceCents;

  ActualPriceSubmitRequestBuilder() {
    ActualPriceSubmitRequest._defaults(this);
  }

  ActualPriceSubmitRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _actualPriceCents = $v.actualPriceCents;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ActualPriceSubmitRequest other) {
    _$v = other as _$ActualPriceSubmitRequest;
  }

  @override
  void update(void Function(ActualPriceSubmitRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ActualPriceSubmitRequest build() => _build();

  _$ActualPriceSubmitRequest _build() {
    final _$result = _$v ??
        _$ActualPriceSubmitRequest._(
          actualPriceCents: BuiltValueNullFieldError.checkNotNull(
              actualPriceCents,
              r'ActualPriceSubmitRequest',
              'actualPriceCents'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
