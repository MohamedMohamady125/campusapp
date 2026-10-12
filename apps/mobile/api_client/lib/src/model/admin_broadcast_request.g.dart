// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_broadcast_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminBroadcastRequest extends AdminBroadcastRequest {
  @override
  final String? body;
  @override
  final BuiltList<String>? emails;
  @override
  final String title;

  factory _$AdminBroadcastRequest(
          [void Function(AdminBroadcastRequestBuilder)? updates]) =>
      (AdminBroadcastRequestBuilder()..update(updates))._build();

  _$AdminBroadcastRequest._({this.body, this.emails, required this.title})
      : super._();
  @override
  AdminBroadcastRequest rebuild(
          void Function(AdminBroadcastRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminBroadcastRequestBuilder toBuilder() =>
      AdminBroadcastRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminBroadcastRequest &&
        body == other.body &&
        emails == other.emails &&
        title == other.title;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jc(_$hash, emails.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminBroadcastRequest')
          ..add('body', body)
          ..add('emails', emails)
          ..add('title', title))
        .toString();
  }
}

class AdminBroadcastRequestBuilder
    implements Builder<AdminBroadcastRequest, AdminBroadcastRequestBuilder> {
  _$AdminBroadcastRequest? _$v;

  String? _body;
  String? get body => _$this._body;
  set body(String? body) => _$this._body = body;

  ListBuilder<String>? _emails;
  ListBuilder<String> get emails => _$this._emails ??= ListBuilder<String>();
  set emails(ListBuilder<String>? emails) => _$this._emails = emails;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  AdminBroadcastRequestBuilder() {
    AdminBroadcastRequest._defaults(this);
  }

  AdminBroadcastRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _body = $v.body;
      _emails = $v.emails?.toBuilder();
      _title = $v.title;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminBroadcastRequest other) {
    _$v = other as _$AdminBroadcastRequest;
  }

  @override
  void update(void Function(AdminBroadcastRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminBroadcastRequest build() => _build();

  _$AdminBroadcastRequest _build() {
    _$AdminBroadcastRequest _$result;
    try {
      _$result = _$v ??
          _$AdminBroadcastRequest._(
            body: body,
            emails: _emails?.build(),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'AdminBroadcastRequest', 'title'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'emails';
        _emails?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AdminBroadcastRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
