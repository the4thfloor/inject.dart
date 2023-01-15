// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of inject.src.summary;

/// The kind of provider.
enum ProviderKind {
  /// The provider is implemented as a constructor or a `factory`.
  constructor,

  /// The provider is implemented as a method.
  method,

  /// The provider is implemented as a getter.
  getter,
}

/// Maps between [ProviderKind] enum values and their names.
final BiMap<ProviderKind, String> _providerKindNames =
    BiMap<ProviderKind, String>()
      ..[ProviderKind.constructor] = 'constructor'
      ..[ProviderKind.method] = 'method'
      ..[ProviderKind.getter] = 'getter';

/// Converts provider [name] to the corresponding `enum` reference.
ProviderKind providerKindFromName(String name) {
  final kind = _providerKindNames.inverse[name];

  if (kind == null) {
    throw ArgumentError.value(name, 'name', 'Invalid provider kind name');
  }

  return kind;
}

/// Converts a provider [kind] to its name.
///
/// See also [providerKindFromName].
String provideKindName(ProviderKind kind) {
  final name = _providerKindNames[kind];

  if (name == null) {
    throw ArgumentError.value(kind, 'kind', 'Unrecognized provider kind');
  }

  return name;
}

/// Contains information about a method, constructor, factory or a getter
/// annotated with `@inject` or `@provides`.
class ProviderSummary {
  /// Name of the annotated method.
  final String name;

  /// Provider kind.
  final ProviderKind kind;

  /// Type of the instance that will be returned.
  final InjectedType injectedType;

  /// Whether or not this provider provides a singleton.
  final bool isSingleton;

  /// Factory used to create an instance of [injectedType].
  /// Only for ConstructorProvider and currently only used for Assisted Inject.
  final LookupKey? factory;

  /// Whether this provider is annotated with `@asynchronous`.
  final bool isAsynchronous;

  /// Dependencies required to create an instance of [injectedType].
  final List<InjectedType> dependencies;

  /// Create a new summary of a provider that returns an instance of
  /// [injectedType].
  factory ProviderSummary(
    String name,
    ProviderKind kind,
    InjectedType injectedType, {
    bool singleton = false,
    LookupKey? factory,
    bool asynchronous = false,
    List<InjectedType> dependencies = const [],
  }) {
    return ProviderSummary._(
      name,
      kind,
      injectedType,
      singleton,
      factory,
      asynchronous,
      List<InjectedType>.unmodifiable(dependencies),
    );
  }

  const ProviderSummary._(
    this.name,
    this.kind,
    this.injectedType,
    this.isSingleton,
    this.factory,
    this.isAsynchronous,
    this.dependencies,
  );

  /// Returns a new instance from the JSON encoding of an instance.
  ///
  /// See also [ProviderSummary.toJson].
  factory ProviderSummary.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    final kind = json['kind'] as String;
    final injectedType = InjectedType.fromJson(json['injectedType']);
    final singleton = json['singleton'] as bool;
    final factory =
        json['factory'] != null ? LookupKey.fromJson(json['factory']) : null;
    final asynchronous = json['asynchronous'] as bool;
    final dependencies = json['dependencies']
        .cast<Map<String, dynamic>>()
        .map<InjectedType>(InjectedType.fromJson)
        .toList();
    return ProviderSummary(
      name,
      providerKindFromName(kind),
      injectedType,
      singleton: singleton,
      factory: factory,
      asynchronous: asynchronous,
      dependencies: dependencies,
    );
  }

  /// Serializes this summary to JSON.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'kind': provideKindName(kind),
      'injectedType': injectedType,
      'singleton': isSingleton,
      'factory': factory,
      'asynchronous': isAsynchronous,
      'dependencies': dependencies
    };
  }
}
