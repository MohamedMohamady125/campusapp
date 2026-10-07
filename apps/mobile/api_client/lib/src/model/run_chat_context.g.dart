// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_chat_context.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RunChatContext extends RunChatContext {
  @override
  final String dropoff;
  @override
  final int feeCents;
  @override
  final String orderId;
  @override
  final String orderText;
  @override
  final String runId;
  @override
  final String? spotImageUrl;
  @override
  final String spotName;

  factory _$RunChatContext([void Function(RunChatContextBuilder)? updates]) =>
      (RunChatContextBuilder()..update(updates))._build();

  _$RunChatContext._(
      {required this.dropoff,
      required this.feeCents,
      required this.orderId,
      required this.orderText,
      required this.runId,
      this.spotImageUrl,
      required this.spotName})
      : super._();
  @override
  RunChatContext rebuild(void Function(RunChatContextBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RunChatContextBuilder toBuilder() => RunChatContextBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RunChatContext &&
        dropoff == other.dropoff &&
        feeCents == other.feeCents &&
        orderId == other.orderId &&
        orderText == other.orderText &&
        runId == other.runId &&
        spotImageUrl == other.spotImageUrl &&
        spotName == other.spotName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, dropoff.hashCode);
    _$hash = $jc(_$hash, feeCents.hashCode);
    _$hash = $jc(_$hash, orderId.hashCode);
    _$hash = $jc(_$hash, orderText.hashCode);
    _$hash = $jc(_$hash, runId.hashCode);
    _$hash = $jc(_$hash, spotImageUrl.hashCode);
    _$hash = $jc(_$hash, spotName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RunChatContext')
          ..add('dropoff', dropoff)
          ..add('feeCents', feeCents)
          ..add('orderId', orderId)
          ..add('orderText', orderText)
          ..add('runId', runId)
          ..add('spotImageUrl', spotImageUrl)
          ..add('spotName', spotName))
        .toString();
  }
}

class RunChatContextBuilder
    implements Builder<RunChatContext, RunChatContextBuilder> {
  _$RunChatContext? _$v;

  String? _dropoff;
  String? get dropoff => _$this._dropoff;
  set dropoff(String? dropoff) => _$this._dropoff = dropoff;

  int? _feeCents;
  int? get feeCents => _$this._feeCents;
  set feeCents(int? feeCents) => _$this._feeCents = feeCents;

  String? _orderId;
  String? get orderId => _$this._orderId;
  set orderId(String? orderId) => _$this._orderId = orderId;

  String? _orderText;
  String? get orderText => _$this._orderText;
  set orderText(String? orderText) => _$this._orderText = orderText;

  String? _runId;
  String? get runId => _$this._runId;
  set runId(String? runId) => _$this._runId = runId;

  String? _spotImageUrl;
  String? get spotImageUrl => _$this._spotImageUrl;
  set spotImageUrl(String? spotImageUrl) => _$this._spotImageUrl = spotImageUrl;

  String? _spotName;
  String? get spotName => _$this._spotName;
  set spotName(String? spotName) => _$this._spotName = spotName;

  RunChatContextBuilder() {
    RunChatContext._defaults(this);
  }

  RunChatContextBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _dropoff = $v.dropoff;
      _feeCents = $v.feeCents;
      _orderId = $v.orderId;
      _orderText = $v.orderText;
      _runId = $v.runId;
      _spotImageUrl = $v.spotImageUrl;
      _spotName = $v.spotName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RunChatContext other) {
    _$v = other as _$RunChatContext;
  }

  @override
  void update(void Function(RunChatContextBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RunChatContext build() => _build();

  _$RunChatContext _build() {
    final _$result = _$v ??
        _$RunChatContext._(
          dropoff: BuiltValueNullFieldError.checkNotNull(
              dropoff, r'RunChatContext', 'dropoff'),
          feeCents: BuiltValueNullFieldError.checkNotNull(
              feeCents, r'RunChatContext', 'feeCents'),
          orderId: BuiltValueNullFieldError.checkNotNull(
              orderId, r'RunChatContext', 'orderId'),
          orderText: BuiltValueNullFieldError.checkNotNull(
              orderText, r'RunChatContext', 'orderText'),
          runId: BuiltValueNullFieldError.checkNotNull(
              runId, r'RunChatContext', 'runId'),
          spotImageUrl: spotImageUrl,
          spotName: BuiltValueNullFieldError.checkNotNull(
              spotName, r'RunChatContext', 'spotName'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
