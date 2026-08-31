// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_spot_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FoodSpotResponse extends FoodSpotResponse {
  @override
  final FoodSpotCategory category;
  @override
  final String? description;
  @override
  final String id;
  @override
  final String name;

  factory _$FoodSpotResponse(
          [void Function(FoodSpotResponseBuilder)? updates]) =>
      (FoodSpotResponseBuilder()..update(updates))._build();

  _$FoodSpotResponse._(
      {required this.category,
      this.description,
      required this.id,
      required this.name})
      : super._();
  @override
  FoodSpotResponse rebuild(void Function(FoodSpotResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FoodSpotResponseBuilder toBuilder() =>
      FoodSpotResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FoodSpotResponse &&
        category == other.category &&
        description == other.description &&
        id == other.id &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FoodSpotResponse')
          ..add('category', category)
          ..add('description', description)
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class FoodSpotResponseBuilder
    implements Builder<FoodSpotResponse, FoodSpotResponseBuilder> {
  _$FoodSpotResponse? _$v;

  FoodSpotCategory? _category;
  FoodSpotCategory? get category => _$this._category;
  set category(FoodSpotCategory? category) => _$this._category = category;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  FoodSpotResponseBuilder() {
    FoodSpotResponse._defaults(this);
  }

  FoodSpotResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _category = $v.category;
      _description = $v.description;
      _id = $v.id;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FoodSpotResponse other) {
    _$v = other as _$FoodSpotResponse;
  }

  @override
  void update(void Function(FoodSpotResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FoodSpotResponse build() => _build();

  _$FoodSpotResponse _build() {
    final _$result = _$v ??
        _$FoodSpotResponse._(
          category: BuiltValueNullFieldError.checkNotNull(
              category, r'FoodSpotResponse', 'category'),
          description: description,
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'FoodSpotResponse', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'FoodSpotResponse', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
