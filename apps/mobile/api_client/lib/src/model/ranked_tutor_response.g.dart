// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ranked_tutor_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RankedTutorResponse extends RankedTutorResponse {
  @override
  final OfferingResponse offering;
  @override
  final bool? premium;
  @override
  final num recencyNorm;
  @override
  final num reputationNorm;
  @override
  final num responsivenessNorm;
  @override
  final num score;
  @override
  final UserPublicResponse tutor;

  factory _$RankedTutorResponse(
          [void Function(RankedTutorResponseBuilder)? updates]) =>
      (RankedTutorResponseBuilder()..update(updates))._build();

  _$RankedTutorResponse._(
      {required this.offering,
      this.premium,
      required this.recencyNorm,
      required this.reputationNorm,
      required this.responsivenessNorm,
      required this.score,
      required this.tutor})
      : super._();
  @override
  RankedTutorResponse rebuild(
          void Function(RankedTutorResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RankedTutorResponseBuilder toBuilder() =>
      RankedTutorResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RankedTutorResponse &&
        offering == other.offering &&
        premium == other.premium &&
        recencyNorm == other.recencyNorm &&
        reputationNorm == other.reputationNorm &&
        responsivenessNorm == other.responsivenessNorm &&
        score == other.score &&
        tutor == other.tutor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, offering.hashCode);
    _$hash = $jc(_$hash, premium.hashCode);
    _$hash = $jc(_$hash, recencyNorm.hashCode);
    _$hash = $jc(_$hash, reputationNorm.hashCode);
    _$hash = $jc(_$hash, responsivenessNorm.hashCode);
    _$hash = $jc(_$hash, score.hashCode);
    _$hash = $jc(_$hash, tutor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RankedTutorResponse')
          ..add('offering', offering)
          ..add('premium', premium)
          ..add('recencyNorm', recencyNorm)
          ..add('reputationNorm', reputationNorm)
          ..add('responsivenessNorm', responsivenessNorm)
          ..add('score', score)
          ..add('tutor', tutor))
        .toString();
  }
}

class RankedTutorResponseBuilder
    implements Builder<RankedTutorResponse, RankedTutorResponseBuilder> {
  _$RankedTutorResponse? _$v;

  OfferingResponseBuilder? _offering;
  OfferingResponseBuilder get offering =>
      _$this._offering ??= OfferingResponseBuilder();
  set offering(OfferingResponseBuilder? offering) =>
      _$this._offering = offering;

  bool? _premium;
  bool? get premium => _$this._premium;
  set premium(bool? premium) => _$this._premium = premium;

  num? _recencyNorm;
  num? get recencyNorm => _$this._recencyNorm;
  set recencyNorm(num? recencyNorm) => _$this._recencyNorm = recencyNorm;

  num? _reputationNorm;
  num? get reputationNorm => _$this._reputationNorm;
  set reputationNorm(num? reputationNorm) =>
      _$this._reputationNorm = reputationNorm;

  num? _responsivenessNorm;
  num? get responsivenessNorm => _$this._responsivenessNorm;
  set responsivenessNorm(num? responsivenessNorm) =>
      _$this._responsivenessNorm = responsivenessNorm;

  num? _score;
  num? get score => _$this._score;
  set score(num? score) => _$this._score = score;

  UserPublicResponseBuilder? _tutor;
  UserPublicResponseBuilder get tutor =>
      _$this._tutor ??= UserPublicResponseBuilder();
  set tutor(UserPublicResponseBuilder? tutor) => _$this._tutor = tutor;

  RankedTutorResponseBuilder() {
    RankedTutorResponse._defaults(this);
  }

  RankedTutorResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _offering = $v.offering.toBuilder();
      _premium = $v.premium;
      _recencyNorm = $v.recencyNorm;
      _reputationNorm = $v.reputationNorm;
      _responsivenessNorm = $v.responsivenessNorm;
      _score = $v.score;
      _tutor = $v.tutor.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RankedTutorResponse other) {
    _$v = other as _$RankedTutorResponse;
  }

  @override
  void update(void Function(RankedTutorResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RankedTutorResponse build() => _build();

  _$RankedTutorResponse _build() {
    _$RankedTutorResponse _$result;
    try {
      _$result = _$v ??
          _$RankedTutorResponse._(
            offering: offering.build(),
            premium: premium,
            recencyNorm: BuiltValueNullFieldError.checkNotNull(
                recencyNorm, r'RankedTutorResponse', 'recencyNorm'),
            reputationNorm: BuiltValueNullFieldError.checkNotNull(
                reputationNorm, r'RankedTutorResponse', 'reputationNorm'),
            responsivenessNorm: BuiltValueNullFieldError.checkNotNull(
                responsivenessNorm,
                r'RankedTutorResponse',
                'responsivenessNorm'),
            score: BuiltValueNullFieldError.checkNotNull(
                score, r'RankedTutorResponse', 'score'),
            tutor: tutor.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'offering';
        offering.build();

        _$failedField = 'tutor';
        tutor.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RankedTutorResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
