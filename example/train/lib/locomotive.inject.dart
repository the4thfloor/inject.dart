// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'locomotive.dart' as _i1;
import 'bike.dart' as _i2;
import 'common.dart' as _i3;
import 'food.dart' as _i4;
import 'dart:async' as _i5;

class TrainServices$Component implements _i1.TrainServices {
  TrainServices$Component._(
    this._bikeServices,
    this._commonServices,
    this._foodServices,
  );

  final _i2.BikeServices _bikeServices;

  final _i3.CommonServices _commonServices;

  final _i4.FoodServices _foodServices;

  static _i5.Future<_i1.TrainServices> create(
    _i2.BikeServices bikeServices,
    _i4.FoodServices foodServices,
    _i3.CommonServices commonServices,
  ) async {
    final component = TrainServices$Component._(
      bikeServices,
      commonServices,
      foodServices,
    );

    return component;
  }

  _i3.CarMaintenance _createCarMaintenance() => _commonServices.maintenance();
  _i2.BikeRack _createBikeRack() =>
      _bikeServices.bikeRack(_createCarMaintenance());
  _i4.Kitchen _createKitchen() =>
      _foodServices.kitchen(_createCarMaintenance());
  @override
  _i2.BikeRack get bikeRack => _createBikeRack();
  @override
  _i4.Kitchen get kitchen => _createKitchen();
}
