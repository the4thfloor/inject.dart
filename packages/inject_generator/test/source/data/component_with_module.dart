import 'package:inject_annotation/inject_annotation.dart';

import 'component_with_module.inject.dart' as g;

@Component([StoreModule])
abstract class ComponentWithModule {
  static const create = g.ComponentWithModule$Component.create;

  Store<AppState> get store;
}

@module
class StoreModule {
  @provides
  @singleton
  Store<AppState> provideStore() => Store<AppState>(AppState());
}

class Store<T> {
  const Store(this.state);

  final T state;
}

class AppState {}
