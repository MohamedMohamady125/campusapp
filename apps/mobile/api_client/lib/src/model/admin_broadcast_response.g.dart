// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_broadcast_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminBroadcastResponse extends AdminBroadcastResponse {
  @override
  final int sent;
  @override
  final BuiltList<String> unknownEmails;

  factory _$AdminBroadcastResponse(
          [void Function(AdminBroadcastResponseBuilder)? updates]) =>
      (AdminBroadcastResponseBuilder()..update(updates))._build();

  _$AdminBroadcastResponse._({required this.sent, required this.unknownEmails})
      : super._();
  @override
  AdminBroadcastResponse rebuild(
          void Function(AdminBroadcastResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminBroadcastResponseBuilder toBuilder() =>
      AdminBroadcastResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminBroadcastResponse &&
        sent == other.sent &&
        unknownEmails == other.unknownEmails;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sent.hashCode);
    _$hash = $jc(_$hash, unknownEmails.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminBroadcastResponse')
          ..add('sent', sent)
          ..add('unknownEmails', unknownEmails))
        .toString();
  }
}

class AdminBroadcastResponseBuilder
    implements Builder<AdminBroadcastResponse, AdminBroadcastResponseBuilder> {
  _$AdminBroadcastResponse? _$v;

  int? _sent;
  int? get sent => _$this._sent;
  set sent(int? sent) => _$this._sent = sent;

  ListBuilder<String>? _unknownEmails;
  ListBuilder<String> get unknownEmails =>
      _$this._unknownEmails ??= ListBuilder<String>();
  set unknownEmails(ListBuilder<String>? unknownEmails) =>
      _$this._unknownEmails = unknownEmails;

  AdminBroadcastResponseBuilder() {
    AdminBroadcastResponse._defaults(this);
  }

  AdminBroadcastResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sent = $v.sent;
      _unknownEmails = $v.unknownEmails.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminBroadcastResponse other) {
    _$v = other as _$AdminBroadcastResponse;
  }

  @override
  void update(void Function(AdminBroadcastResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminBroadcastResponse build() => _build();

  _$AdminBroadcastResponse _build() {
    _$AdminBroadcastResponse _$result;
    try {
      _$result = _$v ??
          _$AdminBroadcastResponse._(
            sent: BuiltValueNullFieldError.checkNotNull(
                sent, r'AdminBroadcastResponse', 'sent'),
            unknownEmails: unknownEmails.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'unknownEmails';
        unknownEmails.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AdminBroadcastResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
