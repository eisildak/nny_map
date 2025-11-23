// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'floor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IndoorNode _$IndoorNodeFromJson(Map<String, dynamic> json) => IndoorNode(
  id: json['id'] as String,
  floorId: json['floorId'] as String,
  name: json['name'] as String,
  roomNumber: json['roomNumber'] as String?,
  type: $enumDecode(_$NodeTypeEnumMap, json['type']),
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
  description: json['description'] as String?,
  isAccessible: json['isAccessible'] as bool? ?? true,
);

Map<String, dynamic> _$IndoorNodeToJson(IndoorNode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'floorId': instance.floorId,
      'name': instance.name,
      'roomNumber': instance.roomNumber,
      'type': _$NodeTypeEnumMap[instance.type]!,
      'x': instance.x,
      'y': instance.y,
      'description': instance.description,
      'isAccessible': instance.isAccessible,
    };

const _$NodeTypeEnumMap = {
  NodeType.entrance: 'entrance',
  NodeType.exit: 'exit',
  NodeType.hall: 'hall',
  NodeType.corridor: 'corridor',
  NodeType.classroom: 'classroom',
  NodeType.office: 'office',
  NodeType.lab: 'lab',
  NodeType.restroom: 'restroom',
  NodeType.storage: 'storage',
  NodeType.stairs: 'stairs',
  NodeType.elevator: 'elevator',
  NodeType.cafeteria: 'cafeteria',
  NodeType.other: 'other',
};

IndoorEdge _$IndoorEdgeFromJson(Map<String, dynamic> json) => IndoorEdge(
  from: json['from'] as String,
  to: json['to'] as String,
  distance: (json['distance'] as num).toDouble(),
  isBidirectional: json['isBidirectional'] as bool? ?? true,
);

Map<String, dynamic> _$IndoorEdgeToJson(IndoorEdge instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'distance': instance.distance,
      'isBidirectional': instance.isBidirectional,
    };

Floor _$FloorFromJson(Map<String, dynamic> json) => Floor(
  id: json['id'] as String,
  buildingId: json['buildingId'] as String,
  name: json['name'] as String,
  floorNumber: (json['floorNumber'] as num).toInt(),
  nodes: (json['nodes'] as List<dynamic>)
      .map((e) => IndoorNode.fromJson(e as Map<String, dynamic>))
      .toList(),
  edges: (json['edges'] as List<dynamic>)
      .map((e) => IndoorEdge.fromJson(e as Map<String, dynamic>))
      .toList(),
  floorPlanImageUrl: json['floorPlanImageUrl'] as String?,
  floorPlanWidth: (json['floorPlanWidth'] as num?)?.toDouble(),
  floorPlanHeight: (json['floorPlanHeight'] as num?)?.toDouble(),
);

Map<String, dynamic> _$FloorToJson(Floor instance) => <String, dynamic>{
  'id': instance.id,
  'buildingId': instance.buildingId,
  'name': instance.name,
  'floorNumber': instance.floorNumber,
  'nodes': instance.nodes.map((e) => e.toJson()).toList(),
  'edges': instance.edges.map((e) => e.toJson()).toList(),
  'floorPlanImageUrl': instance.floorPlanImageUrl,
  'floorPlanWidth': instance.floorPlanWidth,
  'floorPlanHeight': instance.floorPlanHeight,
};
