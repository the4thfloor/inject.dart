// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'coffee_app.dart' as _i1;
import 'src/drip_coffee_module.dart' as _i2;
import 'src/electric_heater.dart' as _i3;
import 'src/heater.dart' as _i4;
import 'dart:async' as _i5;
import 'src/pump.dart' as _i6;
import 'src/coffee_maker.dart' as _i7;

class Coffee$Component implements _i1.Coffee {
  Coffee$Component._(this._dripCoffeeModule);

  final _i2.DripCoffeeModule _dripCoffeeModule;

  late _i3.PowerOutlet _powerOutlet;

  late _i4.Heater _heater;

  _i3.Electricity? _singletonElectricity;

  static _i5.Future<_i1.Coffee> create(
      _i2.DripCoffeeModule dripCoffeeModule) async {
    final component = Coffee$Component._(dripCoffeeModule);
    component._powerOutlet =
        await component._dripCoffeeModule.providePowerOutlet();
    component._heater = await component._dripCoffeeModule
        .provideHeater(component._createElectricity());
    return component;
  }

  _i3.PowerOutlet _createPowerOutlet() => _powerOutlet;
  _i3.Electricity _createElectricity() => _singletonElectricity ??=
      _dripCoffeeModule.provideElectricity(_createPowerOutlet());
  _i4.Heater _createHeater() => _heater;
  _i6.Pump _createPump() => _dripCoffeeModule.providePump(_createHeater());
  String _createBrandNameString() => _dripCoffeeModule.provideBrand();
  String _createModelNameString() => _dripCoffeeModule.provideModel();
  _i7.CoffeeMaker _createCoffeeMaker() => _i7.CoffeeMaker(
        _createHeater(),
        _createPump(),
        _createBrandNameString(),
        _createModelNameString(),
      );
  @override
  _i7.CoffeeMaker getCoffeeMaker() => _createCoffeeMaker();
}
