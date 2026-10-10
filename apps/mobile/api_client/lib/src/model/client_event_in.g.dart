// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_event_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ClientEventIn extends ClientEventIn {
  @override
  final int? durationMs;
  @override
  final String name;
  @override
  final DateTime occurredAt;
  @override
  final BuiltMap<String, PropertiesValue?>? properties;
  @override
  final String? screen;

  factory _$ClientEventIn([void Function(ClientEventInBuilder)? updates]) =>
      (ClientEventInBuilder()..update(updates))._build();

  _$ClientEventIn._(
      {this.durationMs,
      required this.name,
      required this.occurredAt,
      this.properties,
      this.screen})
      : super._();
  @override
  ClientEventIn rebuild(void Function(ClientEventInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClientEventInBuilder toBuilder() => ClientEventInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClientEventIn &&
        durationMs == other.durationMs &&
        name == other.name &&
        occurredAt == other.occurredAt &&
        properties == other.properties &&
        screen == other.screen;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, durationMs.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, occurredAt.hashCode);
    _$hash = $jc(_$hash, properties.hashCode);
    _$hash = $jc(_$hash, screen.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ClientEventIn')
          ..add('durationMs', durationMs)
          ..add('name', name)
          ..add('occurredAt', occurredAt)
          ..add('properties', properties)
          ..add('screen', screen))
        .toString();
  }
}

class ClientEventInBuilder
    implements Builder<ClientEventIn, ClientEventInBuilder> {
  _$ClientEventIn? _$v;

  int? _durationMs;
  int? get durationMs => _$this._durationMs;
  set durationMs(int? durationMs) => _$this._durationMs = durationMs;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  DateTime? _occurredAt;
  DateTime? get occurredAt => _$this._occurredAt;
  set occurredAt(DateTime? occurredAt) => _$this._occurredAt = occurredAt;

  MapBuilder<String, PropertiesValue?>? _properties;
  MapBuilder<String, PropertiesValue?> get properties =>
      _$this._properties ??= MapBuilder<String, PropertiesValue?>();
  set properties(MapBuilder<String, PropertiesValue?>? properties) =>
      _$this._properties = properties;

  String? _screen;
  String? get screen => _$this._screen;
  set screen(String? screen) => _$this._screen = screen;

  ClientEventInBuilder() {
    ClientEventIn._defaults(this);
  }

  ClientEventInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _durationMs = $v.durationMs;
      _name = $v.name;
      _occurredAt = $v.occurredAt;
      _properties = $v.properties?.toBuilder();
      _screen = $v.screen;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ClientEventIn other) {
    _$v = other as _$ClientEventIn;
  }

  @override
  void update(void Function(ClientEventInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClientEventIn build() => _build();

  _$ClientEventIn _build() {
    _$ClientEventIn _$result;
    try {
      _$result = _$v ??
          _$ClientEventIn._(
            durationMs: durationMs,
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'ClientEventIn', 'name'),
            occurredAt: BuiltValueNullFieldError.checkNotNull(
                occurredAt, r'ClientEventIn', 'occurredAt'),
            properties: _properties?.build(),
            screen: screen,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'properties';
        _properties?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ClientEventIn', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
