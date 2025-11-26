/// Bina içi bir noktayı temsil eder (oda, koridor, merdiven, vb.)
class FloorNode {
  final String id;
  final double x;
  final double y;
  final String label;
  final NodeType type;

  FloorNode({
    required this.id,
    required this.x,
    required this.y,
    required this.label,
    required this.type,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FloorNode && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum NodeType {
  kapi, // Kapı/Giriş
  koridor, // Koridor
  merdiven, // Merdiven
  mekan, // Oda/Mekan
}

/// İç mekan POI'ı - Odalar, derslikler, ofisler vb.
class FloorPOI {
  final String id;
  final String name;
  final String description;
  final double x;
  final double y;
  final int floorId;
  final POICategory category;
  final String? roomNumber;
  final String? phone;
  final String? email;
  final List<String>? openHours;

  FloorPOI({
    required this.id,
    required this.name,
    required this.description,
    required this.x,
    required this.y,
    required this.floorId,
    required this.category,
    this.roomNumber,
    this.phone,
    this.email,
    this.openHours,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FloorPOI && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum POICategory {
  ofis, // Ofis
  derslik, // Derslik/Sınıf
  lab, // Laboratuvar
  amfi, // Amfi
  yonetim, // Yönetim
  servis, // Servis (WC, kantin vb)
  toplanti, // Toplantı Salonu
  kutuphane, // Kütüphane
  diger, // Diğer
}

/// Bir binanın bir katını temsil eder
class BuildingFloor {
  final int id;
  final String name;
  final String? mapImagePath;
  final List<FloorNode> nodes;
  final List<Edge> edges;
  final List<FloorPOI> pois;

  BuildingFloor({
    required this.id,
    required this.name,
    this.mapImagePath,
    required this.nodes,
    required this.edges,
    this.pois = const [],
  });

  FloorNode? findNode(String nodeId) {
    try {
      return nodes.firstWhere((node) => node.id == nodeId);
    } catch (e) {
      return null;
    }
  }

  FloorPOI? findPOI(String poiId) {
    try {
      return pois.firstWhere((poi) => poi.id == poiId);
    } catch (e) {
      return null;
    }
  }
}

/// İki nokta arasındaki bağlantı
class Edge {
  final String from;
  final String to;

  Edge(this.from, this.to);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Edge &&
          runtimeType == other.runtimeType &&
          ((from == other.from && to == other.to) ||
              (from == other.to && to == other.from));

  @override
  int get hashCode => from.hashCode ^ to.hashCode;
}

/// Bina bilgilerini tutan sınıf
class IndoorBuilding {
  final String name;
  final Map<int, BuildingFloor> floors;

  IndoorBuilding({required this.name, required this.floors});

  BuildingFloor? getFloor(int floorId) {
    return floors[floorId];
  }

  List<int> get floorIds => floors.keys.toList()..sort();
}
