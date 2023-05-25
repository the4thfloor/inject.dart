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

  /// Dependencies required to create an instance of [injectedType].
  final List<InjectedType> dependencies;

  /// Create a new summary of a provider that returns an instance of
  /// [injectedType].
  factory ProviderSummary(
    String name,
    ProviderKind kind,
    InjectedType injectedType, {
    Iterable<InjectedType> dependencies = const [],
  }) =>
      ProviderSummary._(
        name,
        kind,
        injectedType,
        List<InjectedType>.unmodifiable(dependencies),
      );

  const ProviderSummary._(
    this.name,
    this.kind,
    this.injectedType,
    this.dependencies,
  );

  factory ProviderSummary.fromJson(Map<String, dynamic> json) => _$ProviderSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderSummaryToJson(this);
}
