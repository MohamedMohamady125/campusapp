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
  final int ratingCount;
  @override
  final num reputationScore;
  @override
  final String? venmoHandle;

  factory _$RunUserSummary([void Function(RunUserSummaryBuilder)? updates]) =>
      (RunUserSummaryBuilder()..update(updates))._build();

  _$RunUserSummary._(
      {required this.displayName,
      required this.id,
      required this.ratingCount,
      required this.reputationScore,
      this.venmoHandle})
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
        ratingCount == other.ratingCount &&
        reputationScore == other.reputationScore &&
        venmoHandle == other.venmoHandle;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, ratingCount.hashCode);
    _$hash = $jc(_$hash, reputationScore.hashCode);
    _$hash = $jc(_$hash, venmoHandle.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RunUserSummary')
          ..add('displayName', displayName)
          ..add('id', id)
          ..add('ratingCount', ratingCount)
          ..add('reputationScore', reputationScore)
          ..add('venmoHandle', venmoHandle))
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

  int? _ratingCount;
  int? get ratingCount => _$this._ratingCount;
  set ratingCount(int? ratingCount) => _$this._ratingCount = ratingCount;

  num? _reputationScore;
  num? get reputationScore => _$this._reputationScore;
  set reputationScore(num? reputationScore) =>
      _$this._reputationScore = reputationScore;

  String? _venmoHandle;
  String? get venmoHandle => _$this._venmoHandle;
  set venmoHandle(String? venmoHandle) => _$this._venmoHandle = venmoHandle;

  RunUserSummaryBuilder() {
    RunUserSummary._defaults(this);
  }

  RunUserSummaryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _displayName = $v.displayName;
      _id = $v.id;
      _ratingCount = $v.ratingCount;
      _reputationScore = $v.reputationScore;
      _venmoHandle = $v.venmoHandle;
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
    final _$result = _$v ??
        _$RunUserSummary._(
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName, r'RunUserSummary', 'displayName'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'RunUserSummary', 'id'),
          ratingCount: BuiltValueNullFieldError.checkNotNull(
              ratingCount, r'RunUserSummary', 'ratingCount'),
          reputationScore: BuiltValueNullFieldError.checkNotNull(
              reputationScore, r'RunUserSummary', 'reputationScore'),
          venmoHandle: venmoHandle,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
