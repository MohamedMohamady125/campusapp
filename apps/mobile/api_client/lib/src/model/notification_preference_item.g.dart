// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preference_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotificationPreferenceItem extends NotificationPreferenceItem {
  @override
  final bool enabled;
  @override
  final String type;

  factory _$NotificationPreferenceItem(
          [void Function(NotificationPreferenceItemBuilder)? updates]) =>
      (NotificationPreferenceItemBuilder()..update(updates))._build();

  _$NotificationPreferenceItem._({required this.enabled, required this.type})
      : super._();
  @override
  NotificationPreferenceItem rebuild(
          void Function(NotificationPreferenceItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NotificationPreferenceItemBuilder toBuilder() =>
      NotificationPreferenceItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationPreferenceItem &&
        enabled == other.enabled &&
        type == other.type;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotificationPreferenceItem')
          ..add('enabled', enabled)
          ..add('type', type))
        .toString();
  }
}

class NotificationPreferenceItemBuilder
    implements
        Builder<NotificationPreferenceItem, NotificationPreferenceItemBuilder> {
  _$NotificationPreferenceItem? _$v;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  String? _type;
  String? get type => _$this._type;
  set type(String? type) => _$this._type = type;

  NotificationPreferenceItemBuilder() {
    NotificationPreferenceItem._defaults(this);
  }

  NotificationPreferenceItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _enabled = $v.enabled;
      _type = $v.type;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationPreferenceItem other) {
    _$v = other as _$NotificationPreferenceItem;
  }

  @override
  void update(void Function(NotificationPreferenceItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationPreferenceItem build() => _build();

  _$NotificationPreferenceItem _build() {
    final _$result = _$v ??
        _$NotificationPreferenceItem._(
          enabled: BuiltValueNullFieldError.checkNotNull(
              enabled, r'NotificationPreferenceItem', 'enabled'),
          type: BuiltValueNullFieldError.checkNotNull(
              type, r'NotificationPreferenceItem', 'type'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
