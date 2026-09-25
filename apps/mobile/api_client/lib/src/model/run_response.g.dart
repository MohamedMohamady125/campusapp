// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RunResponse extends RunResponse {
  @override
  final int acceptedCount;
  @override
  final DateTime createdAt;
  @override
  final int feeCents;
  @override
  final FoodSpotResponse foodSpot;
  @override
  final String id;
  @override
  final DateTime leavingAt;
  @override
  final RunOrderResponse? myOrder;
  @override
  final String? note;
  @override
  final BuiltList<RunOrderResponse>? orders;
  @override
  final int pendingCount;
  @override
  final bool prepayRequired;
  @override
  final RunUserSummary runner;
  @override
  final RunLocation? runnerLocation;
  @override
  final int spotsMax;
  @override
  final RunStatus status;

  factory _$RunResponse([void Function(RunResponseBuilder)? updates]) =>
      (RunResponseBuilder()..update(updates))._build();

  _$RunResponse._(
      {required this.acceptedCount,
      required this.createdAt,
      required this.feeCents,
      required this.foodSpot,
      required this.id,
      required this.leavingAt,
      this.myOrder,
      this.note,
      this.orders,
      required this.pendingCount,
      required this.prepayRequired,
      required this.runner,
      this.runnerLocation,
      required this.spotsMax,
      required this.status})
      : super._();
  @override
  RunResponse rebuild(void Function(RunResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RunResponseBuilder toBuilder() => RunResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RunResponse &&
        acceptedCount == other.acceptedCount &&
        createdAt == other.createdAt &&
        feeCents == other.feeCents &&
        foodSpot == other.foodSpot &&
        id == other.id &&
        leavingAt == other.leavingAt &&
        myOrder == other.myOrder &&
        note == other.note &&
        orders == other.orders &&
        pendingCount == other.pendingCount &&
        prepayRequired == other.prepayRequired &&
        runner == other.runner &&
        runnerLocation == other.runnerLocation &&
        spotsMax == other.spotsMax &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, acceptedCount.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, feeCents.hashCode);
    _$hash = $jc(_$hash, foodSpot.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, leavingAt.hashCode);
    _$hash = $jc(_$hash, myOrder.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, orders.hashCode);
    _$hash = $jc(_$hash, pendingCount.hashCode);
    _$hash = $jc(_$hash, prepayRequired.hashCode);
    _$hash = $jc(_$hash, runner.hashCode);
    _$hash = $jc(_$hash, runnerLocation.hashCode);
    _$hash = $jc(_$hash, spotsMax.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RunResponse')
          ..add('acceptedCount', acceptedCount)
          ..add('createdAt', createdAt)
          ..add('feeCents', feeCents)
          ..add('foodSpot', foodSpot)
          ..add('id', id)
          ..add('leavingAt', leavingAt)
          ..add('myOrder', myOrder)
          ..add('note', note)
          ..add('orders', orders)
          ..add('pendingCount', pendingCount)
          ..add('prepayRequired', prepayRequired)
          ..add('runner', runner)
          ..add('runnerLocation', runnerLocation)
          ..add('spotsMax', spotsMax)
          ..add('status', status))
        .toString();
  }
}

class RunResponseBuilder implements Builder<RunResponse, RunResponseBuilder> {
  _$RunResponse? _$v;

  int? _acceptedCount;
  int? get acceptedCount => _$this._acceptedCount;
  set acceptedCount(int? acceptedCount) =>
      _$this._acceptedCount = acceptedCount;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  int? _feeCents;
  int? get feeCents => _$this._feeCents;
  set feeCents(int? feeCents) => _$this._feeCents = feeCents;

  FoodSpotResponseBuilder? _foodSpot;
  FoodSpotResponseBuilder get foodSpot =>
      _$this._foodSpot ??= FoodSpotResponseBuilder();
  set foodSpot(FoodSpotResponseBuilder? foodSpot) =>
      _$this._foodSpot = foodSpot;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DateTime? _leavingAt;
  DateTime? get leavingAt => _$this._leavingAt;
  set leavingAt(DateTime? leavingAt) => _$this._leavingAt = leavingAt;

  RunOrderResponseBuilder? _myOrder;
  RunOrderResponseBuilder get myOrder =>
      _$this._myOrder ??= RunOrderResponseBuilder();
  set myOrder(RunOrderResponseBuilder? myOrder) => _$this._myOrder = myOrder;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  ListBuilder<RunOrderResponse>? _orders;
  ListBuilder<RunOrderResponse> get orders =>
      _$this._orders ??= ListBuilder<RunOrderResponse>();
  set orders(ListBuilder<RunOrderResponse>? orders) => _$this._orders = orders;

  int? _pendingCount;
  int? get pendingCount => _$this._pendingCount;
  set pendingCount(int? pendingCount) => _$this._pendingCount = pendingCount;

  bool? _prepayRequired;
  bool? get prepayRequired => _$this._prepayRequired;
  set prepayRequired(bool? prepayRequired) =>
      _$this._prepayRequired = prepayRequired;

  RunUserSummaryBuilder? _runner;
  RunUserSummaryBuilder get runner =>
      _$this._runner ??= RunUserSummaryBuilder();
  set runner(RunUserSummaryBuilder? runner) => _$this._runner = runner;

  RunLocationBuilder? _runnerLocation;
  RunLocationBuilder get runnerLocation =>
      _$this._runnerLocation ??= RunLocationBuilder();
  set runnerLocation(RunLocationBuilder? runnerLocation) =>
      _$this._runnerLocation = runnerLocation;

  int? _spotsMax;
  int? get spotsMax => _$this._spotsMax;
  set spotsMax(int? spotsMax) => _$this._spotsMax = spotsMax;

  RunStatus? _status;
  RunStatus? get status => _$this._status;
  set status(RunStatus? status) => _$this._status = status;

  RunResponseBuilder() {
    RunResponse._defaults(this);
  }

  RunResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _acceptedCount = $v.acceptedCount;
      _createdAt = $v.createdAt;
      _feeCents = $v.feeCents;
      _foodSpot = $v.foodSpot.toBuilder();
      _id = $v.id;
      _leavingAt = $v.leavingAt;
      _myOrder = $v.myOrder?.toBuilder();
      _note = $v.note;
      _orders = $v.orders?.toBuilder();
      _pendingCount = $v.pendingCount;
      _prepayRequired = $v.prepayRequired;
      _runner = $v.runner.toBuilder();
      _runnerLocation = $v.runnerLocation?.toBuilder();
      _spotsMax = $v.spotsMax;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RunResponse other) {
    _$v = other as _$RunResponse;
  }

  @override
  void update(void Function(RunResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RunResponse build() => _build();

  _$RunResponse _build() {
    _$RunResponse _$result;
    try {
      _$result = _$v ??
          _$RunResponse._(
            acceptedCount: BuiltValueNullFieldError.checkNotNull(
                acceptedCount, r'RunResponse', 'acceptedCount'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'RunResponse', 'createdAt'),
            feeCents: BuiltValueNullFieldError.checkNotNull(
                feeCents, r'RunResponse', 'feeCents'),
            foodSpot: foodSpot.build(),
            id: BuiltValueNullFieldError.checkNotNull(id, r'RunResponse', 'id'),
            leavingAt: BuiltValueNullFieldError.checkNotNull(
                leavingAt, r'RunResponse', 'leavingAt'),
            myOrder: _myOrder?.build(),
            note: note,
            orders: _orders?.build(),
            pendingCount: BuiltValueNullFieldError.checkNotNull(
                pendingCount, r'RunResponse', 'pendingCount'),
            prepayRequired: BuiltValueNullFieldError.checkNotNull(
                prepayRequired, r'RunResponse', 'prepayRequired'),
            runner: runner.build(),
            runnerLocation: _runnerLocation?.build(),
            spotsMax: BuiltValueNullFieldError.checkNotNull(
                spotsMax, r'RunResponse', 'spotsMax'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'RunResponse', 'status'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'foodSpot';
        foodSpot.build();

        _$failedField = 'myOrder';
        _myOrder?.build();

        _$failedField = 'orders';
        _orders?.build();

        _$failedField = 'runner';
        runner.build();
        _$failedField = 'runnerLocation';
        _runnerLocation?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RunResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
