import 'package:json_annotation/json_annotation.dart';
import 'floor.dart';

part 'building.g.dart';

@JsonSerializable(explicitToJson: true)
class Building {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final List<Floor> floors;
  final String? imageUrl;
  final bool hasIndoorMap;

  const Building({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.floors,
    this.imageUrl,
    this.hasIndoorMap = false,
  });

  factory Building.fromJson(Map<String, dynamic> json) =>
      _$BuildingFromJson(json);

  Map<String, dynamic> toJson() => _$BuildingToJson(this);

  @override
  String toString() => 'Building: $name (${floors.length} floors)';
}

// Mühendislik Fakültesi verisi
class BuildingData {
  static final Building engineeringFaculty = Building(
    id: 'muhendislik-fakultesi',
    name: 'Mühendislik Fakültesi',
    description:
        'NNY Mühendislik Fakültesi - Bilgisayar, Elektrik-Elektronik, Endüstri Mühendisliği',
    latitude: 38.786820,
    longitude: 35.406947,
    hasIndoorMap: true,
    floors: [
      Floor(
        id: 'ground-floor',
        buildingId: 'muhendislik-fakultesi',
        name: 'Giriş Katı',
        floorNumber: 0,
        nodes: _getGroundFloorNodes(),
        edges: _getGroundFloorEdges(),
      ),
    ],
  );

  // Kat planından elde edilen odalar ve bağlantılar
  static List<IndoorNode> _getGroundFloorNodes() {
    return [
      // Ana Giriş ve Koridor
      const IndoorNode(
        id: 'main-entrance',
        floorId: 'ground-floor',
        name: 'Ana Giriş',
        type: NodeType.entrance,
        x: 400,
        y: 580,
      ),
      const IndoorNode(
        id: 'central-hall',
        floorId: 'ground-floor',
        name: 'Merkez Hol (209)',
        roomNumber: '209',
        type: NodeType.hall,
        x: 310,
        y: 340,
      ),

      // Sol Kanat - Ofisler ve Sınıflar
      const IndoorNode(
        id: 'room-207',
        floorId: 'ground-floor',
        name: 'Oda 207',
        roomNumber: '207',
        type: NodeType.office,
        x: 110,
        y: 180,
      ),
      const IndoorNode(
        id: 'room-206',
        floorId: 'ground-floor',
        name: 'Oda 206',
        roomNumber: '206',
        type: NodeType.classroom,
        x: 230,
        y: 130,
      ),
      const IndoorNode(
        id: 'room-205',
        floorId: 'ground-floor',
        name: 'Oda 205',
        roomNumber: '205',
        type: NodeType.classroom,
        x: 360,
        y: 130,
      ),
      const IndoorNode(
        id: 'room-208',
        floorId: 'ground-floor',
        name: 'Oda 208',
        roomNumber: '208',
        type: NodeType.office,
        x: 110,
        y: 340,
      ),
      const IndoorNode(
        id: 'room-210',
        floorId: 'ground-floor',
        name: 'Oda 210',
        roomNumber: '210',
        type: NodeType.classroom,
        x: 110,
        y: 450,
      ),

      // Sağ Kanat - Sınıflar ve Laboratuvarlar
      const IndoorNode(
        id: 'room-204',
        floorId: 'ground-floor',
        name: 'Oda 204',
        roomNumber: '204',
        type: NodeType.classroom,
        x: 520,
        y: 180,
      ),
      const IndoorNode(
        id: 'room-203',
        floorId: 'ground-floor',
        name: 'Oda 203',
        roomNumber: '203',
        type: NodeType.classroom,
        x: 550,
        y: 240,
      ),
      const IndoorNode(
        id: 'room-201',
        floorId: 'ground-floor',
        name: 'Oda 201',
        roomNumber: '201',
        type: NodeType.lab,
        x: 480,
        y: 420,
      ),
      const IndoorNode(
        id: 'room-202',
        floorId: 'ground-floor',
        name: 'Oda 202',
        roomNumber: '202',
        type: NodeType.lab,
        x: 480,
        y: 500,
      ),

      // Alt Bölüm - Tuvaletler ve Depolar
      const IndoorNode(
        id: 'room-211',
        floorId: 'ground-floor',
        name: 'Oda 211',
        roomNumber: '211',
        type: NodeType.storage,
        x: 130,
        y: 530,
      ),
      const IndoorNode(
        id: 'room-212',
        floorId: 'ground-floor',
        name: 'Oda 212',
        roomNumber: '212',
        type: NodeType.restroom,
        x: 60,
        y: 530,
      ),
      const IndoorNode(
        id: 'room-213',
        floorId: 'ground-floor',
        name: 'Oda 213',
        roomNumber: '213',
        type: NodeType.restroom,
        x: 60,
        y: 580,
      ),

      // Merdivenler
      const IndoorNode(
        id: 'stairs-main',
        floorId: 'ground-floor',
        name: 'Ana Merdiven',
        type: NodeType.stairs,
        x: 450,
        y: 150,
      ),
      const IndoorNode(
        id: 'stairs-secondary',
        floorId: 'ground-floor',
        name: 'Yan Merdiven',
        type: NodeType.stairs,
        x: 240,
        y: 580,
      ),

      // Koridor Düğümleri (Navigasyon için)
      const IndoorNode(
        id: 'corridor-1',
        floorId: 'ground-floor',
        name: 'Koridor 1',
        type: NodeType.corridor,
        x: 180,
        y: 340,
      ),
      const IndoorNode(
        id: 'corridor-2',
        floorId: 'ground-floor',
        name: 'Koridor 2',
        type: NodeType.corridor,
        x: 310,
        y: 220,
      ),
      const IndoorNode(
        id: 'corridor-3',
        floorId: 'ground-floor',
        name: 'Koridor 3',
        type: NodeType.corridor,
        x: 450,
        y: 340,
      ),
    ];
  }

  static List<IndoorEdge> _getGroundFloorEdges() {
    return [
      // Ana giriş bağlantıları
      const IndoorEdge(
        from: 'main-entrance',
        to: 'central-hall',
        distance: 25.0,
      ),

      // Merkez holden koridor bağlantıları
      const IndoorEdge(from: 'central-hall', to: 'corridor-1', distance: 15.0),
      const IndoorEdge(from: 'central-hall', to: 'corridor-2', distance: 15.0),
      const IndoorEdge(from: 'central-hall', to: 'corridor-3', distance: 15.0),

      // Sol kanat bağlantıları
      const IndoorEdge(from: 'corridor-1', to: 'room-207', distance: 10.0),
      const IndoorEdge(from: 'corridor-1', to: 'room-208', distance: 8.0),
      const IndoorEdge(from: 'corridor-1', to: 'room-210', distance: 12.0),

      // Üst koridor bağlantıları
      const IndoorEdge(from: 'corridor-2', to: 'room-206', distance: 10.0),
      const IndoorEdge(from: 'corridor-2', to: 'room-205', distance: 15.0),
      const IndoorEdge(from: 'corridor-2', to: 'stairs-main', distance: 18.0),

      // Sağ kanat bağlantıları
      const IndoorEdge(from: 'corridor-3', to: 'room-204', distance: 12.0),
      const IndoorEdge(from: 'corridor-3', to: 'room-203', distance: 10.0),
      const IndoorEdge(from: 'corridor-3', to: 'room-201', distance: 15.0),
      const IndoorEdge(from: 'corridor-3', to: 'room-202', distance: 18.0),

      // Alt bölüm bağlantıları
      const IndoorEdge(
        from: 'main-entrance',
        to: 'stairs-secondary',
        distance: 12.0,
      ),
      const IndoorEdge(from: 'stairs-secondary', to: 'room-211', distance: 8.0),
      const IndoorEdge(
        from: 'stairs-secondary',
        to: 'room-212',
        distance: 10.0,
      ),
      const IndoorEdge(from: 'room-212', to: 'room-213', distance: 5.0),

      // Koridor arası bağlantılar
      const IndoorEdge(from: 'corridor-1', to: 'corridor-2', distance: 20.0),
      const IndoorEdge(from: 'corridor-2', to: 'corridor-3', distance: 20.0),
    ];
  }

  static List<Building> getAllBuildings() {
    return [engineeringFaculty];
  }
}
