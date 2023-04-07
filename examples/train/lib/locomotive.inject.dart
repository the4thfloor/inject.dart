// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'locomotive.dart' as _i1;
import 'bike.dart' as _i2;
import 'food.dart' as _i3;
import 'common.dart' as _i4;
import 'package:inject_annotation/inject.dart' as _i5;

class TrainServices$Component implements _i1.TrainServices {
  factory TrainServices$Component.create({
    _i2.BikeServices? bikeServices,
    _i3.FoodServices? foodServices,
    _i4.CommonServices? commonServices,
  }) =>
      TrainServices$Component._(
        bikeServices ?? _i2.BikeServices(),
        foodServices ?? _i3.FoodServices(),
        commonServices ?? _i4.CommonServices(),
      );

  TrainServices$Component._(
    this._bikeServices,
    this._foodServices,
    this._commonServices,
  ) {
    _initialize();
  }

  final _i2.BikeServices _bikeServices;

  final _i3.FoodServices _foodServices;

  final _i4.CommonServices _commonServices;

  late final _CarMaintenance$Provider _carMaintenance$Provider;

  late final _BikeRack$Provider _bikeRack$Provider;

  late final _Kitchen$Provider _kitchen$Provider;

  void _initialize() {
    _carMaintenance$Provider = _CarMaintenance$Provider(_commonServices);
    _bikeRack$Provider = _BikeRack$Provider(
      _carMaintenance$Provider,
      _bikeServices,
    );
    _kitchen$Provider = _Kitchen$Provider(
      _carMaintenance$Provider,
      _foodServices,
    );
  }

  @override
  _i2.BikeRack get bikeRack => _bikeRack$Provider.get();
  @override
  _i3.Kitchen get kitchen => _kitchen$Provider.get();
}

class _CarMaintenance$Provider implements _i5.Provider<_i4.CarMaintenance> {
  const _CarMaintenance$Provider(this._module);

  final _i4.CommonServices _module;

  @override
  _i4.CarMaintenance get() => _module.maintenance();
}

class _BikeRack$Provider implements _i5.Provider<_i2.BikeRack> {
  const _BikeRack$Provider(
    this._carMaintenance$Provider,
    this._module,
  );

  final _CarMaintenance$Provider _carMaintenance$Provider;

  final _i2.BikeServices _module;

  @override
  _i2.BikeRack get() => _module.bikeRack(_carMaintenance$Provider.get());
}

class _Kitchen$Provider implements _i5.Provider<_i3.Kitchen> {
  const _Kitchen$Provider(
    this._carMaintenance$Provider,
    this._module,
  );

  final _CarMaintenance$Provider _carMaintenance$Provider;

  final _i3.FoodServices _module;

  @override
  _i3.Kitchen get() => _module.kitchen(_carMaintenance$Provider.get());
}
