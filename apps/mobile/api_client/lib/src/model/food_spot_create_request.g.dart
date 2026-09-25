// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_spot_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FoodSpotCreateRequest extends FoodSpotCreateRequest {
  @override
  final FoodSpotCategory? category;
  @override
  final String? description;
  @override
  final num? lat;
  @override
  final num? lng;
  @override
  final String name;

  factory _$FoodSpotCreateRequest(
          [void Function(FoodSpotCreateRequestBuilder)? updates]) =>
      (FoodSpotCreateRequestBuilder()..update(updates))._build();

  _$FoodSpotCreateRequest._(
      {this.category, this.description, this.lat, this.lng, required this.name})
      : super._();
  @override
  FoodSpotCreateRequest rebuild(
          void Function(FoodSpotCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FoodSpotCreateRequestBuilder toBuilder() =>
      FoodSpotCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FoodSpotCreateRequest &&
        category == other.category &&
        description == other.description &&
        lat == other.lat &&
        lng == other.lng &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, lat.hashCode);
    _$hash = $jc(_$hash, lng.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FoodSpotCreateRequest')
          ..add('category', category)
          ..add('description', description)
          ..add('lat', lat)
          ..add('lng', lng)
          ..add('name', name))
        .toString();
  }
}

class FoodSpotCreateRequestBuilder
    implements Builder<FoodSpotCreateRequest, FoodSpotCreateRequestBuilder> {
  _$FoodSpotCreateRequest? _$v;

  FoodSpotCategory? _category;
  FoodSpotCategory? get category => _$this._category;
  set category(FoodSpotCategory? category) => _$this._category = category;

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

  FoodSpotCreateRequestBuilder() {
    FoodSpotCreateRequest._defaults(this);
  }

  FoodSpotCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _category = $v.category;
      _description = $v.description;
      _lat = $v.lat;
      _lng = $v.lng;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FoodSpotCreateRequest other) {
    _$v = other as _$FoodSpotCreateRequest;
  }

  @override
  void update(void Function(FoodSpotCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FoodSpotCreateRequest build() => _build();

  _$FoodSpotCreateRequest _build() {
    final _$result = _$v ??
        _$FoodSpotCreateRequest._(
          category: category,
          description: description,
          lat: lat,
          lng: lng,
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'FoodSpotCreateRequest', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
