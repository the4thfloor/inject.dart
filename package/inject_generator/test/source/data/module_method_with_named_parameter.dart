import 'package:inject/inject.dart';

import 'module_method_with_named_parameter.inject.dart' as g;

@Component([BarModule])
abstract class ComponentWithModule implements BarLocator {
  static const create = g.ComponentWithModule$Component.create;
}

abstract class BarLocator {
  @inject
  Bar get bar;
}

@module
class BarModule {
  @provides
  Bar getBar({required Foo foo}) => Bar(foo: foo);
}

@inject
class Foo {}

@inject
class Bar {
  final Foo foo;

  const Bar({required this.foo});
}
