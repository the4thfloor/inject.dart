import 'package:inject/inject.dart';

import 'bla.dart';
import 'foo_bar.dart';
import 'models.dart';

@inject
class MyWidget {
  @brandName
  final Foo? foo;
  @modelName
  final Foo foo2;

  final FooBarFactory fooBarFactory;

  const MyWidget(
    this.foo,
    this.foo2,
    this.fooBarFactory,
  );

  Future<void> run() async {
    final fooBar = await fooBarFactory.create(Bar());
    fooBar.run();
    print('equals: ${foo == foo2}');
  }
}
