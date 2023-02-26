// GENERATED CODE - DO NOT MODIFY BY HAND

part of inject.src.summary;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComponentSummary _$ComponentSummaryFromJson(Map<String, dynamic> json) =>
    ComponentSummary(
      SymbolPath.fromJson(json['clazz'] as Map<String, dynamic>),
      (json['modules'] as List<dynamic>)
          .map((e) => SymbolPath.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['providers'] as List<dynamic>)
          .map((e) => ProviderSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ComponentSummaryToJson(ComponentSummary instance) =>
    <String, dynamic>{
      'clazz': instance.clazz,
      'modules': instance.modules,
      'providers': instance.providers,
    };

FactorySummary _$FactorySummaryFromJson(Map<String, dynamic> json) =>
    FactorySummary(
      SymbolPath.fromJson(json['clazz'] as Map<String, dynamic>),
      FactoryMethodSummary.fromJson(json['factory'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FactorySummaryToJson(FactorySummary instance) =>
    <String, dynamic>{
      'clazz': instance.clazz,
      'factory': instance.factory,
    };

FactoryMethodSummary _$FactoryMethodSummaryFromJson(
        Map<String, dynamic> json) =>
    FactoryMethodSummary(
      json['name'] as String,
      InjectedType.fromJson(json['createdType'] as Map<String, dynamic>),
      (json['parameters'] as List<dynamic>)
          .map((e) => InjectedType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FactoryMethodSummaryToJson(
        FactoryMethodSummary instance) =>
    <String, dynamic>{
      'name': instance.name,
      'createdType': instance.createdType,
      'parameters': instance.parameters,
    };

InjectableSummary _$InjectableSummaryFromJson(Map<String, dynamic> json) =>
    InjectableSummary(
      SymbolPath.fromJson(json['clazz'] as Map<String, dynamic>),
      ProviderSummary.fromJson(json['constructor'] as Map<String, dynamic>),
      json['factory'] == null
          ? null
          : LookupKey.fromJson(json['factory'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$InjectableSummaryToJson(InjectableSummary instance) =>
    <String, dynamic>{
      'clazz': instance.clazz,
      'constructor': instance.constructor,
      'factory': instance.factory,
    };

LibrarySummary _$LibrarySummaryFromJson(Map<String, dynamic> json) =>
    LibrarySummary(
      Uri.parse(json['assetUri'] as String),
      components: (json['components'] as List<dynamic>?)
              ?.map((e) => ComponentSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      modules: (json['modules'] as List<dynamic>?)
              ?.map((e) => ModuleSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      injectables: (json['injectables'] as List<dynamic>?)
              ?.map(
                  (e) => InjectableSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      factories: (json['factories'] as List<dynamic>?)
              ?.map((e) => FactorySummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$LibrarySummaryToJson(LibrarySummary instance) =>
    <String, dynamic>{
      'assetUri': instance.assetUri.toString(),
      'components': instance.components,
      'modules': instance.modules,
      'injectables': instance.injectables,
      'factories': instance.factories,
    };

ModuleSummary _$ModuleSummaryFromJson(Map<String, dynamic> json) =>
    ModuleSummary(
      SymbolPath.fromJson(json['clazz'] as Map<String, dynamic>),
      json['hasDefaultConstructor'] as bool,
      (json['providers'] as List<dynamic>)
          .map((e) => ProviderSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ModuleSummaryToJson(ModuleSummary instance) =>
    <String, dynamic>{
      'clazz': instance.clazz,
      'hasDefaultConstructor': instance.hasDefaultConstructor,
      'providers': instance.providers,
    };

ProviderSummary _$ProviderSummaryFromJson(Map<String, dynamic> json) =>
    ProviderSummary(
      json['name'] as String,
      $enumDecode(_$ProviderKindEnumMap, json['kind']),
      InjectedType.fromJson(json['injectedType'] as Map<String, dynamic>),
      dependencies: (json['dependencies'] as List<dynamic>?)
              ?.map((e) => InjectedType.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ProviderSummaryToJson(ProviderSummary instance) =>
    <String, dynamic>{
      'name': instance.name,
      'kind': _$ProviderKindEnumMap[instance.kind]!,
      'injectedType': instance.injectedType,
      'dependencies': instance.dependencies,
    };

const _$ProviderKindEnumMap = {
  ProviderKind.constructor: 'constructor',
  ProviderKind.method: 'method',
  ProviderKind.getter: 'getter',
};
