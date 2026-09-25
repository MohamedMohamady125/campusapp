// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dropoff_location_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DropoffLocationCreateRequest extends DropoffLocationCreateRequest {
  @override
  final String? description;
  @override
  final num? lat;
  @override
  final num? lng;
  @override
  final String name;

  factory _$DropoffLocationCreateRequest(
          [void Function(DropoffLocationCreateRequestBuilder)? updates]) =>
      (DropoffLocationCreateRequestBuilder()..update(updates))._build();

  _$DropoffLocationCreateRequest._(
      {this.description, this.lat, this.lng, required this.name})
      : super._();
  @override
  DropoffLocationCreateRequest rebuild(
          void Function(DropoffLocationCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DropoffLocationCreateRequestBuilder toBuilder() =>
      DropoffLocationCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DropoffLocationCreateRequest &&
        description == other.description &&
        lat == other.lat &&
        lng == other.lng &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, lat.hashCode);
    _$hash = $jc(_$hash, lng.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DropoffLocationCreateRequest')
          ..add('description', description)
          ..add('lat', lat)
          ..add('lng', lng)
          ..add('name', name))
        .toString();
  }
}

class DropoffLocationCreateRequestBuilder
    implements
        Builder<DropoffLocationCreateRequest,
            DropoffLocationCreateRequestBuilder> {
  _$DropoffLocationCreateRequest? _$v;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  num? _lat;
  num? get lat => _$this._lat;
  set lat(num? lat) => _$this._lat = lat;

  num? _lng;
  num? get lng => _$this._lng;
  set lng(num? lng) => _$this._lng = lng;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  DropoffLocationCreateRequestBuilder() {
    DropoffLocationCreateRequest._defaults(this);
  }

  DropoffLocationCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _description = $v.description;
      _lat = $v.lat;
      _lng = $v.lng;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DropoffLocationCreateRequest other) {
    _$v = other as _$DropoffLocationCreateRequest;
  }

  @override
  void update(void Function(DropoffLocationCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DropoffLocationCreateRequest build() => _build();

  _$DropoffLocationCreateRequest _build() {
    final _$result = _$v ??
        _$DropoffLocationCreateRequest._(
          description: description,
          lat: lat,
          lng: lng,
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'DropoffLocationCreateRequest', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
