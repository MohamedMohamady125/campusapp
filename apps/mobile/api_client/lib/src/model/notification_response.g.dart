// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotificationResponse extends NotificationResponse {
  @override
  final DateTime createdAt;
  @override
  final String id;
  @override
  final BuiltMap<String, JsonObject?> payload;
  @override
  final DateTime? readAt;
  @override
  final String type;

  factory _$NotificationResponse(
          [void Function(NotificationResponseBuilder)? updates]) =>
      (NotificationResponseBuilder()..update(updates))._build();

  _$NotificationResponse._(
      {required this.createdAt,
      required this.id,
      required this.payload,
      this.readAt,
      required this.type})
      : super._();
  @override
  NotificationResponse rebuild(
          void Function(NotificationResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NotificationResponseBuilder toBuilder() =>
      NotificationResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationResponse &&
        createdAt == other.createdAt &&
        id == other.id &&
        payload == other.payload &&
        readAt == other.readAt &&
        type == other.type;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, payload.hashCode);
    _$hash = $jc(_$hash, readAt.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotificationResponse')
          ..add('createdAt', createdAt)
          ..add('id', id)
          ..add('payload', payload)
          ..add('readAt', readAt)
          ..add('type', type))
        .toString();
  }
}

class NotificationResponseBuilder
    implements Builder<NotificationResponse, NotificationResponseBuilder> {
  _$NotificationResponse? _$v;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  MapBuilder<String, JsonObject?>? _payload;
  MapBuilder<String, JsonObject?> get payload =>
      _$this._payload ??= MapBuilder<String, JsonObject?>();
  set payload(MapBuilder<String, JsonObject?>? payload) =>
      _$this._payload = payload;

  DateTime? _readAt;
  DateTime? get readAt => _$this._readAt;
  set readAt(DateTime? readAt) => _$this._readAt = readAt;

  String? _type;
  String? get type => _$this._type;
  set type(String? type) => _$this._type = type;

  NotificationResponseBuilder() {
    NotificationResponse._defaults(this);
  }

  NotificationResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _createdAt = $v.createdAt;
      _id = $v.id;
      _payload = $v.payload.toBuilder();
      _readAt = $v.readAt;
      _type = $v.type;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationResponse other) {
    _$v = other as _$NotificationResponse;
  }

  @override
  void update(void Function(NotificationResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationResponse build() => _build();

  _$NotificationResponse _build() {
    _$NotificationResponse _$result;
    try {
      _$result = _$v ??
          _$NotificationResponse._(
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'NotificationResponse', 'createdAt'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'NotificationResponse', 'id'),
            payload: payload.build(),
            readAt: readAt,
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'NotificationResponse', 'type'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payload';
        payload.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'NotificationResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
