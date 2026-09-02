// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_order_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RunOrderResponse extends RunOrderResponse {
  @override
  final DateTime createdAt;
  @override
  final String dropoff;
  @override
  final String id;
  @override
  final String orderText;
  @override
  final String? pickupCode;
  @override
  final RunUserSummary requester;
  @override
  final String runId;
  @override
  final RunOrderStatus status;

  factory _$RunOrderResponse(
          [void Function(RunOrderResponseBuilder)? updates]) =>
      (RunOrderResponseBuilder()..update(updates))._build();

  _$RunOrderResponse._(
      {required this.createdAt,
      required this.dropoff,
      required this.id,
      required this.orderText,
      this.pickupCode,
      required this.requester,
      required this.runId,
      required this.status})
      : super._();
  @override
  RunOrderResponse rebuild(void Function(RunOrderResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RunOrderResponseBuilder toBuilder() =>
      RunOrderResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RunOrderResponse &&
        createdAt == other.createdAt &&
        dropoff == other.dropoff &&
        id == other.id &&
        orderText == other.orderText &&
        pickupCode == other.pickupCode &&
        requester == other.requester &&
        runId == other.runId &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, dropoff.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, orderText.hashCode);
    _$hash = $jc(_$hash, pickupCode.hashCode);
    _$hash = $jc(_$hash, requester.hashCode);
    _$hash = $jc(_$hash, runId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RunOrderResponse')
          ..add('createdAt', createdAt)
          ..add('dropoff', dropoff)
          ..add('id', id)
          ..add('orderText', orderText)
          ..add('pickupCode', pickupCode)
          ..add('requester', requester)
          ..add('runId', runId)
          ..add('status', status))
        .toString();
  }
}

class RunOrderResponseBuilder
    implements Builder<RunOrderResponse, RunOrderResponseBuilder> {
  _$RunOrderResponse? _$v;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _dropoff;
  String? get dropoff => _$this._dropoff;
  set dropoff(String? dropoff) => _$this._dropoff = dropoff;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _orderText;
  String? get orderText => _$this._orderText;
  set orderText(String? orderText) => _$this._orderText = orderText;

  String? _pickupCode;
  String? get pickupCode => _$this._pickupCode;
  set pickupCode(String? pickupCode) => _$this._pickupCode = pickupCode;

  RunUserSummaryBuilder? _requester;
  RunUserSummaryBuilder get requester =>
      _$this._requester ??= RunUserSummaryBuilder();
  set requester(RunUserSummaryBuilder? requester) =>
      _$this._requester = requester;

  String? _runId;
  String? get runId => _$this._runId;
  set runId(String? runId) => _$this._runId = runId;

  RunOrderStatus? _status;
  RunOrderStatus? get status => _$this._status;
  set status(RunOrderStatus? status) => _$this._status = status;

  RunOrderResponseBuilder() {
    RunOrderResponse._defaults(this);
  }

  RunOrderResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _createdAt = $v.createdAt;
      _dropoff = $v.dropoff;
      _id = $v.id;
      _orderText = $v.orderText;
      _pickupCode = $v.pickupCode;
      _requester = $v.requester.toBuilder();
      _runId = $v.runId;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RunOrderResponse other) {
    _$v = other as _$RunOrderResponse;
  }

  @override
  void update(void Function(RunOrderResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RunOrderResponse build() => _build();

  _$RunOrderResponse _build() {
    _$RunOrderResponse _$result;
    try {
      _$result = _$v ??
          _$RunOrderResponse._(
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'RunOrderResponse', 'createdAt'),
            dropoff: BuiltValueNullFieldError.checkNotNull(
                dropoff, r'RunOrderResponse', 'dropoff'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'RunOrderResponse', 'id'),
            orderText: BuiltValueNullFieldError.checkNotNull(
                orderText, r'RunOrderResponse', 'orderText'),
            pickupCode: pickupCode,
            requester: requester.build(),
            runId: BuiltValueNullFieldError.checkNotNull(
                runId, r'RunOrderResponse', 'runId'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'RunOrderResponse', 'status'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'requester';
        requester.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RunOrderResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
