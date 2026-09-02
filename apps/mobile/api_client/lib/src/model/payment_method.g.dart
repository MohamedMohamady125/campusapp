// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PaymentMethod extends PaymentMethod {
  @override
  final String handle;
  @override
  final PaymentMethodType type;

  factory _$PaymentMethod([void Function(PaymentMethodBuilder)? updates]) =>
      (PaymentMethodBuilder()..update(updates))._build();

  _$PaymentMethod._({required this.handle, required this.type}) : super._();
  @override
  PaymentMethod rebuild(void Function(PaymentMethodBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PaymentMethodBuilder toBuilder() => PaymentMethodBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaymentMethod &&
        handle == other.handle &&
        type == other.type;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, handle.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PaymentMethod')
          ..add('handle', handle)
          ..add('type', type))
        .toString();
  }
}

class PaymentMethodBuilder
    implements Builder<PaymentMethod, PaymentMethodBuilder> {
  _$PaymentMethod? _$v;

  String? _handle;
  String? get handle => _$this._handle;
  set handle(String? handle) => _$this._handle = handle;

  PaymentMethodType? _type;
  PaymentMethodType? get type => _$this._type;
  set type(PaymentMethodType? type) => _$this._type = type;

  PaymentMethodBuilder() {
    PaymentMethod._defaults(this);
  }

  PaymentMethodBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _handle = $v.handle;
      _type = $v.type;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PaymentMethod other) {
    _$v = other as _$PaymentMethod;
  }

  @override
  void update(void Function(PaymentMethodBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaymentMethod build() => _build();

  _$PaymentMethod _build() {
    final _$result = _$v ??
        _$PaymentMethod._(
          handle: BuiltValueNullFieldError.checkNotNull(
              handle, r'PaymentMethod', 'handle'),
          type: BuiltValueNullFieldError.checkNotNull(
              type, r'PaymentMethod', 'type'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
