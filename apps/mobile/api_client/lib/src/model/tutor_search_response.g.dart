// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutor_search_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TutorSearchResponse extends TutorSearchResponse {
  @override
  final CourseResponse course;
  @override
  final BuiltList<RankedTutorResponse> items;

  factory _$TutorSearchResponse(
          [void Function(TutorSearchResponseBuilder)? updates]) =>
      (TutorSearchResponseBuilder()..update(updates))._build();

  _$TutorSearchResponse._({required this.course, required this.items})
      : super._();
  @override
  TutorSearchResponse rebuild(
          void Function(TutorSearchResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TutorSearchResponseBuilder toBuilder() =>
      TutorSearchResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TutorSearchResponse &&
        course == other.course &&
        items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, course.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TutorSearchResponse')
          ..add('course', course)
          ..add('items', items))
        .toString();
  }
}

class TutorSearchResponseBuilder
    implements Builder<TutorSearchResponse, TutorSearchResponseBuilder> {
  _$TutorSearchResponse? _$v;

  CourseResponseBuilder? _course;
  CourseResponseBuilder get course =>
      _$this._course ??= CourseResponseBuilder();
  set course(CourseResponseBuilder? course) => _$this._course = course;

  ListBuilder<RankedTutorResponse>? _items;
  ListBuilder<RankedTutorResponse> get items =>
      _$this._items ??= ListBuilder<RankedTutorResponse>();
  set items(ListBuilder<RankedTutorResponse>? items) => _$this._items = items;

  TutorSearchResponseBuilder() {
    TutorSearchResponse._defaults(this);
  }

  TutorSearchResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _course = $v.course.toBuilder();
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TutorSearchResponse other) {
    _$v = other as _$TutorSearchResponse;
  }

  @override
  void update(void Function(TutorSearchResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TutorSearchResponse build() => _build();

  _$TutorSearchResponse _build() {
    _$TutorSearchResponse _$result;
    try {
      _$result = _$v ??
          _$TutorSearchResponse._(
            course: course.build(),
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'course';
        course.build();
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TutorSearchResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
