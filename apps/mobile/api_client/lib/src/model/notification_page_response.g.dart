// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_page_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotificationPageResponse extends NotificationPageResponse {
  @override
  final BuiltList<NotificationResponse> items;
  @override
  final String? nextCursor;
  @override
  final int unreadCount;

  factory _$NotificationPageResponse(
          [void Function(NotificationPageResponseBuilder)? updates]) =>
      (NotificationPageResponseBuilder()..update(updates))._build();

  _$NotificationPageResponse._(
      {required this.items, this.nextCursor, required this.unreadCount})
      : super._();
  @override
  NotificationPageResponse rebuild(
          void Function(NotificationPageResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NotificationPageResponseBuilder toBuilder() =>
      NotificationPageResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationPageResponse &&
        items == other.items &&
        nextCursor == other.nextCursor &&
        unreadCount == other.unreadCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jc(_$hash, unreadCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotificationPageResponse')
          ..add('items', items)
          ..add('nextCursor', nextCursor)
          ..add('unreadCount', unreadCount))
        .toString();
  }
}

class NotificationPageResponseBuilder
    implements
        Builder<NotificationPageResponse, NotificationPageResponseBuilder> {
  _$NotificationPageResponse? _$v;

  ListBuilder<NotificationResponse>? _items;
  ListBuilder<NotificationResponse> get items =>
      _$this._items ??= ListBuilder<NotificationResponse>();
  set items(ListBuilder<NotificationResponse>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  int? _unreadCount;
  int? get unreadCount => _$this._unreadCount;
  set unreadCount(int? unreadCount) => _$this._unreadCount = unreadCount;

  NotificationPageResponseBuilder() {
    NotificationPageResponse._defaults(this);
  }

  NotificationPageResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _unreadCount = $v.unreadCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationPageResponse other) {
    _$v = other as _$NotificationPageResponse;
  }

  @override
  void update(void Function(NotificationPageResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationPageResponse build() => _build();

  _$NotificationPageResponse _build() {
    _$NotificationPageResponse _$result;
    try {
      _$result = _$v ??
          _$NotificationPageResponse._(
            items: items.build(),
            nextCursor: nextCursor,
            unreadCount: BuiltValueNullFieldError.checkNotNull(
                unreadCount, r'NotificationPageResponse', 'unreadCount'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'NotificationPageResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
