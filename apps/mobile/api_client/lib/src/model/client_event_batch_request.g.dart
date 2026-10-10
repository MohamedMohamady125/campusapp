// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_event_batch_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ClientEventBatchRequestPlatformEnum
    _$clientEventBatchRequestPlatformEnum_ios =
    const ClientEventBatchRequestPlatformEnum._('ios');
const ClientEventBatchRequestPlatformEnum
    _$clientEventBatchRequestPlatformEnum_android =
    const ClientEventBatchRequestPlatformEnum._('android');
const ClientEventBatchRequestPlatformEnum
    _$clientEventBatchRequestPlatformEnum_web =
    const ClientEventBatchRequestPlatformEnum._('web');

ClientEventBatchRequestPlatformEnum
    _$clientEventBatchRequestPlatformEnumValueOf(String name) {
  switch (name) {
    case 'ios':
      return _$clientEventBatchRequestPlatformEnum_ios;
    case 'android':
      return _$clientEventBatchRequestPlatformEnum_android;
    case 'web':
      return _$clientEventBatchRequestPlatformEnum_web;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ClientEventBatchRequestPlatformEnum>
    _$clientEventBatchRequestPlatformEnumValues = BuiltSet<
        ClientEventBatchRequestPlatformEnum>(const <ClientEventBatchRequestPlatformEnum>[
  _$clientEventBatchRequestPlatformEnum_ios,
  _$clientEventBatchRequestPlatformEnum_android,
  _$clientEventBatchRequestPlatformEnum_web,
]);

Serializer<ClientEventBatchRequestPlatformEnum>
    _$clientEventBatchRequestPlatformEnumSerializer =
    _$ClientEventBatchRequestPlatformEnumSerializer();

class _$ClientEventBatchRequestPlatformEnumSerializer
    implements PrimitiveSerializer<ClientEventBatchRequestPlatformEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ios': 'ios',
    'android': 'android',
    'web': 'web',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ios': 'ios',
    'android': 'android',
    'web': 'web',
  };

  @override
  final Iterable<Type> types = const <Type>[
    ClientEventBatchRequestPlatformEnum
  ];
  @override
  final String wireName = 'ClientEventBatchRequestPlatformEnum';

  @override
  Object serialize(
          Serializers serializers, ClientEventBatchRequestPlatformEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ClientEventBatchRequestPlatformEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ClientEventBatchRequestPlatformEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ClientEventBatchRequest extends ClientEventBatchRequest {
  @override
  final BuiltList<ClientEventIn> events;
  @override
  final ClientEventBatchRequestPlatformEnum platform;
  @override
  final String sessionId;

  factory _$ClientEventBatchRequest(
          [void Function(ClientEventBatchRequestBuilder)? updates]) =>
      (ClientEventBatchRequestBuilder()..update(updates))._build();

  _$ClientEventBatchRequest._(
      {required this.events, required this.platform, required this.sessionId})
      : super._();
  @override
  ClientEventBatchRequest rebuild(
          void Function(ClientEventBatchRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClientEventBatchRequestBuilder toBuilder() =>
      ClientEventBatchRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClientEventBatchRequest &&
        events == other.events &&
        platform == other.platform &&
        sessionId == other.sessionId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, events.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, sessionId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ClientEventBatchRequest')
          ..add('events', events)
          ..add('platform', platform)
          ..add('sessionId', sessionId))
        .toString();
  }
}

class ClientEventBatchRequestBuilder
    implements
        Builder<ClientEventBatchRequest, ClientEventBatchRequestBuilder> {
  _$ClientEventBatchRequest? _$v;

  ListBuilder<ClientEventIn>? _events;
  ListBuilder<ClientEventIn> get events =>
      _$this._events ??= ListBuilder<ClientEventIn>();
  set events(ListBuilder<ClientEventIn>? events) => _$this._events = events;

  ClientEventBatchRequestPlatformEnum? _platform;
  ClientEventBatchRequestPlatformEnum? get platform => _$this._platform;
  set platform(ClientEventBatchRequestPlatformEnum? platform) =>
      _$this._platform = platform;

  String? _sessionId;
  String? get sessionId => _$this._sessionId;
  set sessionId(String? sessionId) => _$this._sessionId = sessionId;

  ClientEventBatchRequestBuilder() {
    ClientEventBatchRequest._defaults(this);
  }

  ClientEventBatchRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _events = $v.events.toBuilder();
      _platform = $v.platform;
      _sessionId = $v.sessionId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ClientEventBatchRequest other) {
    _$v = other as _$ClientEventBatchRequest;
  }

  @override
  void update(void Function(ClientEventBatchRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClientEventBatchRequest build() => _build();

  _$ClientEventBatchRequest _build() {
    _$ClientEventBatchRequest _$result;
    try {
      _$result = _$v ??
          _$ClientEventBatchRequest._(
            events: events.build(),
            platform: BuiltValueNullFieldError.checkNotNull(
                platform, r'ClientEventBatchRequest', 'platform'),
            sessionId: BuiltValueNullFieldError.checkNotNull(
                sessionId, r'ClientEventBatchRequest', 'sessionId'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'events';
        events.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ClientEventBatchRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
