// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lookup_key.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LookupKey _$LookupKeyFromJson(Map<String, dynamic> json) => LookupKey(
      SymbolPath.fromJson(json['root'] as Map<String, dynamic>),
      qualifier: json['qualifier'] == null
          ? null
          : SymbolPath.fromJson(json['qualifier'] as Map<String, dynamic>),
      typeArguments: (json['typeArguments'] as List<dynamic>?)
          ?.map((e) => SymbolPath.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LookupKeyToJson(LookupKey instance) => <String, dynamic>{
      'root': instance.root,
      'qualifier': instance.qualifier,
      'typeArguments': instance.typeArguments,
    };
