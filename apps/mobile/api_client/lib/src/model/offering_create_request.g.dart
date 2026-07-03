// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offering_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OfferingCreateRequestGradeReceivedEnum
    _$offeringCreateRequestGradeReceivedEnum_aPlus =
    const OfferingCreateRequestGradeReceivedEnum._('aPlus');
const OfferingCreateRequestGradeReceivedEnum
    _$offeringCreateRequestGradeReceivedEnum_A =
    const OfferingCreateRequestGradeReceivedEnum._('A');
const OfferingCreateRequestGradeReceivedEnum
    _$offeringCreateRequestGradeReceivedEnum_A_ =
    const OfferingCreateRequestGradeReceivedEnum._('A_');
const OfferingCreateRequestGradeReceivedEnum
    _$offeringCreateRequestGradeReceivedEnum_bPlus =
    const OfferingCreateRequestGradeReceivedEnum._('bPlus');
const OfferingCreateRequestGradeReceivedEnum
    _$offeringCreateRequestGradeReceivedEnum_B =
    const OfferingCreateRequestGradeReceivedEnum._('B');
const OfferingCreateRequestGradeReceivedEnum
    _$offeringCreateRequestGradeReceivedEnum_B_ =
    const OfferingCreateRequestGradeReceivedEnum._('B_');

OfferingCreateRequestGradeReceivedEnum
    _$offeringCreateRequestGradeReceivedEnumValueOf(String name) {
  switch (name) {
    case 'aPlus':
      return _$offeringCreateRequestGradeReceivedEnum_aPlus;
    case 'A':
      return _$offeringCreateRequestGradeReceivedEnum_A;
    case 'A_':
      return _$offeringCreateRequestGradeReceivedEnum_A_;
    case 'bPlus':
      return _$offeringCreateRequestGradeReceivedEnum_bPlus;
    case 'B':
      return _$offeringCreateRequestGradeReceivedEnum_B;
    case 'B_':
      return _$offeringCreateRequestGradeReceivedEnum_B_;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OfferingCreateRequestGradeReceivedEnum>
    _$offeringCreateRequestGradeReceivedEnumValues = BuiltSet<
        OfferingCreateRequestGradeReceivedEnum>(const <OfferingCreateRequestGradeReceivedEnum>[
  _$offeringCreateRequestGradeReceivedEnum_aPlus,
  _$offeringCreateRequestGradeReceivedEnum_A,
  _$offeringCreateRequestGradeReceivedEnum_A_,
  _$offeringCreateRequestGradeReceivedEnum_bPlus,
  _$offeringCreateRequestGradeReceivedEnum_B,
  _$offeringCreateRequestGradeReceivedEnum_B_,
]);

Serializer<OfferingCreateRequestGradeReceivedEnum>
    _$offeringCreateRequestGradeReceivedEnumSerializer =
    _$OfferingCreateRequestGradeReceivedEnumSerializer();

class _$OfferingCreateRequestGradeReceivedEnumSerializer
    implements PrimitiveSerializer<OfferingCreateRequestGradeReceivedEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'aPlus': 'A+',
    'A': 'A',
    'A_': 'A-',
    'bPlus': 'B+',
    'B': 'B',
    'B_': 'B-',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'A+': 'aPlus',
    'A': 'A',
    'A-': 'A_',
    'B+': 'bPlus',
    'B': 'B',
    'B-': 'B_',
  };

  @override
  final Iterable<Type> types = const <Type>[
    OfferingCreateRequestGradeReceivedEnum
  ];
  @override
  final String wireName = 'OfferingCreateRequestGradeReceivedEnum';

  @override
  Object serialize(Serializers serializers,
          OfferingCreateRequestGradeReceivedEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OfferingCreateRequestGradeReceivedEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OfferingCreateRequestGradeReceivedEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OfferingCreateRequest extends OfferingCreateRequest {
  @override
  final String? blurb;
  @override
  final String courseId;
  @override
  final OfferingCreateRequestGradeReceivedEnum gradeReceived;
  @override
  final String termTaken;

  factory _$OfferingCreateRequest(
          [void Function(OfferingCreateRequestBuilder)? updates]) =>
      (OfferingCreateRequestBuilder()..update(updates))._build();

  _$OfferingCreateRequest._(
      {this.blurb,
      required this.courseId,
      required this.gradeReceived,
      required this.termTaken})
      : super._();
  @override
  OfferingCreateRequest rebuild(
          void Function(OfferingCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OfferingCreateRequestBuilder toBuilder() =>
      OfferingCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OfferingCreateRequest &&
        blurb == other.blurb &&
        courseId == other.courseId &&
        gradeReceived == other.gradeReceived &&
        termTaken == other.termTaken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, blurb.hashCode);
    _$hash = $jc(_$hash, courseId.hashCode);
    _$hash = $jc(_$hash, gradeReceived.hashCode);
    _$hash = $jc(_$hash, termTaken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OfferingCreateRequest')
          ..add('blurb', blurb)
          ..add('courseId', courseId)
          ..add('gradeReceived', gradeReceived)
          ..add('termTaken', termTaken))
        .toString();
  }
}

class OfferingCreateRequestBuilder
    implements Builder<OfferingCreateRequest, OfferingCreateRequestBuilder> {
  _$OfferingCreateRequest? _$v;

  String? _blurb;
  String? get blurb => _$this._blurb;
  set blurb(String? blurb) => _$this._blurb = blurb;

  String? _courseId;
  String? get courseId => _$this._courseId;
  set courseId(String? courseId) => _$this._courseId = courseId;

  OfferingCreateRequestGradeReceivedEnum? _gradeReceived;
  OfferingCreateRequestGradeReceivedEnum? get gradeReceived =>
      _$this._gradeReceived;
  set gradeReceived(OfferingCreateRequestGradeReceivedEnum? gradeReceived) =>
      _$this._gradeReceived = gradeReceived;

  String? _termTaken;
  String? get termTaken => _$this._termTaken;
  set termTaken(String? termTaken) => _$this._termTaken = termTaken;

  OfferingCreateRequestBuilder() {
    OfferingCreateRequest._defaults(this);
  }

  OfferingCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _blurb = $v.blurb;
      _courseId = $v.courseId;
      _gradeReceived = $v.gradeReceived;
      _termTaken = $v.termTaken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OfferingCreateRequest other) {
    _$v = other as _$OfferingCreateRequest;
  }

  @override
  void update(void Function(OfferingCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OfferingCreateRequest build() => _build();

  _$OfferingCreateRequest _build() {
    final _$result = _$v ??
        _$OfferingCreateRequest._(
          blurb: blurb,
          courseId: BuiltValueNullFieldError.checkNotNull(
              courseId, r'OfferingCreateRequest', 'courseId'),
          gradeReceived: BuiltValueNullFieldError.checkNotNull(
              gradeReceived, r'OfferingCreateRequest', 'gradeReceived'),
          termTaken: BuiltValueNullFieldError.checkNotNull(
              termTaken, r'OfferingCreateRequest', 'termTaken'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
