import 'package:inject/inject.dart';

import 'models.dart';

const brandName = Qualifier(#brandName);
const modelName = Qualifier(#modelName);

@module
class FooModule {
  @provides
  @brandName
  @asynchronous
  Future<Foo> foo() async => Foo();

  @provides
  @modelName
  Foo foo2() => Foo();
}

@module
class BlaModule {
  @provides
  @asynchronous
  Future<BlaBla> blaBla(@modelName Foo foo) async => BlaBla();
}

class BlaBla {}
