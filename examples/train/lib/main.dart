import 'dart:async';

import 'bike.dart';
import 'common.dart';
import 'food.dart';
import 'locomotive.dart';

Future<void> main() async {
  final services = await TrainServices.create(
    BikeServices(),
    FoodServices(),
    CommonServices(),
  );
  print(services.bikeRack.pleaseFix());
}
