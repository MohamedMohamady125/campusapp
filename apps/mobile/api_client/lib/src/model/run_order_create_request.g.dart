// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_order_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RunOrderCreateRequest extends RunOrderCreateRequest {
  @override
  final String dropoff;
  @override
  final String orderText;

  factory _$RunOrderCreateRequest(
          [void Function(RunOrderCreateRequestBuilder)? updates]) =>
      (RunOrderCreateRequestBuilder()..update(updates))._build();

  _$RunOrderCreateRequest._({required this.dropoff, required this.orderText})
      : super._();
  @override
  RunOrderCreateRequest rebuild(
          void Function(RunOrderCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RunOrderCreateRequestBuilder toBuilder() =>
      RunOrderCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RunOrderCreateRequest &&
        dropoff == other.dropoff &&
        orderText == other.orderText;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, dropoff.hashCode);
    _$hash = $jc(_$hash, orderText.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RunOrderCreateRequest')
          ..add('dropoff', dropoff)
          ..add('orderText', orderText))
        .toString();
  }
}

class RunOrderCreateRequestBuilder
    implements Builder<RunOrderCreateRequest, RunOrderCreateRequestBuilder> {
  _$RunOrderCreateRequest? _$v;

  String? _dropoff;
  String? get dropoff => _$this._dropoff;
  set dropoff(String? dropoff) => _$this._dropoff = dropoff;

  String? _orderText;
  String? get orderText => _$this._orderText;
  set orderText(String? orderText) => _$this._orderText = orderText;

  RunOrderCreateRequestBuilder() {
    RunOrderCreateRequest._defaults(this);
  }

  RunOrderCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _dropoff = $v.dropoff;
      _orderText = $v.orderText;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RunOrderCreateRequest other) {
    _$v = other as _$RunOrderCreateRequest;
  }

  @override
  void update(void Function(RunOrderCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RunOrderCreateRequest build() => _build();

  _$RunOrderCreateRequest _build() {
    final _$result = _$v ??
        _$RunOrderCreateRequest._(
          dropoff: BuiltValueNullFieldError.checkNotNull(
              dropoff, r'RunOrderCreateRequest', 'dropoff'),
          orderText: BuiltValueNullFieldError.checkNotNull(
              orderText, r'RunOrderCreateRequest', 'orderText'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
