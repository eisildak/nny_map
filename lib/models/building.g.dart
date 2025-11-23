// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'building.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Building _$BuildingFromJson(Map<String, dynamic> json) => Building(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  floors: (json['floors'] as List<dynamic>)
      .map((e) => Floor.fromJson(e as Map<String, dynamic>))
      .toList(),
  imageUrl: json['imageUrl'] as String?,
  hasIndoorMap: json['hasIndoorMap'] as bool? ?? false,
);

Map<String, dynamic> _$BuildingToJson(Building instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'floors': instance.floors.map((e) => e.toJson()).toList(),
  'imageUrl': instance.imageUrl,
  'hasIndoorMap': instance.hasIndoorMap,
};
