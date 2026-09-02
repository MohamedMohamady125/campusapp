// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_user_summary.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RunUserSummary extends RunUserSummary {
  @override
  final String displayName;
  @override
  final String id;
  @override
  final BuiltList<PaymentMethod>? paymentMethods;
  @override
  final int ratingCount;
  @override
  final num reputationScore;

  factory _$RunUserSummary([void Function(RunUserSummaryBuilder)? updates]) =>
      (RunUserSummaryBuilder()..update(updates))._build();

  _$RunUserSummary._(
      {required this.displayName,
      required this.id,
      this.paymentMethods,
      required this.ratingCount,
      required this.reputationScore})
      : super._();
  @override
  RunUserSummary rebuild(void Function(RunUserSummaryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RunUserSummaryBuilder toBuilder() => RunUserSummaryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RunUserSummary &&
        displayName == other.displayName &&
        id == other.id &&
        paymentMethods == other.paymentMethods &&
        ratingCount == other.ratingCount &&
        reputationScore == other.reputationScore;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, paymentMethods.hashCode);
    _$hash = $jc(_$hash, ratingCount.hashCode);
    _$hash = $jc(_$hash, reputationScore.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RunUserSummary')
          ..add('displayName', displayName)
          ..add('id', id)
          ..add('paymentMethods', paymentMethods)
          ..add('ratingCount', ratingCount)
          ..add('reputationScore', reputationScore))
        .toString();
  }
}

class RunUserSummaryBuilder
    implements Builder<RunUserSummary, RunUserSummaryBuilder> {
  _$RunUserSummary? _$v;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  ListBuilder<PaymentMethod>? _paymentMethods;
  ListBuilder<PaymentMethod> get paymentMethods =>
      _$this._paymentMethods ??= ListBuilder<PaymentMethod>();
  set paymentMethods(ListBuilder<PaymentMethod>? paymentMethods) =>
      _$this._paymentMethods = paymentMethods;

  int? _ratingCount;
  int? get ratingCount => _$this._ratingCount;
  set ratingCount(int? ratingCount) => _$this._ratingCount = ratingCount;

  num? _reputationScore;
  num? get reputationScore => _$this._reputationScore;
  set reputationScore(num? reputationScore) =>
      _$this._reputationScore = reputationScore;

  RunUserSummaryBuilder() {
    RunUserSummary._defaults(this);
  }

  RunUserSummaryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _displayName = $v.displayName;
      _id = $v.id;
      _paymentMethods = $v.paymentMethods?.toBuilder();
      _ratingCount = $v.ratingCount;
      _reputationScore = $v.reputationScore;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RunUserSummary other) {
    _$v = other as _$RunUserSummary;
  }

  @override
  void update(void Function(RunUserSummaryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RunUserSummary build() => _build();

  _$RunUserSummary _build() {
    _$RunUserSummary _$result;
    try {
      _$result = _$v ??
          _$RunUserSummary._(
            displayName: BuiltValueNullFieldError.checkNotNull(
                displayName, r'RunUserSummary', 'displayName'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'RunUserSummary', 'id'),
            paymentMethods: _paymentMethods?.build(),
            ratingCount: BuiltValueNullFieldError.checkNotNull(
                ratingCount, r'RunUserSummary', 'ratingCount'),
            reputationScore: BuiltValueNullFieldError.checkNotNull(
                reputationScore, r'RunUserSummary', 'reputationScore'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'paymentMethods';
        _paymentMethods?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RunUserSummary', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
