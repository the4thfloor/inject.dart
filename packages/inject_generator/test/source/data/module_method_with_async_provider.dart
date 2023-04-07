import 'package:inject_annotation/inject.dart';

import 'module_method_with_async_provider.inject.dart' as g;

@Component([BarModule])
abstract class ComponentWithModule {
  static const create = g.ComponentWithModule$Component.create;

  @inject
  Future<Bar> get bar;
}

@module
class BarModule {
  @provides
  @asynchronous
  Future<Bar> getBar({required Foo foo}) async => Bar(foo: foo);
}

@inject
class Foo {}

class Bar {
  final Foo foo;

  const Bar({required this.foo});
}
