import 'package:json_annotation/json_annotation.dart';

part 'floor.g.dart';

// Indoor node types
enum NodeType {
  entrance,
  exit,
  hall,
  corridor,
  classroom,
  office,
  lab,
  restroom,
  storage,
  stairs,
  elevator,
  cafeteria,
  other,
}

// Indoor node representation
@JsonSerializable()
class IndoorNode {
  final String id;
  final String floorId;
  final String name;
  final String? roomNumber;
  final NodeType type;
  final double x; // Coordinate on floor plan (pixels or meters)
  final double y; // Coordinate on floor plan (pixels or meters)
  final String? description;
  final bool isAccessible; // For wheelchair accessibility

  const IndoorNode({
    required this.id,
    required this.floorId,
    required this.name,
    this.roomNumber,
    required this.type,
    required this.x,
    required this.y,
    this.description,
    this.isAccessible = true,
  });

  factory IndoorNode.fromJson(Map<String, dynamic> json) =>
      _$IndoorNodeFromJson(json);

  Map<String, dynamic> toJson() => _$IndoorNodeToJson(this);

  @override
  String toString() =>
      'Node: $name${roomNumber != null ? " ($roomNumber)" : ""}';
}

// Edge between two nodes
@JsonSerializable()
class IndoorEdge {
  final String from;
  final String to;
  final double distance; // meters
  final bool isBidirectional;

  const IndoorEdge({
    required this.from,
    required this.to,
    required this.distance,
    this.isBidirectional = true,
  });

  factory IndoorEdge.fromJson(Map<String, dynamic> json) =>
      _$IndoorEdgeFromJson(json);

  Map<String, dynamic> toJson() => _$IndoorEdgeToJson(this);
}

// Floor representation
@JsonSerializable(explicitToJson: true)
class Floor {
  final String id;
  final String buildingId;
  final String name;
  final int floorNumber; // 0 for ground, -1 for basement, 1+ for upper floors
  final List<IndoorNode> nodes;
  final List<IndoorEdge> edges;
  final String? floorPlanImageUrl;
  final double? floorPlanWidth; // Real-world width in meters
  final double? floorPlanHeight; // Real-world height in meters

  const Floor({
    required this.id,
    required this.buildingId,
    required this.name,
    required this.floorNumber,
    required this.nodes,
    required this.edges,
    this.floorPlanImageUrl,
    this.floorPlanWidth,
    this.floorPlanHeight,
  });

  factory Floor.fromJson(Map<String, dynamic> json) => _$FloorFromJson(json);

  Map<String, dynamic> toJson() => _$FloorToJson(this);

  // Helper method to find a node by ID
  IndoorNode? findNode(String nodeId) {
    try {
      return nodes.firstWhere((node) => node.id == nodeId);
    } catch (e) {
      return null;
    }
  }

  // Helper method to get connected nodes
  List<String> getConnectedNodes(String nodeId) {
    List<String> connected = [];
    for (var edge in edges) {
      if (edge.from == nodeId) {
        connected.add(edge.to);
      }
      if (edge.isBidirectional && edge.to == nodeId) {
        connected.add(edge.from);
      }
    }
    return connected;
  }

  @override
  String toString() => 'Floor: $name ($floorNumber) - ${nodes.length} nodes';
}
