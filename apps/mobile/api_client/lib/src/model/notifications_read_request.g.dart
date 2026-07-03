// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_read_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotificationsReadRequest extends NotificationsReadRequest {
  @override
  final BuiltList<String>? ids;

  factory _$NotificationsReadRequest(
          [void Function(NotificationsReadRequestBuilder)? updates]) =>
      (NotificationsReadRequestBuilder()..update(updates))._build();

  _$NotificationsReadRequest._({this.ids}) : super._();
  @override
  NotificationsReadRequest rebuild(
          void Function(NotificationsReadRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NotificationsReadRequestBuilder toBuilder() =>
      NotificationsReadRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationsReadRequest && ids == other.ids;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ids.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotificationsReadRequest')
          ..add('ids', ids))
        .toString();
  }
}

class NotificationsReadRequestBuilder
    implements
        Builder<NotificationsReadRequest, NotificationsReadRequestBuilder> {
  _$NotificationsReadRequest? _$v;

  ListBuilder<String>? _ids;
  ListBuilder<String> get ids => _$this._ids ??= ListBuilder<String>();
  set ids(ListBuilder<String>? ids) => _$this._ids = ids;

  NotificationsReadRequestBuilder() {
    NotificationsReadRequest._defaults(this);
  }

  NotificationsReadRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ids = $v.ids?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationsReadRequest other) {
    _$v = other as _$NotificationsReadRequest;
  }

  @override
  void update(void Function(NotificationsReadRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationsReadRequest build() => _build();

  _$NotificationsReadRequest _build() {
    _$NotificationsReadRequest _$result;
    try {
      _$result = _$v ??
          _$NotificationsReadRequest._(
            ids: _ids?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'ids';
        _ids?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'NotificationsReadRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
