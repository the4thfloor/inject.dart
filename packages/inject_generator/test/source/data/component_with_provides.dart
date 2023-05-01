import 'package:inject_annotation/inject_annotation.dart';

// import 'component_with_provides.inject.dart' as g;

@component
abstract class ComponentWithProvides {
  // static const create = g.ComponentWithProvides$Component.create;

  @provides
  Bar get bar;
}

@inject
class Bar {
  String get foo => 'foo';
}
