// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'symbol_path.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SymbolPath _$SymbolPathFromJson(Map<String, dynamic> json) => SymbolPath(
      json['package'] as String,
      json['path'] as String,
      json['symbol'] as String,
    );

Map<String, dynamic> _$SymbolPathToJson(SymbolPath instance) =>
    <String, dynamic>{
      'package': instance.package,
      'path': instance.path,
      'symbol': instance.symbol,
    };
