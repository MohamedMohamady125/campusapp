// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_page_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RunPageResponse extends RunPageResponse {
  @override
  final BuiltList<RunResponse> items;
  @override
  final String? nextCursor;

  factory _$RunPageResponse([void Function(RunPageResponseBuilder)? updates]) =>
      (RunPageResponseBuilder()..update(updates))._build();

  _$RunPageResponse._({required this.items, this.nextCursor}) : super._();
  @override
  RunPageResponse rebuild(void Function(RunPageResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RunPageResponseBuilder toBuilder() => RunPageResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RunPageResponse &&
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
    return (newBuiltValueToStringHelper(r'RunPageResponse')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class RunPageResponseBuilder
    implements Builder<RunPageResponse, RunPageResponseBuilder> {
  _$RunPageResponse? _$v;

  ListBuilder<RunResponse>? _items;
  ListBuilder<RunResponse> get items =>
      _$this._items ??= ListBuilder<RunResponse>();
  set items(ListBuilder<RunResponse>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  RunPageResponseBuilder() {
    RunPageResponse._defaults(this);
  }

  RunPageResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RunPageResponse other) {
    _$v = other as _$RunPageResponse;
  }

  @override
  void update(void Function(RunPageResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RunPageResponse build() => _build();

  _$RunPageResponse _build() {
    _$RunPageResponse _$result;
    try {
      _$result = _$v ??
          _$RunPageResponse._(
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
            r'RunPageResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
