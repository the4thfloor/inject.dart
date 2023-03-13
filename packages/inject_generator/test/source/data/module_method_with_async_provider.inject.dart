// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'module_method_with_async_provider.dart' as _i1;
import 'dart:async' as _i2;
import 'package:inject/inject.dart' as _i3;

class ComponentWithModule$Component implements _i1.ComponentWithModule {
  factory ComponentWithModule$Component.create({_i1.BarModule? barModule}) =>
      ComponentWithModule$Component._(barModule ?? _i1.BarModule());

  ComponentWithModule$Component._(this._barModule) {
    _initialize();
  }

  final _i1.BarModule _barModule;

  late final _Foo$Provider _foo$Provider;

  late final _Bar$Provider _bar$Provider;

  void _initialize() {
    _foo$Provider = _Foo$Provider();
    _bar$Provider = _Bar$Provider(
      _foo$Provider,
      _barModule,
    );
  }

  @override
  _i2.Future<_i1.Bar> get bar => _bar$Provider.get();
}

class _Foo$Provider implements _i3.Provider<_i1.Foo> {
  const _Foo$Provider();

  @override
  _i1.Foo get() => _i1.Foo();
}

class _Bar$Provider implements _i3.Provider<_i2.Future<_i1.Bar>> {
  const _Bar$Provider(
    this._foo$Provider,
    this._module,
  );

  final _Foo$Provider _foo$Provider;

  final _i1.BarModule _module;

  @override
  _i2.Future<_i1.Bar> get() async =>
      await _module.getBar(foo: _foo$Provider.get());
}
