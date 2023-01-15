import 'package:inject/inject.dart';

import 'bla.dart';
import 'models.dart';

@AssistedInject(FooBarFactory)
class FooBar {
  @brandName
  final Foo foo;

  final Bar bar;

  @modelName
  final Foo foo2;

  const FooBar(this.foo, @assisted this.bar, {required this.foo2});

  void run() {
    print('foo: $foo - bar: $bar');
  }
}

@assistedFactory
abstract class FooBarFactory {
  Future<FooBar> create(Bar bar);
}
