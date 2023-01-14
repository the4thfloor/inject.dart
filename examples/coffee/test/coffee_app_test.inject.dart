// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'coffee_app_test.dart' as _i1;
import 'package:inject_example_coffee/src/drip_coffee_module.dart' as _i2;
import 'package:inject_example_coffee/src/electric_heater.dart' as _i3;
import 'dart:async' as _i4;
import 'package:inject_example_coffee/src/heater.dart' as _i5;
import 'package:inject_example_coffee/src/pump.dart' as _i6;
import 'package:inject_example_coffee/src/coffee_maker.dart' as _i7;

class TestCoffee$Component implements _i1.TestCoffee {
  TestCoffee$Component._(
    this._testModule,
    this._dripCoffeeModule,
  );

  final _i1.TestModule _testModule;

  final _i2.DripCoffeeModule _dripCoffeeModule;

  late _i3.PowerOutlet _powerOutlet;

  _i3.Electricity? _singletonElectricity;

  static _i4.Future<_i1.TestCoffee> create(
    _i2.DripCoffeeModule dripCoffeeModule,
    _i1.TestModule testModule,
  ) async {
    final component = TestCoffee$Component._(
      testModule,
      dripCoffeeModule,
    );
    component._powerOutlet =
        await component._dripCoffeeModule.providePowerOutlet();
    return component;
  }

  _i3.PowerOutlet _createPowerOutlet() => _powerOutlet;
  _i3.Electricity _createElectricity() => _singletonElectricity ??=
      _dripCoffeeModule.provideElectricity(_createPowerOutlet());
  _i5.Heater _createHeater() => _testModule.testHeater(_createElectricity());
  _i6.Pump _createPump() => _dripCoffeeModule.providePump(_createHeater());
  String _createBrandNameString() => _dripCoffeeModule.provideBrand();
  String _createModelNameString() => _testModule.testModel();
  _i7.CoffeeMaker _createCoffeeMaker() => _i7.CoffeeMaker(
        _createHeater(),
        _createPump(),
        _createBrandNameString(),
        _createModelNameString(),
      );
  @override
  _i7.CoffeeMaker getCoffeeMaker() => _createCoffeeMaker();
}
