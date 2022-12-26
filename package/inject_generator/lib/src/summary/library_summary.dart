// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of inject.src.summary;

/// JSON-serializable subset of code analysis information about a Dart library
/// containing dependency injection constructs.
///
/// A library summary generally corresponds to a ".dart" file.
class LibrarySummary {
  /// Creates a [LibrarySummary] by parsing the .inject.summary [json].
  static LibrarySummary parseJson(Map<String, dynamic> json) {
    final assetUri = Uri.parse(json['asset'] as String);
    final summary = json['summary'] as Map<String, dynamic>;
    final injectors = (summary['injector'] as List<dynamic>)
        .map((e) => _injectorFromJson(assetUri, e as Map<String, dynamic>))
        .toList();
    final modules = (summary['module'] as List<dynamic>)
        .map((e) => _moduleFromJson(assetUri, e as Map<String, dynamic>))
        .toList();
    final injectables = (summary['injectable'] as List<dynamic>)
        .map((e) => _injectableFromJson(assetUri, e as Map<String, dynamic>))
        .toList();
    return LibrarySummary(
      assetUri,
      injectors: injectors,
      modules: modules,
      injectables: injectables,
    );
  }

  /// Points to the Dart file that defines the library from which this summary
  /// was extracted.
  ///
  /// The URI uses the "asset:" scheme.
  final Uri assetUri;

  /// Injector classes defined in the library.
  final List<InjectorSummary> injectors;

  /// Module classes defined in this library.
  final List<ModuleSummary> modules;

  /// Injectable classes.
  final List<InjectableSummary> injectables;

  /// Constructor.
  ///
  /// [assetUri], [injectors] and [modules] must not be `null`.
  factory LibrarySummary(
    Uri assetUri, {
    List<InjectorSummary> injectors = const [],
    List<ModuleSummary> modules = const [],
    List<InjectableSummary> injectables = const [],
  }) {
    return LibrarySummary._(assetUri, injectors, modules, injectables);
  }

  LibrarySummary._(
    this.assetUri,
    this.injectors,
    this.modules,
    this.injectables,
  );

  /// Serializes this summary to JSON.
  Map<String, dynamic> toJson() {
    return {
      'asset': assetUri.toString(),
      'summary': {
        'injector': injectors,
        'module': modules,
        'injectable': injectables,
      }
    };
  }
}

InjectorSummary _injectorFromJson(Uri assetUri, Map<String, dynamic> json) {
  final name = json['name'] as String;
  final List<SymbolPath> modules = json['modules']
      .cast<String>()
      .map(Uri.parse)
      .map<SymbolPath>((e) => SymbolPath.fromAbsoluteUri(e))
      .toList();
  final List<ProviderSummary> providers = json['providers']
      .cast<Map<String, dynamic>>()
      .map<ProviderSummary>(_providerFromJson)
      .toList();
  final clazz = SymbolPath.fromAbsoluteUri(assetUri, name);
  return InjectorSummary(clazz, modules, providers);
}

ModuleSummary _moduleFromJson(Uri assetUri, Map<String, dynamic> json) {
  final name = json['name'] as String;
  final List<ProviderSummary> providers = json['providers']
      .cast<Map<String, dynamic>>()
      .map<ProviderSummary>(_providerFromJson)
      .toList();
  final clazz = SymbolPath.fromAbsoluteUri(assetUri, name);
  return ModuleSummary(clazz, providers);
}

ProviderSummary _providerFromJson(Map<String, dynamic> json) {
  final name = json['name'] as String;
  final injectedType = InjectedType.fromJson(json['injectedType']);
  final singleton = json['singleton'] as bool;
  final asynchronous = json['asynchronous'] as bool;
  final kind = json['kind'] as String;
  final dependencies = json['dependencies']
      .cast<Map<String, dynamic>>()
      .map<InjectedType>((dependency) => InjectedType.fromJson(dependency))
      .toList();
  return ProviderSummary(
    injectedType,
    name,
    providerKindFromName(kind),
    singleton: singleton,
    asynchronous: asynchronous,
    dependencies: dependencies,
  );
}

InjectableSummary _injectableFromJson(Uri assetUri, Map<String, dynamic> json) {
  final name = json['name'] as String;
  final type = SymbolPath.fromAbsoluteUri(assetUri, name);
  return InjectableSummary(
    type,
    _providerFromJson(json['constructor'].cast<String, dynamic>()),
  );
}
