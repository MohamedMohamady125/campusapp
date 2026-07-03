// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences_update_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotificationPreferencesUpdateRequest
    extends NotificationPreferencesUpdateRequest {
  @override
  final BuiltList<NotificationPreferenceItem> preferences;

  factory _$NotificationPreferencesUpdateRequest(
          [void Function(NotificationPreferencesUpdateRequestBuilder)?
              updates]) =>
      (NotificationPreferencesUpdateRequestBuilder()..update(updates))._build();

  _$NotificationPreferencesUpdateRequest._({required this.preferences})
      : super._();
  @override
  NotificationPreferencesUpdateRequest rebuild(
          void Function(NotificationPreferencesUpdateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NotificationPreferencesUpdateRequestBuilder toBuilder() =>
      NotificationPreferencesUpdateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationPreferencesUpdateRequest &&
        preferences == other.preferences;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, preferences.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotificationPreferencesUpdateRequest')
          ..add('preferences', preferences))
        .toString();
  }
}

class NotificationPreferencesUpdateRequestBuilder
    implements
        Builder<NotificationPreferencesUpdateRequest,
            NotificationPreferencesUpdateRequestBuilder> {
  _$NotificationPreferencesUpdateRequest? _$v;

  ListBuilder<NotificationPreferenceItem>? _preferences;
  ListBuilder<NotificationPreferenceItem> get preferences =>
      _$this._preferences ??= ListBuilder<NotificationPreferenceItem>();
  set preferences(ListBuilder<NotificationPreferenceItem>? preferences) =>
      _$this._preferences = preferences;

  NotificationPreferencesUpdateRequestBuilder() {
    NotificationPreferencesUpdateRequest._defaults(this);
  }

  NotificationPreferencesUpdateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _preferences = $v.preferences.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationPreferencesUpdateRequest other) {
    _$v = other as _$NotificationPreferencesUpdateRequest;
  }

  @override
  void update(
      void Function(NotificationPreferencesUpdateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationPreferencesUpdateRequest build() => _build();

  _$NotificationPreferencesUpdateRequest _build() {
    _$NotificationPreferencesUpdateRequest _$result;
    try {
      _$result = _$v ??
          _$NotificationPreferencesUpdateRequest._(
            preferences: preferences.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'preferences';
        preferences.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'NotificationPreferencesUpdateRequest',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
