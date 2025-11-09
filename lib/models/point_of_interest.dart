import 'package:json_annotation/json_annotation.dart';

part 'point_of_interest.g.dart';

@JsonSerializable()
class PointOfInterest {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String category;
  final String? imageUrl;
  final bool isActive;

  const PointOfInterest({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.category,
    this.imageUrl,
    this.isActive = true,
  });

  factory PointOfInterest.fromJson(Map<String, dynamic> json) =>
      _$PointOfInterestFromJson(json);

  Map<String, dynamic> toJson() => _$PointOfInterestToJson(this);

  @override
  String toString() => 'POI: $name ($category)';
}

// NNY Üniversite Kampüsü POI'ları
class POIData {
  static List<PointOfInterest> kayseriMilletBahcesi = [
    // Giriş Kapıları
    const PointOfInterest(
      id: 'giris-kapisi-1',
      name: 'Ana Giriş Kapısı',
      description: 'Ana kampüs giriş kapısı',
      latitude: 38.785920,
      longitude: 35.411434,
      category: 'Kapı',
    ),
    const PointOfInterest(
      id: 'lojmanlar-giris',
      name: 'Lojmanlar Giriş',
      description: 'Lojman bölgesi giriş kapısı',
      latitude: 38.786920,
      longitude: 35.405372,
      category: 'Kapı',
    ),

    // Fakülteler
    const PointOfInterest(
      id: 'saglik-bilimleri-fakultesi',
      name: 'Sağlık Bilimleri Fakültesi',
      description: 'NNY Sağlık Bilimleri Fakültesi',
      latitude: 38.784986,
      longitude: 35.408400,
      category: 'Fakülte',
    ),
    const PointOfInterest(
      id: 'iibf',
      name: 'İktisadi ve İdari Bilimler Fakültesi',
      description: 'Nuh Naci Yazgan Üniversitesi İİBF',
      latitude: 38.784841,
      longitude: 35.407210,
      category: 'Fakülte',
    ),
    const PointOfInterest(
      id: 'muhendislik-fakultesi',
      name: 'Mühendislik Fakültesi',
      description: 'NNY Mühendislik Fakültesi',
      latitude: 38.786820,
      longitude: 35.406947,
      category: 'Fakülte',
    ),
    const PointOfInterest(
      id: 'guzel-sanatlar-fakultesi',
      name: 'Güzel Sanatlar ve Tasarım Fakültesi',
      description: 'NNY Güzel Sanatlar ve Tasarım Fakültesi',
      latitude: 38.786857,
      longitude: 35.407829,
      category: 'Fakülte',
    ),
    const PointOfInterest(
      id: 'dis-fakultesi',
      name: 'Diş Fakültesi',
      description: 'NNY Diş Hekimliği Fakültesi',
      latitude: 38.788004,
      longitude: 35.406966,
      category: 'Fakülte',
    ),

    // Sağlık Tesisleri
    const PointOfInterest(
      id: 'dis-hastanesi',
      name: 'Diş Hastanesi',
      description: 'NNY Diş Hastanesi',
      latitude: 38.788485,
      longitude: 35.406612,
      category: 'Sağlık',
    ),

    // Önemli Binalar ve Tesisler
    const PointOfInterest(
      id: 'saatli-kule',
      name: 'Saatli Kule',
      description: 'Kampüsün simge yapısı - Saatli Kule',
      latitude: 38.785585,
      longitude: 35.409541,
      category: 'Önemli Nokta',
    ),
    const PointOfInterest(
      id: 'toren-alani',
      name: 'Tören Alanı',
      description: 'Kampüs tören ve etkinlik alanı',
      latitude: 38.785907,
      longitude: 35.409788,
      category: 'Önemli Nokta',
    ),
    const PointOfInterest(
      id: 'suleyman-cetinsaya-kultur-merkezi',
      name: 'Süleyman Çetinsaya Kültür Merkezi',
      description: 'Kültür ve sanat etkinlikleri merkezi',
      latitude: 38.787253,
      longitude: 35.409233,
      category: 'Kültür',
    ),
    const PointOfInterest(
      id: 'ahmet-uzandac-kutuphanesi',
      name: 'Ahmet Uzandaç Kütüphanesi',
      description: 'Merkez kütüphane - Ahmet Uzandaç Kütüphanesi',
      latitude: 38.784961,
      longitude: 35.405728,
      category: 'Kütüphane',
    ),
    const PointOfInterest(
      id: 'baldoktu-spor-salonu',
      name: 'Baldöktü Spor Salonu',
      description: 'Kapalı spor salonu',
      latitude: 38.783945,
      longitude: 35.403850,
      category: 'Spor',
    ),

    // Öğrenci Yurtları
    const PointOfInterest(
      id: 'nuh-yapislar-erkek-yurdu',
      name: 'Nuh Yapışlar Yımaz Özdemir Erkek Öğrenci Yurdu',
      description: 'Erkek öğrenci yurdu',
      latitude: 38.784803,
      longitude: 35.404971,
      category: 'Yurt',
    ),
    const PointOfInterest(
      id: 'sahabiye-erkek-yurdu-b',
      name: 'Sahabiye Erkek Öğrenci Yurdu B Blok',
      description: 'Erkek öğrenci yurdu - B Blok',
      latitude: 38.785750,
      longitude: 35.404931,
      category: 'Yurt',
    ),

    // Otobüs Durakları
    const PointOfInterest(
      id: 'otobus-duragi-1',
      name: 'Otobüs Durağı 1 (Kampüs İçi)',
      description: 'Kampüs içi otobüs durağı',
      latitude: 38.786911,
      longitude: 35.405886,
      category: 'Ulaşım',
    ),
    const PointOfInterest(
      id: 'otobus-duragi-2',
      name: 'Otobüs Durağı 2 (Kampüs İçi)',
      description: 'Kampüs içi otobüs durağı',
      latitude: 38.784718,
      longitude: 35.406424,
      category: 'Ulaşım',
    ),
    const PointOfInterest(
      id: 'dis-hastanesi-otobus-duragi',
      name: 'Diş Hastanesi Otobüs Durağı',
      description: 'Diş hastanesi önü otobüs durağı',
      latitude: 38.788722,
      longitude: 35.406562,
      category: 'Ulaşım',
    ),
    const PointOfInterest(
      id: 'kampus-disi-otobus-duragi',
      name: 'Kampüs Dışı Otobüs Durağı',
      description: 'Kampüs dışı otobüs durağı',
      latitude: 38.785319,
      longitude: 35.411936,
      category: 'Ulaşım',
    ),

    // Otoparklar
    const PointOfInterest(
      id: 'guzel-sanatlar-otopark',
      name: 'Güzel Sanatlar Fakültesi Otoparkı',
      description: 'Güzel Sanatlar Fakültesi otopark alanı',
      latitude: 38.787006774092966,
      longitude: 35.407983689914914,
      category: 'Otopark',
    ),
    const PointOfInterest(
      id: 'muhendislik-otopark',
      name: 'Mühendislik Fakültesi Otoparkı',
      description: 'Mühendislik Fakültesi otopark alanı',
      latitude: 38.786956,
      longitude: 35.406957,
      category: 'Otopark',
    ),
    const PointOfInterest(
      id: 'otopark-3',
      name: 'Otopark 3',
      description: 'Otopark alanı 3',
      latitude: 38.785718,
      longitude: 35.405773,
      category: 'Otopark',
    ),
    const PointOfInterest(
      id: 'otopark-4',
      name: 'Otopark 4',
      description: 'Otopark alanı 4',
      latitude: 38.784661,
      longitude: 35.407137,
      category: 'Otopark',
    ),
    const PointOfInterest(
      id: 'otopark-5',
      name: 'Otopark 5',
      description: 'Otopark alanı 5',
      latitude: 38.784611,
      longitude: 35.405388,
      category: 'Otopark',
    ),
    const PointOfInterest(
      id: 'kultur-merkezi-otopark',
      name: 'Kültür Merkezi Otoparkı',
      description: 'Süleyman Çetinsaya Kültür Merkezi otoparkı',
      latitude: 38.787089,
      longitude: 35.409707,
      category: 'Otopark',
    ),
    const PointOfInterest(
      id: 'misafir-otopark',
      name: 'Misafir Otoparkı',
      description: 'Misafir araçlar için otopark',
      latitude: 38.786142,
      longitude: 35.411534,
      category: 'Otopark',
    ),

    // Diğer Tesisler
    const PointOfInterest(
      id: 'ceylan-kirtasiye',
      name: 'Ceylan Kırtasiye',
      description: 'Kampüs kırtasiye',
      latitude: 38.786172,
      longitude: 35.406315,
      category: 'Hizmet',
    ),

    // İsimsiz Binalar
    const PointOfInterest(
      id: 'isimsiz-bina-1',
      name: 'İsimsiz Bina 1',
      description: 'Kampüs binası',
      latitude: 38.786804,
      longitude: 35.405590,
      category: 'Bina',
    ),
    const PointOfInterest(
      id: 'isimsiz-bina-2',
      name: 'İsimsiz Bina 2',
      description: 'Kampüs binası',
      latitude: 38.786251,
      longitude: 35.405364,
      category: 'Bina',
    ),
    const PointOfInterest(
      id: 'isimsiz-bina-3',
      name: 'İsimsiz Bina 3',
      description: 'Kampüs binası',
      latitude: 38.785857,
      longitude: 35.405671,
      category: 'Bina',
    ),
    const PointOfInterest(
      id: 'isimsiz-bina-4',
      name: 'İsimsiz Bina 4',
      description: 'Kampüs binası',
      latitude: 38.785529,
      longitude: 35.405935,
      category: 'Bina',
    ),
    const PointOfInterest(
      id: 'isimsiz-bina-5',
      name: 'İsimsiz Bina 5',
      description: 'Kampüs binası',
      latitude: 38.784847,
      longitude: 35.407914,
      category: 'Bina',
    ),
    const PointOfInterest(
      id: 'isimsiz-bina-6',
      name: 'İsimsiz Bina 6',
      description: 'Kampüs binası',
      latitude: 38.784551,
      longitude: 35.408165,
      category: 'Bina',
    ),
  ];
}
