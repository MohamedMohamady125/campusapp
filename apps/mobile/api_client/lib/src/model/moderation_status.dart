//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moderation_status.g.dart';

class ModerationStatus extends EnumClass {

  @BuiltValueEnumConst(wireName: r'pending')
  static const ModerationStatus pending = _$pending;
  @BuiltValueEnumConst(wireName: r'approved')
  static const ModerationStatus approved = _$approved;
  @BuiltValueEnumConst(wireName: r'rejected')
  static const ModerationStatus rejected = _$rejected;

  static Serializer<ModerationStatus> get serializer => _$moderationStatusSerializer;

  const ModerationStatus._(String name): super(name);

  static BuiltSet<ModerationStatus> get values => _$values;
  static ModerationStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ModerationStatusMixin = Object with _$ModerationStatusMixin;

