// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'class_with_named_parameter.dart' as _i1;
import 'dart:async' as _i2;

class Component$Component implements _i1.Component {
  Component$Component._();

  static _i2.Future<_i1.Component> create() async {
    final component = Component$Component._();

    return component;
  }

  _i1.Foo _createFoo() => _i1.Foo();
  _i1.Bar _createBar() => _i1.Bar();
  _i1.FooBar _createFooBar() => _i1.FooBar(
        _createFoo(),
        bar: _createBar(),
      );
  @override
  _i1.FooBar get fooBar => _createFooBar();
}
