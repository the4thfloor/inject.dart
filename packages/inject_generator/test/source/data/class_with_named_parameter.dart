import 'package:inject/inject.dart';

import 'class_with_named_parameter.inject.dart' as g;

@component
abstract class Component {
  static const create = g.Component$Component.create;

  @inject
  FooBar get fooBar;
}

@inject
class Foo {}

@inject
class Bar {}

@inject
class FooBar {
  final Foo foo;
  final Bar bar;

  const FooBar(this.foo, {required this.bar});
}
