// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'coffee_app_test.dart' as _i1;
import 'package:inject_example_coffee/src/drip_coffee_module.dart' as _i2;
import 'dart:async' as _i3;
import 'package:inject_example_coffee/src/coffee_maker.dart' as _i4;
import 'package:inject/inject.dart' as _i5;
import 'package:inject_example_coffee/src/electric_heater.dart' as _i6;
import 'package:inject_example_coffee/src/heater.dart' as _i7;
import 'package:inject_example_coffee/src/pump.dart' as _i8;

class TestCoffee$Component implements _i1.TestCoffee {
  factory TestCoffee$Component.create({
    _i2.DripCoffeeModule? dripCoffeeModule,
    _i1.TestModule? testModule,
  }) =>
      TestCoffee$Component._(
        dripCoffeeModule ?? _i2.DripCoffeeModule(),
        testModule ?? _i1.TestModule(),
      );

  TestCoffee$Component._(
    this._dripCoffeeModule,
    this._testModule,
  ) {
    _initialize();
  }

  final _i2.DripCoffeeModule _dripCoffeeModule;

  final _i1.TestModule _testModule;

  late final _PowerOutlet$Provider _powerOutlet$Provider;

  late final _Electricity$Provider _electricity$Provider;

  late final _Heater$Provider _heater$Provider;

  late final _Pump$Provider _pump$Provider;

  late final _StringBrandName$Provider _stringBrandName$Provider;

  late final _StringModelName$Provider _stringModelName$Provider;

  late final _CoffeeMaker$Provider _coffeeMaker$Provider;

  void _initialize() {
    _powerOutlet$Provider = _PowerOutlet$Provider(_dripCoffeeModule);
    _electricity$Provider = _Electricity$Provider(
      _powerOutlet$Provider,
      _dripCoffeeModule,
    );
    _heater$Provider = _Heater$Provider(
      _electricity$Provider,
      _testModule,
    );
    _pump$Provider = _Pump$Provider(
      _heater$Provider,
      _dripCoffeeModule,
    );
    _stringBrandName$Provider = _StringBrandName$Provider(_dripCoffeeModule);
    _stringModelName$Provider = _StringModelName$Provider(_testModule);
    _coffeeMaker$Provider = _CoffeeMaker$Provider(
      _heater$Provider,
      _pump$Provider,
      _stringBrandName$Provider,
      _stringModelName$Provider,
    );
  }

  @override
  _i3.Future<_i4.CoffeeMaker> getCoffeeMaker() => _coffeeMaker$Provider.get();
}

class _PowerOutlet$Provider
    implements _i5.Provider<_i3.Future<_i6.PowerOutlet>> {
  const _PowerOutlet$Provider(this._module);

  final _i2.DripCoffeeModule _module;

  @override
  _i3.Future<_i6.PowerOutlet> get() async => _module.providePowerOutlet();
}

class _Electricity$Provider
    implements _i5.Provider<_i3.Future<_i6.Electricity>> {
  _Electricity$Provider(
    this._powerOutlet$Provider,
    this._module,
  );

  final _PowerOutlet$Provider _powerOutlet$Provider;

  final _i2.DripCoffeeModule _module;

  _i6.Electricity? _singleton;

  @override
  _i3.Future<_i6.Electricity> get() async => _singleton ??=
      _module.provideElectricity(await _powerOutlet$Provider.get());
}

class _Heater$Provider implements _i5.Provider<_i3.Future<_i7.Heater>> {
  const _Heater$Provider(
    this._electricity$Provider,
    this._module,
  );

  final _Electricity$Provider _electricity$Provider;

  final _i1.TestModule _module;

  @override
  _i3.Future<_i7.Heater> get() async =>
      _module.testHeater(await _electricity$Provider.get());
}

class _Pump$Provider implements _i5.Provider<_i3.Future<_i8.Pump>> {
  const _Pump$Provider(
    this._heater$Provider,
    this._module,
  );

  final _Heater$Provider _heater$Provider;

  final _i2.DripCoffeeModule _module;

  @override
  _i3.Future<_i8.Pump> get() async =>
      _module.providePump(await _heater$Provider.get());
}

class _StringBrandName$Provider implements _i5.Provider<String> {
  const _StringBrandName$Provider(this._module);

  final _i2.DripCoffeeModule _module;

  @override
  String get() => _module.provideBrand();
}

class _StringModelName$Provider implements _i5.Provider<String> {
  const _StringModelName$Provider(this._module);

  final _i1.TestModule _module;

  @override
  String get() => _module.testModel();
}

class _CoffeeMaker$Provider
    implements _i5.Provider<_i3.Future<_i4.CoffeeMaker>> {
  const _CoffeeMaker$Provider(
    this._heater$Provider,
    this._pump$Provider,
    this._stringBrandName$Provider,
    this._stringModelName$Provider,
  );

  final _Heater$Provider _heater$Provider;

  final _Pump$Provider _pump$Provider;

  final _StringBrandName$Provider _stringBrandName$Provider;

  final _StringModelName$Provider _stringModelName$Provider;

  @override
  _i3.Future<_i4.CoffeeMaker> get() async => _i4.CoffeeMaker(
        await _heater$Provider.get(),
        await _pump$Provider.get(),
        _stringBrandName$Provider.get(),
        _stringModelName$Provider.get(),
      );
}
