// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'component_without_module.dart' as _i1;
import 'dart:async' as _i2;

class ComponentWithoutModule$Component implements _i1.ComponentWithoutModule {
  ComponentWithoutModule$Component._();

  static _i2.Future<_i1.ComponentWithoutModule> create() async {
    final component = ComponentWithoutModule$Component._();

    return component;
  }

  _i1.Bar _createBar() => _i1.Bar();
  @override
  _i1.Bar getBar() => _createBar();
}
