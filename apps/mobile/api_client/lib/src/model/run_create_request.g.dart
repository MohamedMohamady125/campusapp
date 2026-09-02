// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RunCreateRequest extends RunCreateRequest {
  @override
  final String deliverySpot;
  @override
  final int? feeCents;
  @override
  final String foodSpotId;
  @override
  final DateTime leavingAt;
  @override
  final String? note;
  @override
  final bool? paysWithDiningDollars;
  @override
  final bool? prepayRequired;
  @override
  final int? spotsMax;

  factory _$RunCreateRequest(
          [void Function(RunCreateRequestBuilder)? updates]) =>
      (RunCreateRequestBuilder()..update(updates))._build();

  _$RunCreateRequest._(
      {required this.deliverySpot,
      this.feeCents,
      required this.foodSpotId,
      required this.leavingAt,
      this.note,
      this.paysWithDiningDollars,
      this.prepayRequired,
      this.spotsMax})
      : super._();
  @override
  RunCreateRequest rebuild(void Function(RunCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RunCreateRequestBuilder toBuilder() =>
      RunCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RunCreateRequest &&
        deliverySpot == other.deliverySpot &&
        feeCents == other.feeCents &&
        foodSpotId == other.foodSpotId &&
        leavingAt == other.leavingAt &&
        note == other.note &&
        paysWithDiningDollars == other.paysWithDiningDollars &&
        prepayRequired == other.prepayRequired &&
        spotsMax == other.spotsMax;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, deliverySpot.hashCode);
    _$hash = $jc(_$hash, feeCents.hashCode);
    _$hash = $jc(_$hash, foodSpotId.hashCode);
    _$hash = $jc(_$hash, leavingAt.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, paysWithDiningDollars.hashCode);
    _$hash = $jc(_$hash, prepayRequired.hashCode);
    _$hash = $jc(_$hash, spotsMax.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RunCreateRequest')
          ..add('deliverySpot', deliverySpot)
          ..add('feeCents', feeCents)
          ..add('foodSpotId', foodSpotId)
          ..add('leavingAt', leavingAt)
          ..add('note', note)
          ..add('paysWithDiningDollars', paysWithDiningDollars)
          ..add('prepayRequired', prepayRequired)
          ..add('spotsMax', spotsMax))
        .toString();
  }
}

class RunCreateRequestBuilder
    implements Builder<RunCreateRequest, RunCreateRequestBuilder> {
  _$RunCreateRequest? _$v;

  String? _deliverySpot;
  String? get deliverySpot => _$this._deliverySpot;
  set deliverySpot(String? deliverySpot) => _$this._deliverySpot = deliverySpot;

  int? _feeCents;
  int? get feeCents => _$this._feeCents;
  set feeCents(int? feeCents) => _$this._feeCents = feeCents;

  String? _foodSpotId;
  String? get foodSpotId => _$this._foodSpotId;
  set foodSpotId(String? foodSpotId) => _$this._foodSpotId = foodSpotId;

  DateTime? _leavingAt;
  DateTime? get leavingAt => _$this._leavingAt;
  set leavingAt(DateTime? leavingAt) => _$this._leavingAt = leavingAt;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  bool? _paysWithDiningDollars;
  bool? get paysWithDiningDollars => _$this._paysWithDiningDollars;
  set paysWithDiningDollars(bool? paysWithDiningDollars) =>
      _$this._paysWithDiningDollars = paysWithDiningDollars;

  bool? _prepayRequired;
  bool? get prepayRequired => _$this._prepayRequired;
  set prepayRequired(bool? prepayRequired) =>
      _$this._prepayRequired = prepayRequired;

  int? _spotsMax;
  int? get spotsMax => _$this._spotsMax;
  set spotsMax(int? spotsMax) => _$this._spotsMax = spotsMax;

  RunCreateRequestBuilder() {
    RunCreateRequest._defaults(this);
  }

  RunCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _deliverySpot = $v.deliverySpot;
      _feeCents = $v.feeCents;
      _foodSpotId = $v.foodSpotId;
      _leavingAt = $v.leavingAt;
      _note = $v.note;
      _paysWithDiningDollars = $v.paysWithDiningDollars;
      _prepayRequired = $v.prepayRequired;
      _spotsMax = $v.spotsMax;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RunCreateRequest other) {
    _$v = other as _$RunCreateRequest;
  }

  @override
  void update(void Function(RunCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RunCreateRequest build() => _build();

  _$RunCreateRequest _build() {
    final _$result = _$v ??
        _$RunCreateRequest._(
          deliverySpot: BuiltValueNullFieldError.checkNotNull(
              deliverySpot, r'RunCreateRequest', 'deliverySpot'),
          feeCents: feeCents,
          foodSpotId: BuiltValueNullFieldError.checkNotNull(
              foodSpotId, r'RunCreateRequest', 'foodSpotId'),
          leavingAt: BuiltValueNullFieldError.checkNotNull(
              leavingAt, r'RunCreateRequest', 'leavingAt'),
          note: note,
          paysWithDiningDollars: paysWithDiningDollars,
          prepayRequired: prepayRequired,
          spotsMax: spotsMax,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
