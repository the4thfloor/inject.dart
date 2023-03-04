import 'package:inject/inject.dart';

import 'assisted_inject.inject.dart' as g;

@component
abstract class Component {
  static const create = g.Component$Component.create;

  @inject
  AnnotatedClassFactory get annotatedClassFactory;

  @inject
  AnnotatedConstructorFactory get annotatedConstructorFactory;
}

@AssistedInject(AnnotatedClassFactory)
class AnnotatedClass {
  final Foo foo;
  final Bar bar;

  const AnnotatedClass(this.foo, {@assisted required this.bar});
}

@assistedFactory
abstract class AnnotatedClassFactory {
  AnnotatedClass create({required Bar bar});
}

class AnnotatedConstructor {
  final Foo foo;
  final Bar bar;

  @AssistedInject(AnnotatedConstructorFactory)
  const AnnotatedConstructor(this.foo, {@assisted required this.bar});
}

@assistedFactory
abstract class AnnotatedConstructorFactory {
  AnnotatedConstructor create({required Bar bar});
}

@inject
class Foo {}

class Bar {}
