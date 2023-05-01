// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'main.dart' as _i1;
import 'package:inject_annotation/inject_annotation.dart' as _i2;

class MainComponent$Component implements _i1.MainComponent {
  factory MainComponent$Component.create({_i1.ApiModule? apiModule}) =>
      MainComponent$Component._(apiModule ?? _i1.ApiModule());

  MainComponent$Component._(this._apiModule) {
    _initialize();
  }

  final _i1.ApiModule _apiModule;

  late final _FakeApiClient$Provider _fakeApiClient$Provider;

  late final _Repository$Provider _repository$Provider;

  void _initialize() {
    _fakeApiClient$Provider = _FakeApiClient$Provider(_apiModule);
    _repository$Provider = _Repository$Provider(_fakeApiClient$Provider);
  }

  @override
  _i1.Repository get repository => _repository$Provider.get();
}

class _FakeApiClient$Provider implements _i2.Provider<_i1.FakeApiClient> {
  _FakeApiClient$Provider(this._module);

  final _i1.ApiModule _module;

  _i1.FakeApiClient? _singleton;

  @override
  _i1.FakeApiClient get() => _singleton ??= _module.apiClient();
}

class _Repository$Provider implements _i2.Provider<_i1.Repository> {
  const _Repository$Provider(this._fakeApiClient$Provider);

  final _FakeApiClient$Provider _fakeApiClient$Provider;

  @override
  _i1.Repository get() => _i1.Repository(_fakeApiClient$Provider.get());
}
