// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dropoff_location_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DropoffLocationResponse extends DropoffLocationResponse {
  @override
  final String? description;
  @override
  final String id;
  @override
  final num? lat;
  @override
  final num? lng;
  @override
  final String name;

  factory _$DropoffLocationResponse(
          [void Function(DropoffLocationResponseBuilder)? updates]) =>
      (DropoffLocationResponseBuilder()..update(updates))._build();

  _$DropoffLocationResponse._(
      {this.description,
      required this.id,
      this.lat,
      this.lng,
      required this.name})
      : super._();
  @override
  DropoffLocationResponse rebuild(
          void Function(DropoffLocationResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DropoffLocationResponseBuilder toBuilder() =>
      DropoffLocationResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DropoffLocationResponse &&
        description == other.description &&
        id == other.id &&
        lat == other.lat &&
        lng == other.lng &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, lat.hashCode);
    _$hash = $jc(_$hash, lng.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DropoffLocationResponse')
          ..add('description', description)
          ..add('id', id)
          ..add('lat', lat)
          ..add('lng', lng)
          ..add('name', name))
        .toString();
  }
}

class DropoffLocationResponseBuilder
    implements
        Builder<DropoffLocationResponse, DropoffLocationResponseBuilder> {
  _$DropoffLocationResponse? _$v;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  num? _lat;
  num? get lat => _$this._lat;
  set lat(num? lat) => _$this._lat = lat;

  num? _lng;
  num? get lng => _$this._lng;
  set lng(num? lng) => _$this._lng = lng;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  DropoffLocationResponseBuilder() {
    DropoffLocationResponse._defaults(this);
  }

  DropoffLocationResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _description = $v.description;
      _id = $v.id;
      _lat = $v.lat;
      _lng = $v.lng;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DropoffLocationResponse other) {
    _$v = other as _$DropoffLocationResponse;
  }

  @override
  void update(void Function(DropoffLocationResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DropoffLocationResponse build() => _build();

  _$DropoffLocationResponse _build() {
    final _$result = _$v ??
        _$DropoffLocationResponse._(
          description: description,
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'DropoffLocationResponse', 'id'),
          lat: lat,
          lng: lng,
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'DropoffLocationResponse', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
