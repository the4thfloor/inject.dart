// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'assisted_inject.dart' as _i1;
import 'package:inject/inject.dart' as _i2;

class Component$Component implements _i1.Component {
  factory Component$Component.create() => Component$Component._();

  Component$Component._() {
    _initialize();
  }

  late final _Foo$Provider _foo$Provider;

  late final _FooBarFactory$Provider _fooBarFactory$Provider;

  void _initialize() {
    _foo$Provider = _Foo$Provider();
    _fooBarFactory$Provider = _FooBarFactory$Provider(_foo$Provider);
  }

  @override
  _i1.FooBarFactory get fooBarFactory => _fooBarFactory$Provider.get();
}

class _Foo$Provider implements _i2.Provider<_i1.Foo> {
  const _Foo$Provider();

  @override
  _i1.Foo get() => _i1.Foo();
}

class _FooBarFactory$Provider implements _i2.Provider<_i1.FooBarFactory> {
  _FooBarFactory$Provider(this._foo$Provider);

  final _Foo$Provider _foo$Provider;

  _i1.FooBarFactory? _factory;

  @override
  _i1.FooBarFactory get() => _factory ??= _FooBarFactory$Factory(_foo$Provider);
}

class _FooBarFactory$Factory implements _i1.FooBarFactory {
  const _FooBarFactory$Factory(this._foo$Provider);

  final _Foo$Provider _foo$Provider;

  @override
  _i1.FooBar create({required _i1.Bar bar}) => _i1.FooBar(
        _foo$Provider.get(),
        bar: bar,
      );
}
