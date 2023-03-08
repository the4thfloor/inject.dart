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
@JsonSerializable()
class ProviderSummary {
  /// Name of the annotated method.
  final String name;

  /// Provider kind.
  final ProviderKind kind;

  /// Type of the instance that will be returned.
  final InjectedType injectedType;

  /// Whether or not this provider provides a singleton.
  final bool isSingleton;

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
    bool isSingleton = false,
    bool isAsynchronous = false,
    Iterable<InjectedType> dependencies = const [],
  }) {
    return ProviderSummary._(
      name,
      kind,
      injectedType,
      isSingleton,
      isAsynchronous,
      List<InjectedType>.unmodifiable(dependencies),
    );
  }

  const ProviderSummary._(
    this.name,
    this.kind,
    this.injectedType,
    this.isSingleton,
    this.isAsynchronous,
    this.dependencies,
  );

  factory ProviderSummary.fromJson(Map<String, dynamic> json) =>
      _$ProviderSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderSummaryToJson(this);
}
