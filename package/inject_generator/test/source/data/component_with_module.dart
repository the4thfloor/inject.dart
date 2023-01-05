import 'package:inject/inject.dart';

// import 'component_with_module.inject.dart' as g;

@Component([BarModule])
abstract class ComponentWithModule implements BarLocator {
  // static const create = g.ComponentWithModule$Component.create;
}

abstract class BarLocator {
  @inject
  Bar get bar;
}

@module
class BarModule {
  @provides
  Bar getBar() => Bar();
}

@inject
class Bar {
  String get foo => 'foo';
}
