// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'component_with_module.dart' as _i1;
import 'package:inject_annotation/inject_annotation.dart' as _i2;

class ComponentWithModule$Component implements _i1.ComponentWithModule {
  factory ComponentWithModule$Component.create(
          {_i1.StoreModule? storeModule}) =>
      ComponentWithModule$Component._(storeModule ?? _i1.StoreModule());

  ComponentWithModule$Component._(this._storeModule) {
    _initialize();
  }

  final _i1.StoreModule _storeModule;

  late final _StoreAppState$Provider _storeAppState$Provider;

  void _initialize() {
    _storeAppState$Provider = _StoreAppState$Provider(_storeModule);
  }

  @override
  _i1.Store<_i1.AppState> get store => _storeAppState$Provider.get();
}

class _StoreAppState$Provider implements _i2.Provider<_i1.Store<_i1.AppState>> {
  _StoreAppState$Provider(this._module);

  final _i1.StoreModule _module;

  _i1.Store<_i1.AppState>? _singleton;

  @override
  _i1.Store<_i1.AppState> get() => _singleton ??= _module.provideStore();
}
