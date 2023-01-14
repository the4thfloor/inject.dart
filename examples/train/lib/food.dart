import 'package:inject/inject.dart';

import 'common.dart';

/// Provides service locator for food car feature code.
FoodServiceLocator? foodServices;

/// Declares dependencies used by the food car.
abstract class FoodServiceLocator {
  @inject
  Kitchen get kitchen;
}

/// Declares dependencies needed by the food car.
@module
class FoodServices {
  @provides
  Kitchen kitchen(CarMaintenance cm) => Kitchen(cm);
}

class Kitchen {
  Kitchen(CarMaintenance cm);
}
