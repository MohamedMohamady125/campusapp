// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CourseResponse extends CourseResponse {
  @override
  final String code;
  @override
  final String department;
  @override
  final String id;
  @override
  final String title;

  factory _$CourseResponse([void Function(CourseResponseBuilder)? updates]) =>
      (CourseResponseBuilder()..update(updates))._build();

  _$CourseResponse._(
      {required this.code,
      required this.department,
      required this.id,
      required this.title})
      : super._();
  @override
  CourseResponse rebuild(void Function(CourseResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CourseResponseBuilder toBuilder() => CourseResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CourseResponse &&
        code == other.code &&
        department == other.department &&
        id == other.id &&
        title == other.title;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, department.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CourseResponse')
          ..add('code', code)
          ..add('department', department)
          ..add('id', id)
          ..add('title', title))
        .toString();
  }
}

class CourseResponseBuilder
    implements Builder<CourseResponse, CourseResponseBuilder> {
  _$CourseResponse? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _department;
  String? get department => _$this._department;
  set department(String? department) => _$this._department = department;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  CourseResponseBuilder() {
    CourseResponse._defaults(this);
  }

  CourseResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _department = $v.department;
      _id = $v.id;
      _title = $v.title;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CourseResponse other) {
    _$v = other as _$CourseResponse;
  }

  @override
  void update(void Function(CourseResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CourseResponse build() => _build();

  _$CourseResponse _build() {
    final _$result = _$v ??
        _$CourseResponse._(
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'CourseResponse', 'code'),
          department: BuiltValueNullFieldError.checkNotNull(
              department, r'CourseResponse', 'department'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'CourseResponse', 'id'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'CourseResponse', 'title'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
