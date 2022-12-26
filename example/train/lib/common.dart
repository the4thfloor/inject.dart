import 'package:inject/inject.dart';

/// Provides common dependencies.
@module
class CommonServices {
  @provide
  CarMaintenance maintenance() => CarMaintenance();
}

/// Fixes train cars of all kinds.
class CarMaintenance {
  String pleaseFix() => 'Sure thing!';
}
