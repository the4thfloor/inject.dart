import 'package:inject_example_train/bike.dart';
import 'package:inject_example_train/common.dart';
import 'package:inject_example_train/food.dart';
import 'package:inject_example_train/locomotive.dart';
import 'package:test/test.dart';

void main() {
  group('locomotive', () {
    test('can instantiate TrainServices', () async {
      final services = await TrainServices.create(
        BikeServices(),
        FoodServices(),
        CommonServices(),
      );
      services
        ..bikeRack
        ..kitchen;
    });
  });
}
