// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'foo.dart' as _i1;
import 'bla.dart' as _i2;
import 'dart:async' as _i3;
import 'widget.dart' as _i4;
import 'models.dart' as _i5;
import 'package:inject/inject.dart' as _i6;
import 'foo_bar.dart' as _i7;

class FooComponent$Component implements _i1.FooComponent {
  factory FooComponent$Component.create({
    _i2.FooModule? fooModule,
    _i2.BlaModule? blaModule,
  }) =>
      FooComponent$Component._(
        fooModule ?? _i2.FooModule(),
        blaModule ?? _i2.BlaModule(),
      );

  FooComponent$Component._(
    this._fooModule,
    this._blaModule,
  ) {
    _initialize();
  }

  final _i2.FooModule _fooModule;

  final _i2.BlaModule _blaModule;

  late final _FooBrandName$Provider _fooBrandName$Provider;

  late final _FooModelName$Provider _fooModelName$Provider;

  late final _FooBarFactory$Provider _fooBarFactory$Provider;

  late final _MyWidget$Provider _myWidget$Provider;

  late final _Foo2$Provider _foo2$Provider;

  late final _BlaBla$Provider _blaBla$Provider;

  void _initialize() {
    _fooBrandName$Provider = _FooBrandName$Provider(_fooModule);
    _fooModelName$Provider = _FooModelName$Provider(_fooModule);
    _fooBarFactory$Provider = _FooBarFactory$Provider(
      _fooBrandName$Provider,
      _fooModelName$Provider,
    );
    _myWidget$Provider = _MyWidget$Provider(
      _fooBrandName$Provider,
      _fooModelName$Provider,
      _fooBarFactory$Provider,
    );
    _foo2$Provider = _Foo2$Provider();
    _blaBla$Provider = _BlaBla$Provider(
      _fooModelName$Provider,
      _blaModule,
    );
  }

  @override
  _i3.Future<_i4.MyWidget> get myWidget => _myWidget$Provider.get();
  @override
  _i5.Foo2 get foo2 => _foo2$Provider.get();
  @override
  _i3.Future<_i4.MyWidget> getMyWidget() => _myWidget$Provider.get();
}

class _FooBrandName$Provider implements _i6.Provider<_i3.Future<_i5.Foo>> {
  const _FooBrandName$Provider(this._module);

  final _i2.FooModule _module;

  @override
  _i3.Future<_i5.Foo> get() async => _module.foo();
}

class _FooModelName$Provider implements _i6.Provider<_i5.Foo> {
  const _FooModelName$Provider(this._module);

  final _i2.FooModule _module;

  @override
  _i5.Foo get() => _module.foo2();
}

class _FooBarFactory$Provider
    implements _i6.Provider<_i3.Future<_i7.FooBarFactory>> {
  _FooBarFactory$Provider(
    this._fooBrandName$Provider,
    this._fooModelName$Provider,
  );

  final _FooBrandName$Provider _fooBrandName$Provider;

  final _FooModelName$Provider _fooModelName$Provider;

  _i7.FooBarFactory? _factory;

  @override
  _i3.Future<_i7.FooBarFactory> get() async =>
      _factory ??= _FooBarFactory$Factory(
        _fooBrandName$Provider,
        _fooModelName$Provider,
      );
}

class _FooBarFactory$Factory implements _i7.FooBarFactory {
  const _FooBarFactory$Factory(
    this._fooBrandName$Provider,
    this._fooModelName$Provider,
  );

  final _FooBrandName$Provider _fooBrandName$Provider;

  final _FooModelName$Provider _fooModelName$Provider;

  @override
  _i3.Future<_i7.FooBar> create(_i5.Bar bar) async => _i7.FooBar(
        await _fooBrandName$Provider.get(),
        bar,
        foo2: _fooModelName$Provider.get(),
      );
}

class _MyWidget$Provider implements _i6.Provider<_i3.Future<_i4.MyWidget>> {
  const _MyWidget$Provider(
    this._fooBrandName$Provider,
    this._fooModelName$Provider,
    this._fooBarFactory$Provider,
  );

  final _FooBrandName$Provider _fooBrandName$Provider;

  final _FooModelName$Provider _fooModelName$Provider;

  final _FooBarFactory$Provider _fooBarFactory$Provider;

  @override
  _i3.Future<_i4.MyWidget> get() async => _i4.MyWidget(
        await _fooBrandName$Provider.get(),
        _fooModelName$Provider.get(),
        await _fooBarFactory$Provider.get(),
      );
}

class _Foo2$Provider implements _i6.Provider<_i5.Foo2> {
  const _Foo2$Provider();

  @override
  _i5.Foo2 get() => _i5.Foo2();
}

class _BlaBla$Provider implements _i6.Provider<_i3.Future<_i2.BlaBla>> {
  const _BlaBla$Provider(
    this._fooModelName$Provider,
    this._module,
  );

  final _FooModelName$Provider _fooModelName$Provider;

  final _i2.BlaModule _module;

  @override
  _i3.Future<_i2.BlaBla> get() async =>
      _module.blaBla(_fooModelName$Provider.get());
}
