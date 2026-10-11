// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_order_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RunOrderCreateRequest extends RunOrderCreateRequest {
  @override
  final String dropoffLocationId;
  @override
  final int? itemPriceCents;
  @override
  final String orderText;

  factory _$RunOrderCreateRequest(
          [void Function(RunOrderCreateRequestBuilder)? updates]) =>
      (RunOrderCreateRequestBuilder()..update(updates))._build();

  _$RunOrderCreateRequest._(
      {required this.dropoffLocationId,
      this.itemPriceCents,
      required this.orderText})
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
        dropoffLocationId == other.dropoffLocationId &&
        itemPriceCents == other.itemPriceCents &&
        orderText == other.orderText;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, dropoffLocationId.hashCode);
    _$hash = $jc(_$hash, itemPriceCents.hashCode);
    _$hash = $jc(_$hash, orderText.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RunOrderCreateRequest')
          ..add('dropoffLocationId', dropoffLocationId)
          ..add('itemPriceCents', itemPriceCents)
          ..add('orderText', orderText))
        .toString();
  }
}

class RunOrderCreateRequestBuilder
    implements Builder<RunOrderCreateRequest, RunOrderCreateRequestBuilder> {
  _$RunOrderCreateRequest? _$v;

  String? _dropoffLocationId;
  String? get dropoffLocationId => _$this._dropoffLocationId;
  set dropoffLocationId(String? dropoffLocationId) =>
      _$this._dropoffLocationId = dropoffLocationId;

  int? _itemPriceCents;
  int? get itemPriceCents => _$this._itemPriceCents;
  set itemPriceCents(int? itemPriceCents) =>
      _$this._itemPriceCents = itemPriceCents;

  String? _orderText;
  String? get orderText => _$this._orderText;
  set orderText(String? orderText) => _$this._orderText = orderText;

  RunOrderCreateRequestBuilder() {
    RunOrderCreateRequest._defaults(this);
  }

  RunOrderCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _dropoffLocationId = $v.dropoffLocationId;
      _itemPriceCents = $v.itemPriceCents;
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
          dropoffLocationId: BuiltValueNullFieldError.checkNotNull(
              dropoffLocationId, r'RunOrderCreateRequest', 'dropoffLocationId'),
          itemPriceCents: itemPriceCents,
          orderText: BuiltValueNullFieldError.checkNotNull(
              orderText, r'RunOrderCreateRequest', 'orderText'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
