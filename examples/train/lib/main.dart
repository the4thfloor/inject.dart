import 'locomotive.dart';

void main() {
  final services = TrainServices.create();
  print(services.bikeRack.pleaseFix());
}
