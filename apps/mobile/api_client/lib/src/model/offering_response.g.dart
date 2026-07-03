// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offering_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OfferingResponse extends OfferingResponse {
  @override
  final bool active;
  @override
  final String? blurb;
  @override
  final CourseResponse course;
  @override
  final DateTime createdAt;
  @override
  final String gradeReceived;
  @override
  final String id;
  @override
  final String termTaken;
  @override
  final String tutorId;

  factory _$OfferingResponse(
          [void Function(OfferingResponseBuilder)? updates]) =>
      (OfferingResponseBuilder()..update(updates))._build();

  _$OfferingResponse._(
      {required this.active,
      this.blurb,
      required this.course,
      required this.createdAt,
      required this.gradeReceived,
      required this.id,
      required this.termTaken,
      required this.tutorId})
      : super._();
  @override
  OfferingResponse rebuild(void Function(OfferingResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OfferingResponseBuilder toBuilder() =>
      OfferingResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OfferingResponse &&
        active == other.active &&
        blurb == other.blurb &&
        course == other.course &&
        createdAt == other.createdAt &&
        gradeReceived == other.gradeReceived &&
        id == other.id &&
        termTaken == other.termTaken &&
        tutorId == other.tutorId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, active.hashCode);
    _$hash = $jc(_$hash, blurb.hashCode);
    _$hash = $jc(_$hash, course.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, gradeReceived.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, termTaken.hashCode);
    _$hash = $jc(_$hash, tutorId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OfferingResponse')
          ..add('active', active)
          ..add('blurb', blurb)
          ..add('course', course)
          ..add('createdAt', createdAt)
          ..add('gradeReceived', gradeReceived)
          ..add('id', id)
          ..add('termTaken', termTaken)
          ..add('tutorId', tutorId))
        .toString();
  }
}

class OfferingResponseBuilder
    implements Builder<OfferingResponse, OfferingResponseBuilder> {
  _$OfferingResponse? _$v;

  bool? _active;
  bool? get active => _$this._active;
  set active(bool? active) => _$this._active = active;

  String? _blurb;
  String? get blurb => _$this._blurb;
  set blurb(String? blurb) => _$this._blurb = blurb;

  CourseResponseBuilder? _course;
  CourseResponseBuilder get course =>
      _$this._course ??= CourseResponseBuilder();
  set course(CourseResponseBuilder? course) => _$this._course = course;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _gradeReceived;
  String? get gradeReceived => _$this._gradeReceived;
  set gradeReceived(String? gradeReceived) =>
      _$this._gradeReceived = gradeReceived;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _termTaken;
  String? get termTaken => _$this._termTaken;
  set termTaken(String? termTaken) => _$this._termTaken = termTaken;

  String? _tutorId;
  String? get tutorId => _$this._tutorId;
  set tutorId(String? tutorId) => _$this._tutorId = tutorId;

  OfferingResponseBuilder() {
    OfferingResponse._defaults(this);
  }

  OfferingResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _active = $v.active;
      _blurb = $v.blurb;
      _course = $v.course.toBuilder();
      _createdAt = $v.createdAt;
      _gradeReceived = $v.gradeReceived;
      _id = $v.id;
      _termTaken = $v.termTaken;
      _tutorId = $v.tutorId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OfferingResponse other) {
    _$v = other as _$OfferingResponse;
  }

  @override
  void update(void Function(OfferingResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OfferingResponse build() => _build();

  _$OfferingResponse _build() {
    _$OfferingResponse _$result;
    try {
      _$result = _$v ??
          _$OfferingResponse._(
            active: BuiltValueNullFieldError.checkNotNull(
                active, r'OfferingResponse', 'active'),
            blurb: blurb,
            course: course.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'OfferingResponse', 'createdAt'),
            gradeReceived: BuiltValueNullFieldError.checkNotNull(
                gradeReceived, r'OfferingResponse', 'gradeReceived'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'OfferingResponse', 'id'),
            termTaken: BuiltValueNullFieldError.checkNotNull(
                termTaken, r'OfferingResponse', 'termTaken'),
            tutorId: BuiltValueNullFieldError.checkNotNull(
                tutorId, r'OfferingResponse', 'tutorId'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'course';
        course.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OfferingResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
