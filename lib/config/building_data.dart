import '../models/indoor_building.dart';

/// Mühendislik Fakültesi bina verisi
class EngineeringBuildingData {
  static IndoorBuilding get building => IndoorBuilding(
    name: "Mühendislik Fakültesi",
    floors: {
      0: BuildingFloor(
        id: 0,
        name: "Zemin Kat",
        nodes: [
          FloorNode(
            id: 'giris',
            x: 550,
            y: 650,
            label: "Ana Giriş",
            type: NodeType.kapi,
          ),
          FloorNode(
            id: 'hol_z',
            x: 550,
            y: 500,
            label: "Ana Hol",
            type: NodeType.koridor,
          ),
          FloorNode(
            id: 'koridor_merkez_z',
            x: 550,
            y: 350,
            label: "Merkez Koridor",
            type: NodeType.koridor,
          ),
          FloorNode(
            id: 'koridor_sol_z',
            x: 250,
            y: 350,
            label: "Sol Koridor",
            type: NodeType.koridor,
          ),
          FloorNode(
            id: 'koridor_sag_z',
            x: 850,
            y: 350,
            label: "Sağ Koridor",
            type: NodeType.koridor,
          ),
          FloorNode(
            id: 'merdiven_z',
            x: 550,
            y: 200,
            label: "Merdivenler",
            type: NodeType.merdiven,
          ),
        ],
        edges: [
          Edge('giris', 'hol_z'),
          Edge('hol_z', 'koridor_merkez_z'),
          Edge('koridor_merkez_z', 'koridor_sol_z'),
          Edge('koridor_merkez_z', 'koridor_sag_z'),
          Edge('koridor_merkez_z', 'merdiven_z'),
        ],
        pois: [
          FloorPOI(
            id: 'z_ogrenci_isleri',
            name: 'Öğrenci İşleri',
            description: 'Öğrenci kayıt, transkript ve belge işlemleri',
            x: 200,
            y: 450,
            floorId: 0,
            category: POICategory.yonetim,
            roomNumber: 'Z-101',
            phone: '+90 352 324 00 00',
            openHours: ['Pzt-Cum: 09:00-17:00'],
          ),
          FloorPOI(
            id: 'z_bilgisayar_lab',
            name: 'Bilgisayar Laboratuvarı 1',
            description: '40 bilgisayar kapasiteli lab',
            x: 150,
            y: 250,
            floorId: 0,
            category: POICategory.lab,
            roomNumber: 'Z-105',
          ),
          FloorPOI(
            id: 'z_konferans',
            name: 'Konferans Salonu',
            description: '200 kişilik konferans salonu',
            x: 550,
            y: 150,
            floorId: 0,
            category: POICategory.toplanti,
            roomNumber: 'Z-200',
          ),
          FloorPOI(
            id: 'z_kantin',
            name: 'Kantin',
            description: 'Fakülte kantini',
            x: 750,
            y: 550,
            floorId: 0,
            category: POICategory.servis,
            roomNumber: 'Z-001',
            openHours: ['Pzt-Cum: 08:00-18:00'],
          ),
          FloorPOI(
            id: 'z_wc',
            name: 'WC',
            description: 'Tuvalet',
            x: 900,
            y: 350,
            floorId: 0,
            category: POICategory.servis,
          ),
        ],
      ),
      1: BuildingFloor(
        id: 1,
        name: "1. Kat",
        nodes: [
          FloorNode(
            id: 'merdiven_1',
            x: 550,
            y: 200,
            label: "Merdivenler",
            type: NodeType.merdiven,
          ),
          FloorNode(
            id: 'koridor_1_orta',
            x: 550,
            y: 350,
            label: "Orta Koridor",
            type: NodeType.koridor,
          ),
          FloorNode(
            id: 'koridor_1_sol',
            x: 250,
            y: 350,
            label: "Sol Koridor",
            type: NodeType.koridor,
          ),
          FloorNode(
            id: 'koridor_1_sag',
            x: 850,
            y: 350,
            label: "Sağ Koridor",
            type: NodeType.koridor,
          ),
        ],
        edges: [
          Edge('merdiven_1', 'koridor_1_orta'),
          Edge('koridor_1_orta', 'koridor_1_sol'),
          Edge('koridor_1_orta', 'koridor_1_sag'),
        ],
        pois: [
          FloorPOI(
            id: '1_dekanlik',
            name: 'Dekanlık',
            description: 'Mühendislik Fakültesi Dekanlığı',
            x: 850,
            y: 250,
            floorId: 1,
            category: POICategory.yonetim,
            roomNumber: '1-201',
            phone: '+90 352 324 00 01',
            email: 'muhendislik@nny.edu.tr',
            openHours: ['Pzt-Cum: 09:00-17:00'],
          ),
          FloorPOI(
            id: '1_amfi_101',
            name: 'Amfi 101',
            description: '150 kişilik amfi derslik',
            x: 200,
            y: 250,
            floorId: 1,
            category: POICategory.amfi,
            roomNumber: '1-101',
          ),
          FloorPOI(
            id: '1_lab_elektronik',
            name: 'Elektronik Laboratuvarı',
            description: 'Elektronik deney labı',
            x: 300,
            y: 450,
            floorId: 1,
            category: POICategory.lab,
            roomNumber: '1-105',
          ),
          FloorPOI(
            id: '1_wc',
            name: 'WC',
            description: 'Tuvalet',
            x: 650,
            y: 150,
            floorId: 1,
            category: POICategory.servis,
          ),
        ],
      ),
      2: BuildingFloor(
        id: 2,
        name: "2. Kat",
        nodes: [
          FloorNode(
            id: 'merdiven_2',
            x: 550,
            y: 200,
            label: "Merdivenler",
            type: NodeType.merdiven,
          ),
          FloorNode(
            id: 'koridor_2_uzun',
            x: 550,
            y: 400,
            label: "Koridor",
            type: NodeType.koridor,
          ),
          FloorNode(
            id: 'koridor_2_sol',
            x: 250,
            y: 400,
            label: "Sol Koridor",
            type: NodeType.koridor,
          ),
          FloorNode(
            id: 'koridor_2_sag',
            x: 850,
            y: 400,
            label: "Sağ Koridor",
            type: NodeType.koridor,
          ),
        ],
        edges: [
          Edge('merdiven_2', 'koridor_2_uzun'),
          Edge('koridor_2_uzun', 'koridor_2_sol'),
          Edge('koridor_2_uzun', 'koridor_2_sag'),
        ],
        pois: [
          FloorPOI(
            id: '2_derslik_201',
            name: 'Derslik 201',
            description: '40 kişilik derslik',
            x: 250,
            y: 300,
            floorId: 2,
            category: POICategory.derslik,
            roomNumber: '2-201',
          ),
          FloorPOI(
            id: '2_derslik_202',
            name: 'Derslik 202',
            description: '40 kişilik derslik',
            x: 850,
            y: 300,
            floorId: 2,
            category: POICategory.derslik,
            roomNumber: '2-202',
          ),
          FloorPOI(
            id: '2_ogretim_uyesi_1',
            name: 'Öğretim Üyesi Odası 1',
            description: 'Prof. Dr. Ahmet Yılmaz',
            x: 350,
            y: 500,
            floorId: 2,
            category: POICategory.ofis,
            roomNumber: '2-210',
            email: 'ayilmaz@nny.edu.tr',
          ),
          FloorPOI(
            id: '2_ogretim_uyesi_2',
            name: 'Öğretim Üyesi Odası 2',
            description: 'Doç. Dr. Ayşe Demir',
            x: 750,
            y: 500,
            floorId: 2,
            category: POICategory.ofis,
            roomNumber: '2-211',
            email: 'ademir@nny.edu.tr',
          ),
          FloorPOI(
            id: '2_kutuphane',
            name: 'Fakülte Kütüphanesi',
            description: 'Teknik kitap ve dergi arşivi',
            x: 550,
            y: 550,
            floorId: 2,
            category: POICategory.kutuphane,
            roomNumber: '2-250',
            openHours: ['Pzt-Cum: 08:30-19:00'],
          ),
        ],
      ),
    },
  );

  /// Katlar arası bağlantılar (merdivenler)
  static List<Edge> get interFloorConnections => [
    Edge('merdiven_z', 'merdiven_1'),
    Edge('merdiven_1', 'merdiven_2'),
  ];

  /// Tüm node'ları tek listede döndürür
  static List<FloorNode> get allNodes {
    return building.floors.values.expand((floor) => floor.nodes).toList();
  }

  /// Tüm edge'leri tek listede döndürür
  static List<Edge> get allEdges {
    return building.floors.values.expand((floor) => floor.edges).toList();
  }

  /// Hedef olarak seçilebilecek node'lar (koridor ve merdiven hariç)
  static List<FloorNode> get targetNodes {
    return allNodes
        .where(
          (node) =>
              node.type != NodeType.koridor && node.type != NodeType.merdiven,
        )
        .toList();
  }
}
