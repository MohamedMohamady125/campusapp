// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_proof_submit_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PaymentProofSubmitRequest extends PaymentProofSubmitRequest {
  @override
  final String? note;
  @override
  final String proofKey;

  factory _$PaymentProofSubmitRequest(
          [void Function(PaymentProofSubmitRequestBuilder)? updates]) =>
      (PaymentProofSubmitRequestBuilder()..update(updates))._build();

  _$PaymentProofSubmitRequest._({this.note, required this.proofKey})
      : super._();
  @override
  PaymentProofSubmitRequest rebuild(
          void Function(PaymentProofSubmitRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PaymentProofSubmitRequestBuilder toBuilder() =>
      PaymentProofSubmitRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaymentProofSubmitRequest &&
        note == other.note &&
        proofKey == other.proofKey;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, proofKey.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PaymentProofSubmitRequest')
          ..add('note', note)
          ..add('proofKey', proofKey))
        .toString();
  }
}

class PaymentProofSubmitRequestBuilder
    implements
        Builder<PaymentProofSubmitRequest, PaymentProofSubmitRequestBuilder> {
  _$PaymentProofSubmitRequest? _$v;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  String? _proofKey;
  String? get proofKey => _$this._proofKey;
  set proofKey(String? proofKey) => _$this._proofKey = proofKey;

  PaymentProofSubmitRequestBuilder() {
    PaymentProofSubmitRequest._defaults(this);
  }

  PaymentProofSubmitRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _note = $v.note;
      _proofKey = $v.proofKey;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PaymentProofSubmitRequest other) {
    _$v = other as _$PaymentProofSubmitRequest;
  }

  @override
  void update(void Function(PaymentProofSubmitRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaymentProofSubmitRequest build() => _build();

  _$PaymentProofSubmitRequest _build() {
    final _$result = _$v ??
        _$PaymentProofSubmitRequest._(
          note: note,
          proofKey: BuiltValueNullFieldError.checkNotNull(
              proofKey, r'PaymentProofSubmitRequest', 'proofKey'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
