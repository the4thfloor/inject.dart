import 'package:inject_annotation/inject_annotation.dart';

/// Provides common dependencies.
@module
class CommonServices {
  @provides
  CarMaintenance maintenance() => CarMaintenance();
}

/// Fixes train cars of all kinds.
class CarMaintenance {
  String pleaseFix() => 'Sure thing!';
}
