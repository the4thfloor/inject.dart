// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'module_method_with_named_parameter.dart' as _i1;
import 'dart:async' as _i2;

class ComponentWithModule$Component implements _i1.ComponentWithModule {
  ComponentWithModule$Component._(this._barModule);

  final _i1.BarModule _barModule;

  static _i2.Future<_i1.ComponentWithModule> create(
      _i1.BarModule barModule) async {
    final component = ComponentWithModule$Component._(barModule);

    return component;
  }

  _i1.Foo _createFoo() => _i1.Foo();
  _i1.Bar _createBar() => _barModule.getBar(foo: _createFoo());
  @override
  _i1.Bar get bar => _createBar();
}
