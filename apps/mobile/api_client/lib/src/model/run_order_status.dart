//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'run_order_status.g.dart';

class RunOrderStatus extends EnumClass {

  /// Per-order lifecycle within a run.  requested → accepted | declined | cancelled accepted → delivered → received | no_show
  @BuiltValueEnumConst(wireName: r'requested')
  static const RunOrderStatus requested = _$requested;
  /// Per-order lifecycle within a run.  requested → accepted | declined | cancelled accepted → delivered → received | no_show
  @BuiltValueEnumConst(wireName: r'accepted')
  static const RunOrderStatus accepted = _$accepted;
  /// Per-order lifecycle within a run.  requested → accepted | declined | cancelled accepted → delivered → received | no_show
  @BuiltValueEnumConst(wireName: r'declined')
  static const RunOrderStatus declined = _$declined;
  /// Per-order lifecycle within a run.  requested → accepted | declined | cancelled accepted → delivered → received | no_show
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const RunOrderStatus cancelled = _$cancelled;
  /// Per-order lifecycle within a run.  requested → accepted | declined | cancelled accepted → delivered → received | no_show
  @BuiltValueEnumConst(wireName: r'delivered')
  static const RunOrderStatus delivered = _$delivered;
  /// Per-order lifecycle within a run.  requested → accepted | declined | cancelled accepted → delivered → received | no_show
  @BuiltValueEnumConst(wireName: r'received')
  static const RunOrderStatus received = _$received;
  /// Per-order lifecycle within a run.  requested → accepted | declined | cancelled accepted → delivered → received | no_show
  @BuiltValueEnumConst(wireName: r'no_show')
  static const RunOrderStatus noShow = _$noShow;

  static Serializer<RunOrderStatus> get serializer => _$runOrderStatusSerializer;

  const RunOrderStatus._(String name): super(name);

  static BuiltSet<RunOrderStatus> get values => _$values;
  static RunOrderStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class RunOrderStatusMixin = Object with _$RunOrderStatusMixin;

