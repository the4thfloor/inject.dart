import 'package:inject_annotation/inject_annotation.dart';

import 'component_with_module.inject.dart' as g;

@Component([BarModule])
abstract class ComponentWithModule {
  static const create = g.ComponentWithModule$Component.create;

  @inject
  Bar get bar;
}

@module
class BarModule {
  @provides
  Bar getBar() => Bar();
}

class Bar {
  String get foo => 'foo';
}
