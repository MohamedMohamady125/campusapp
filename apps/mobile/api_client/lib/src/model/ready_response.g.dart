// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ready_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ReadyResponseStatusEnum _$readyResponseStatusEnum_ok =
    const ReadyResponseStatusEnum._('ok');
const ReadyResponseStatusEnum _$readyResponseStatusEnum_degraded =
    const ReadyResponseStatusEnum._('degraded');

ReadyResponseStatusEnum _$readyResponseStatusEnumValueOf(String name) {
  switch (name) {
    case 'ok':
      return _$readyResponseStatusEnum_ok;
    case 'degraded':
      return _$readyResponseStatusEnum_degraded;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ReadyResponseStatusEnum> _$readyResponseStatusEnumValues =
    BuiltSet<ReadyResponseStatusEnum>(const <ReadyResponseStatusEnum>[
  _$readyResponseStatusEnum_ok,
  _$readyResponseStatusEnum_degraded,
]);

Serializer<ReadyResponseStatusEnum> _$readyResponseStatusEnumSerializer =
    _$ReadyResponseStatusEnumSerializer();

class _$ReadyResponseStatusEnumSerializer
    implements PrimitiveSerializer<ReadyResponseStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ok': 'ok',
    'degraded': 'degraded',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ok': 'ok',
    'degraded': 'degraded',
  };

  @override
  final Iterable<Type> types = const <Type>[ReadyResponseStatusEnum];
  @override
  final String wireName = 'ReadyResponseStatusEnum';

  @override
  Object serialize(Serializers serializers, ReadyResponseStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ReadyResponseStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ReadyResponseStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ReadyResponse extends ReadyResponse {
  @override
  final bool database;
  @override
  final bool redis;
  @override
  final ReadyResponseStatusEnum status;

  factory _$ReadyResponse([void Function(ReadyResponseBuilder)? updates]) =>
      (ReadyResponseBuilder()..update(updates))._build();

  _$ReadyResponse._(
      {required this.database, required this.redis, required this.status})
      : super._();
  @override
  ReadyResponse rebuild(void Function(ReadyResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReadyResponseBuilder toBuilder() => ReadyResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReadyResponse &&
        database == other.database &&
        redis == other.redis &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, database.hashCode);
    _$hash = $jc(_$hash, redis.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReadyResponse')
          ..add('database', database)
          ..add('redis', redis)
          ..add('status', status))
        .toString();
  }
}

class ReadyResponseBuilder
    implements Builder<ReadyResponse, ReadyResponseBuilder> {
  _$ReadyResponse? _$v;

  bool? _database;
  bool? get database => _$this._database;
  set database(bool? database) => _$this._database = database;

  bool? _redis;
  bool? get redis => _$this._redis;
  set redis(bool? redis) => _$this._redis = redis;

  ReadyResponseStatusEnum? _status;
  ReadyResponseStatusEnum? get status => _$this._status;
  set status(ReadyResponseStatusEnum? status) => _$this._status = status;

  ReadyResponseBuilder() {
    ReadyResponse._defaults(this);
  }

  ReadyResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _database = $v.database;
      _redis = $v.redis;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReadyResponse other) {
    _$v = other as _$ReadyResponse;
  }

  @override
  void update(void Function(ReadyResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReadyResponse build() => _build();

  _$ReadyResponse _build() {
    final _$result = _$v ??
        _$ReadyResponse._(
          database: BuiltValueNullFieldError.checkNotNull(
              database, r'ReadyResponse', 'database'),
          redis: BuiltValueNullFieldError.checkNotNull(
              redis, r'ReadyResponse', 'redis'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'ReadyResponse', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
