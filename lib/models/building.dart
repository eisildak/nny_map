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

  // Kat planından elde edilen odalar ve bağlantılar (Gemini ile düzenlenmiş zemin kat)
  static List<IndoorNode> _getGroundFloorNodes() {
    return [
      // --- GİRİŞ BÖLÜMÜ ---
      const IndoorNode(
        id: 'giris',
        floorId: 'ground-floor',
        name: 'Ana Giriş',
        type: NodeType.entrance,
        x: 375,
        y: 550,
        description: 'Ana giriş kapısı',
      ),
      const IndoorNode(
        id: 'guvenlik',
        floorId: 'ground-floor',
        name: 'Güvenlik',
        type: NodeType.office,
        x: 440,
        y: 475,
        description: 'Güvenlik & Kontrol',
      ),
      const IndoorNode(
        id: 'giris-koridor',
        floorId: 'ground-floor',
        name: 'Giriş Koridoru',
        type: NodeType.corridor,
        x: 375,
        y: 415,
      ),

      // --- SOL KANAT (A BLOK) ---
      const IndoorNode(
        id: 'amfi-1',
        floorId: 'ground-floor',
        name: 'Amfi 1',
        roomNumber: 'Amfi 1',
        type: NodeType.classroom,
        x: 90,
        y: 80,
        description: '80 Kişi',
      ),
      const IndoorNode(
        id: 'derslik-a1',
        floorId: 'ground-floor',
        name: 'Derslik A1',
        roomNumber: 'A1',
        type: NodeType.classroom,
        x: 52,
        y: 190,
        description: '30 Kişi',
      ),
      const IndoorNode(
        id: 'derslik-a2',
        floorId: 'ground-floor',
        name: 'Derslik A2',
        roomNumber: 'A2',
        type: NodeType.classroom,
        x: 127,
        y: 190,
        description: '30 Kişi',
      ),
      const IndoorNode(
        id: 'derslik-a3',
        floorId: 'ground-floor',
        name: 'Derslik A3',
        roomNumber: 'A3',
        type: NodeType.classroom,
        x: 52,
        y: 280,
        description: '30 Kişi',
      ),
      const IndoorNode(
        id: 'derslik-a4',
        floorId: 'ground-floor',
        name: 'Derslik A4',
        roomNumber: 'A4',
        type: NodeType.classroom,
        x: 127,
        y: 280,
        description: '30 Kişi',
      ),
      const IndoorNode(
        id: 'amfi-2',
        floorId: 'ground-floor',
        name: 'Amfi 2',
        roomNumber: 'Amfi 2',
        type: NodeType.classroom,
        x: 90,
        y: 390,
        description: '80 Kişi',
      ),

      // --- MERDİVENLER ---
      // Sol küçük merdiven (Amfi 1 yanında)
      const IndoorNode(
        id: 'merdiven-sol',
        floorId: 'ground-floor',
        name: 'Sol Merdiven',
        roomNumber: 'M1',
        type: NodeType.stairs,
        x: 295,
        y: 150,
        description: 'A Blok Merdiven',
      ),
      // Sağ küçük merdiven (Amfi 3 yanında)
      const IndoorNode(
        id: 'merdiven-sag',
        floorId: 'ground-floor',
        name: 'Sağ Merdiven',
        roomNumber: 'M3',
        type: NodeType.stairs,
        x: 835,
        y: 150,
        description: 'B Blok Merdiven',
      ),

      // --- ORTA BLOK (İdari & Sosyal) ---
      // Büyük orta merdiven (Skr ve Öğr.1 arasında)
      const IndoorNode(
        id: 'merdiven-orta',
        floorId: 'ground-floor',
        name: 'Ana Merdiven',
        roomNumber: 'M2',
        type: NodeType.stairs,
        x: 425,
        y: 175,
        description: 'Orta Merdiven',
      ),
      const IndoorNode(
        id: 'bolum-bsk',
        floorId: 'ground-floor',
        name: 'Bölüm Başkanlığı',
        roomNumber: 'Bşk.',
        type: NodeType.office,
        x: 245,
        y: 175,
        description: 'Müdür Odası',
      ),
      const IndoorNode(
        id: 'sekreterlik',
        floorId: 'ground-floor',
        name: 'Sekreterlik',
        roomNumber: 'Skr.',
        type: NodeType.office,
        x: 300,
        y: 175,
        description: 'Danışma',
      ),
      const IndoorNode(
        id: 'wc-bay',
        floorId: 'ground-floor',
        name: 'WC Bay',
        type: NodeType.restroom,
        x: 350,
        y: 175,
      ),
      const IndoorNode(
        id: 'wc-bayan',
        floorId: 'ground-floor',
        name: 'WC Bayan',
        type: NodeType.restroom,
        x: 400,
        y: 175,
      ),
      const IndoorNode(
        id: 'kantin',
        floorId: 'ground-floor',
        name: 'Orta Hol / Dinlenme',
        type: NodeType.cafeteria,
        x: 375,
        y: 235,
        description: 'Ortak Alan',
      ),
      const IndoorNode(
        id: 'ogr-gor-1',
        floorId: 'ground-floor',
        name: 'Öğr. Gör. 1',
        roomNumber: 'Öğr.1',
        type: NodeType.office,
        x: 450,
        y: 175,
        description: 'Ofis',
      ),
      const IndoorNode(
        id: 'ogr-gor-2',
        floorId: 'ground-floor',
        name: 'Öğr. Gör. 2',
        roomNumber: 'Öğr.2',
        type: NodeType.office,
        x: 505,
        y: 175,
        description: 'Ofis',
      ),

      // --- SAĞ KANAT (B BLOK) ---
      const IndoorNode(
        id: 'amfi-3',
        floorId: 'ground-floor',
        name: 'Amfi 3',
        roomNumber: 'Amfi 3',
        type: NodeType.classroom,
        x: 660,
        y: 80,
        description: '80 Kişi',
      ),
      const IndoorNode(
        id: 'derslik-b1',
        floorId: 'ground-floor',
        name: 'Derslik B1',
        roomNumber: 'B1',
        type: NodeType.classroom,
        x: 622,
        y: 190,
        description: '30 Kişi',
      ),
      const IndoorNode(
        id: 'derslik-b2',
        floorId: 'ground-floor',
        name: 'Derslik B2',
        roomNumber: 'B2',
        type: NodeType.classroom,
        x: 697,
        y: 190,
        description: '30 Kişi',
      ),
      const IndoorNode(
        id: 'derslik-b3',
        floorId: 'ground-floor',
        name: 'Derslik B3',
        roomNumber: 'B3',
        type: NodeType.classroom,
        x: 622,
        y: 280,
        description: '30 Kişi',
      ),
      const IndoorNode(
        id: 'derslik-b4',
        floorId: 'ground-floor',
        name: 'Derslik B4',
        roomNumber: 'B4',
        type: NodeType.classroom,
        x: 697,
        y: 280,
        description: '30 Kişi',
      ),
      const IndoorNode(
        id: 'amfi-4',
        floorId: 'ground-floor',
        name: 'Amfi 4',
        roomNumber: 'Amfi 4',
        type: NodeType.classroom,
        x: 660,
        y: 390,
        description: '80 Kişi',
      ),

      // --- KORİDORLAR (Navigasyon düğümleri) ---
      const IndoorNode(
        id: 'koridor-a',
        floorId: 'ground-floor',
        name: 'A Blok Koridor',
        type: NodeType.corridor,
        x: 175,
        y: 235,
      ),
      const IndoorNode(
        id: 'koridor-b',
        floorId: 'ground-floor',
        name: 'B Blok Koridor',
        type: NodeType.corridor,
        x: 575,
        y: 235,
      ),
      const IndoorNode(
        id: 'ana-koridor',
        floorId: 'ground-floor',
        name: 'Ana Koridor',
        type: NodeType.corridor,
        x: 375,
        y: 285,
      ),
    ];
  }

  static List<IndoorEdge> _getGroundFloorEdges() {
    return [
      // Ana giriş -> Giriş koridoru -> Ana koridor
      const IndoorEdge(from: 'giris', to: 'giris-koridor', distance: 15.0),
      const IndoorEdge(from: 'giris-koridor', to: 'guvenlik', distance: 8.0),
      const IndoorEdge(
        from: 'giris-koridor',
        to: 'ana-koridor',
        distance: 20.0,
      ),

      // Ana koridor -> Orta Blok
      const IndoorEdge(from: 'ana-koridor', to: 'kantin', distance: 10.0),
      const IndoorEdge(from: 'kantin', to: 'merdiven-orta', distance: 20.0),
      const IndoorEdge(from: 'kantin', to: 'bolum-bsk', distance: 15.0),
      const IndoorEdge(from: 'kantin', to: 'sekreterlik', distance: 12.0),
      const IndoorEdge(from: 'kantin', to: 'wc-bay', distance: 10.0),
      const IndoorEdge(from: 'kantin', to: 'wc-bayan', distance: 12.0),
      const IndoorEdge(from: 'kantin', to: 'ogr-gor-1', distance: 15.0),
      const IndoorEdge(from: 'kantin', to: 'ogr-gor-2', distance: 17.0),

      // Ana koridor -> Koridorlar
      const IndoorEdge(from: 'ana-koridor', to: 'koridor-a', distance: 15.0),
      const IndoorEdge(from: 'ana-koridor', to: 'koridor-b', distance: 15.0),

      // A Blok Koridor -> Odalar ve Merdiven
      const IndoorEdge(from: 'koridor-a', to: 'amfi-1', distance: 20.0),
      const IndoorEdge(from: 'koridor-a', to: 'derslik-a1', distance: 12.0),
      const IndoorEdge(from: 'koridor-a', to: 'derslik-a2', distance: 10.0),
      const IndoorEdge(from: 'koridor-a', to: 'derslik-a3', distance: 12.0),
      const IndoorEdge(from: 'koridor-a', to: 'derslik-a4', distance: 10.0),
      const IndoorEdge(from: 'koridor-a', to: 'amfi-2', distance: 20.0),
      const IndoorEdge(from: 'koridor-a', to: 'merdiven-sol', distance: 8.0),

      // B Blok Koridor -> Odalar ve Merdiven
      const IndoorEdge(from: 'koridor-b', to: 'amfi-3', distance: 20.0),
      const IndoorEdge(from: 'koridor-b', to: 'derslik-b1', distance: 12.0),
      const IndoorEdge(from: 'koridor-b', to: 'derslik-b2', distance: 10.0),
      const IndoorEdge(from: 'koridor-b', to: 'derslik-b3', distance: 12.0),
      const IndoorEdge(from: 'koridor-b', to: 'derslik-b4', distance: 10.0),
      const IndoorEdge(from: 'koridor-b', to: 'amfi-4', distance: 20.0),
      const IndoorEdge(from: 'koridor-b', to: 'merdiven-sag', distance: 8.0),
    ];
  }

  static List<Building> getAllBuildings() {
    return [engineeringFaculty];
  }
}
