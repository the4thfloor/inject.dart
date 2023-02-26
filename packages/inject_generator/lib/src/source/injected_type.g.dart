// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'injected_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InjectedType _$InjectedTypeFromJson(Map<String, dynamic> json) => InjectedType(
      LookupKey.fromJson(json['lookupKey'] as Map<String, dynamic>),
      name: json['name'] as String?,
      isNullable: json['isNullable'] as bool?,
      isRequired: json['isRequired'] as bool?,
      isNamed: json['isNamed'] as bool?,
      isProvider: json['isProvider'] as bool?,
      isFeature: json['isFeature'] as bool?,
      isAssisted: json['isAssisted'] as bool?,
    );

Map<String, dynamic> _$InjectedTypeToJson(InjectedType instance) =>
    <String, dynamic>{
      'lookupKey': instance.lookupKey,
      'name': instance.name,
      'isNullable': instance.isNullable,
      'isRequired': instance.isRequired,
      'isNamed': instance.isNamed,
      'isProvider': instance.isProvider,
      'isFeature': instance.isFeature,
      'isAssisted': instance.isAssisted,
    };
