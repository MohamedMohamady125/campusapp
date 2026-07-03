// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SubscriptionResponse extends SubscriptionResponse {
  @override
  final DateTime currentPeriodEnd;
  @override
  final String id;
  @override
  final String plan;
  @override
  final String status;

  factory _$SubscriptionResponse(
          [void Function(SubscriptionResponseBuilder)? updates]) =>
      (SubscriptionResponseBuilder()..update(updates))._build();

  _$SubscriptionResponse._(
      {required this.currentPeriodEnd,
      required this.id,
      required this.plan,
      required this.status})
      : super._();
  @override
  SubscriptionResponse rebuild(
          void Function(SubscriptionResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SubscriptionResponseBuilder toBuilder() =>
      SubscriptionResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SubscriptionResponse &&
        currentPeriodEnd == other.currentPeriodEnd &&
        id == other.id &&
        plan == other.plan &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, currentPeriodEnd.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, plan.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SubscriptionResponse')
          ..add('currentPeriodEnd', currentPeriodEnd)
          ..add('id', id)
          ..add('plan', plan)
          ..add('status', status))
        .toString();
  }
}

class SubscriptionResponseBuilder
    implements Builder<SubscriptionResponse, SubscriptionResponseBuilder> {
  _$SubscriptionResponse? _$v;

  DateTime? _currentPeriodEnd;
  DateTime? get currentPeriodEnd => _$this._currentPeriodEnd;
  set currentPeriodEnd(DateTime? currentPeriodEnd) =>
      _$this._currentPeriodEnd = currentPeriodEnd;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _plan;
  String? get plan => _$this._plan;
  set plan(String? plan) => _$this._plan = plan;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  SubscriptionResponseBuilder() {
    SubscriptionResponse._defaults(this);
  }

  SubscriptionResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _currentPeriodEnd = $v.currentPeriodEnd;
      _id = $v.id;
      _plan = $v.plan;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SubscriptionResponse other) {
    _$v = other as _$SubscriptionResponse;
  }

  @override
  void update(void Function(SubscriptionResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SubscriptionResponse build() => _build();

  _$SubscriptionResponse _build() {
    final _$result = _$v ??
        _$SubscriptionResponse._(
          currentPeriodEnd: BuiltValueNullFieldError.checkNotNull(
              currentPeriodEnd, r'SubscriptionResponse', 'currentPeriodEnd'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'SubscriptionResponse', 'id'),
          plan: BuiltValueNullFieldError.checkNotNull(
              plan, r'SubscriptionResponse', 'plan'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'SubscriptionResponse', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
