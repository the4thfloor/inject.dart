import 'package:inject/inject.dart';

import 'assisted_inject.inject.dart' as g;

@component
abstract class Component {
  static const create = g.Component$Component.create;

  @inject
  FooBarFactory get fooBarFactory;
}

@AssistedInject(FooBarFactory)
class FooBar {
  final Foo foo;
  final Bar bar;

  const FooBar(this.foo, {@assisted required this.bar});
}

@assistedFactory
abstract class FooBarFactory {
  FooBar create({required Bar bar});
}

@inject
class Foo {}

class Bar {}
