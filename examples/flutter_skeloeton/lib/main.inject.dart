// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:flutter/src/foundation/key.dart' as _i7;
import 'package:inject/inject.dart' as _i5;

import 'main.dart' as _i1;
import 'src/app.dart' as _i4;
import 'src/settings/settings_controller.dart' as _i2;
import 'src/settings/settings_service.dart' as _i6;

class MainComponent$Component implements _i1.MainComponent {
  factory MainComponent$Component.create(
          {_i2.SettingsModule? settingsModule}) =>
      MainComponent$Component._(settingsModule ?? _i2.SettingsModule());

  MainComponent$Component._(this._settingsModule) {
    _initialize();
  }

  final _i2.SettingsModule _settingsModule;

  late final _SettingsService$Provider _settingsService$Provider;

  late final _SettingsController$Provider _settingsController$Provider;

  late final _MyAppFactory$Provider _myAppFactory$Provider;

  void _initialize() {
    _settingsService$Provider = _SettingsService$Provider();
    _settingsController$Provider = _SettingsController$Provider(
      _settingsService$Provider,
      _settingsModule,
    );
    _myAppFactory$Provider =
        _MyAppFactory$Provider(_settingsController$Provider);
  }

  @override
  _i4.MyAppFactory get myAppFactory => _myAppFactory$Provider.get();
}

class _SettingsService$Provider implements _i5.Provider<_i6.SettingsService> {
  _SettingsService$Provider();

  _i6.SettingsService? _singleton;

  @override
  _i6.SettingsService get() => _singleton ??= _i6.SettingsService();
}

class _SettingsController$Provider
    implements _i5.Provider<_i3.Future<_i2.SettingsController>> {
  _SettingsController$Provider(
    this._settingsService$Provider,
    this._module,
  );

  final _SettingsService$Provider _settingsService$Provider;

  final _i2.SettingsModule _module;

  _i3.Future<_i2.SettingsController>? _singleton;

  @override
  _i3.Future<_i2.SettingsController> get() => _singleton ??=
      _module.settingsController(_settingsService$Provider.get());
}

class _MyAppFactory$Provider implements _i5.Provider<_i4.MyAppFactory> {
  _MyAppFactory$Provider(this._settingsController$Provider);

  final _SettingsController$Provider _settingsController$Provider;

  _i4.MyAppFactory? _factory;

  @override
  _i4.MyAppFactory get() =>
      _factory ??= _MyAppFactory$Factory(_settingsController$Provider);
}

class _MyAppFactory$Factory implements _i4.MyAppFactory {
  const _MyAppFactory$Factory(this._settingsController$Provider);

  final _SettingsController$Provider _settingsController$Provider;

  @override
  _i3.Future<_i4.MyApp> create({_i7.Key? key}) async => _i4.MyApp(
        key: key,
        settingsController: await _settingsController$Provider.get(),
      );
}
