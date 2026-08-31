//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'run_status.g.dart';

class RunStatus extends EnumClass {

  /// Food run lifecycle (food-runs spec).  open → locked → at_store → delivering → done Terminal alternates: expired (nobody joined / runner ghosted), cancelled.
  @BuiltValueEnumConst(wireName: r'open')
  static const RunStatus open = _$open;
  /// Food run lifecycle (food-runs spec).  open → locked → at_store → delivering → done Terminal alternates: expired (nobody joined / runner ghosted), cancelled.
  @BuiltValueEnumConst(wireName: r'locked')
  static const RunStatus locked = _$locked;
  /// Food run lifecycle (food-runs spec).  open → locked → at_store → delivering → done Terminal alternates: expired (nobody joined / runner ghosted), cancelled.
  @BuiltValueEnumConst(wireName: r'at_store')
  static const RunStatus atStore = _$atStore;
  /// Food run lifecycle (food-runs spec).  open → locked → at_store → delivering → done Terminal alternates: expired (nobody joined / runner ghosted), cancelled.
  @BuiltValueEnumConst(wireName: r'delivering')
  static const RunStatus delivering = _$delivering;
  /// Food run lifecycle (food-runs spec).  open → locked → at_store → delivering → done Terminal alternates: expired (nobody joined / runner ghosted), cancelled.
  @BuiltValueEnumConst(wireName: r'done')
  static const RunStatus done = _$done;
  /// Food run lifecycle (food-runs spec).  open → locked → at_store → delivering → done Terminal alternates: expired (nobody joined / runner ghosted), cancelled.
  @BuiltValueEnumConst(wireName: r'expired')
  static const RunStatus expired = _$expired;
  /// Food run lifecycle (food-runs spec).  open → locked → at_store → delivering → done Terminal alternates: expired (nobody joined / runner ghosted), cancelled.
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const RunStatus cancelled = _$cancelled;

  static Serializer<RunStatus> get serializer => _$runStatusSerializer;

  const RunStatus._(String name): super(name);

  static BuiltSet<RunStatus> get values => _$values;
  static RunStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class RunStatusMixin = Object with _$RunStatusMixin;

