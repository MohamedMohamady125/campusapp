// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_page_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReportPageResponse extends ReportPageResponse {
  @override
  final BuiltList<ReportResponse> items;
  @override
  final String? nextCursor;

  factory _$ReportPageResponse(
          [void Function(ReportPageResponseBuilder)? updates]) =>
      (ReportPageResponseBuilder()..update(updates))._build();

  _$ReportPageResponse._({required this.items, this.nextCursor}) : super._();
  @override
  ReportPageResponse rebuild(
          void Function(ReportPageResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReportPageResponseBuilder toBuilder() =>
      ReportPageResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReportPageResponse &&
        items == other.items &&
        nextCursor == other.nextCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReportPageResponse')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class ReportPageResponseBuilder
    implements Builder<ReportPageResponse, ReportPageResponseBuilder> {
  _$ReportPageResponse? _$v;

  ListBuilder<ReportResponse>? _items;
  ListBuilder<ReportResponse> get items =>
      _$this._items ??= ListBuilder<ReportResponse>();
  set items(ListBuilder<ReportResponse>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  ReportPageResponseBuilder() {
    ReportPageResponse._defaults(this);
  }

  ReportPageResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReportPageResponse other) {
    _$v = other as _$ReportPageResponse;
  }

  @override
  void update(void Function(ReportPageResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReportPageResponse build() => _build();

  _$ReportPageResponse _build() {
    _$ReportPageResponse _$result;
    try {
      _$result = _$v ??
          _$ReportPageResponse._(
            items: items.build(),
            nextCursor: nextCursor,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ReportPageResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
