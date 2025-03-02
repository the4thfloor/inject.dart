// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'main.dart' as _i1;
import 'src/settings/settings_controller.dart' as _i2;
import 'src/app.dart' as _i3;
import 'package:inject_annotation/inject_annotation.dart' as _i4;
import 'src/settings/settings_service.dart' as _i5;
import 'dart:async' as _i6;
import 'package:flutter/src/foundation/key.dart' as _i7;

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
  _i3.MyAppFactory get myAppFactory => _myAppFactory$Provider.get();
}

class _SettingsService$Provider implements _i4.Provider<_i5.SettingsService> {
  _SettingsService$Provider();

  _i5.SettingsService? _singleton;

  @override
  _i5.SettingsService get() => _singleton ??= const _i5.SettingsService();
}

class _SettingsController$Provider
    implements _i4.Provider<_i6.Future<_i2.SettingsController>> {
  _SettingsController$Provider(
    this._settingsService$Provider,
    this._module,
  );

  final _SettingsService$Provider _settingsService$Provider;

  final _i2.SettingsModule _module;

  _i2.SettingsController? _singleton;

  @override
  _i6.Future<_i2.SettingsController> get() async => _singleton ??=
      await _module.settingsController(_settingsService$Provider.get());
}

class _MyAppFactory$Provider implements _i4.Provider<_i3.MyAppFactory> {
  _MyAppFactory$Provider(this._settingsController$Provider);

  final _SettingsController$Provider _settingsController$Provider;

  late final _i3.MyAppFactory _factory =
      _MyAppFactory$Factory(_settingsController$Provider);

  @override
  _i3.MyAppFactory get() => _factory;
}

class _MyAppFactory$Factory implements _i3.MyAppFactory {
  const _MyAppFactory$Factory(this._settingsController$Provider);

  final _SettingsController$Provider _settingsController$Provider;

  @override
  _i6.Future<_i3.MyApp> create({_i7.Key? key}) async => _i3.MyApp(
        key: key,
        settingsController: await _settingsController$Provider.get(),
      );
}
