import 'package:inject/inject.dart';

import 'bla.dart';
import 'foo.inject.dart' as g;
import 'models.dart';
import 'widget.dart';

Future<void> main() async {
  final comp = FooComponent.create();
  final myWidget = await comp.myWidget;
  myWidget.run();
}

@Component([FooModule, FooModule, BlaModule])
abstract class FooComponent {
  static const create = g.FooComponent$Component.create;

  @inject
  Future<MyWidget> get myWidget;

  @inject
  Future<MyWidget> getMyWidget();

  @inject
  Foo2 get foo2;
}

// @Component([FooModule])
// abstract class FooComponent2 {
//   static const create = g.FooComponent$Component.create;
//
//   @inject
//   Foo2 get foo2;
//
//   @inject
//   Bar2 get bar2;
// }
