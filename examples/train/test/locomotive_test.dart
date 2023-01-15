import 'package:inject_example_train/locomotive.dart';
import 'package:test/test.dart';

void main() {
  group('locomotive', () {
    test('can instantiate TrainServices', () async {
      final services = TrainServices.create();
      services
        ..bikeRack
        ..kitchen;
    });
  });
}
