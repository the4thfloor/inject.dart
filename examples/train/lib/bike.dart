import 'package:inject_annotation/inject_annotation.dart';

import 'common.dart';

/// Provides the service locator to the bike car feature code.
BikeServiceLocator? bikeServices;

/// Declares dependencies used by the bike car.
abstract class BikeServiceLocator {
  @inject
  BikeRack get bikeRack;
}

/// Declares dependencies needed by the bike car.
@module
class BikeServices {
  /// Note the dependency on [CarMaintenance] which this module does not itself
  /// provide. This tells `package:inject` to look for it when this module is
  /// mixed into an injector. The compiler will _statically_ check that this
  /// dependency is satisfied, and issue a warning if it's not.
  @provides
  BikeRack bikeRack(CarMaintenance cm) => BikeRack(cm);
}

class BikeRack {
  final CarMaintenance maintenance;

  BikeRack(this.maintenance);

  String pleaseFix() {
    return maintenance.pleaseFix();
  }
}
