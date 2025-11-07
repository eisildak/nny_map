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
      name: 'Giriş Kapısı',
      description: 'Ana kampüs giriş kapısı',
      latitude: 38.78589474434629,
      longitude: 35.411693980735855,
      category: 'Kapı',
    ),
    const PointOfInterest(
      id: 'lojmanlar-giris',
      name: 'Lojmanlar Giriş',
      description: 'Lojman bölgesi giriş kapısı',
      latitude: 38.78693116419184,
      longitude: 35.405381190327866,
      category: 'Kapı',
    ),

    // Fakülteler
    const PointOfInterest(
      id: 'saglik-bilimleri-fakultesi',
      name: 'Sağlık Bilimleri Fakültesi',
      description: 'NNY Sağlık Bilimleri Fakültesi',
      latitude: 38.78514462717952,
      longitude: 35.40831865228636,
      category: 'Fakülte',
    ),
    const PointOfInterest(
      id: 'iibf',
      name: 'İktisadi ve İdari Bilimler Fakültesi',
      description: 'Nuh Naci Yazgan Üniversitesi İİBF',
      latitude: 38.7849469661776,
      longitude: 35.406897525490486,
      category: 'Fakülte',
    ),
    const PointOfInterest(
      id: 'muhendislik-fakultesi',
      name: 'Mühendislik Fakültesi',
      description: 'NNY Mühendislik Fakültesi',
      latitude: 38.78680568375408,
      longitude: 35.406943515614515,
      category: 'Fakülte',
    ),
    const PointOfInterest(
      id: 'guzel-sanatlar-fakultesi',
      name: 'Güzel Sanatlar ve Tasarım Fakültesi',
      description: 'NNY Güzel Sanatlar ve Tasarım Fakültesi',
      latitude: 38.7868410756953,
      longitude: 35.40786398732062,
      category: 'Fakülte',
    ),

    // Önemli Binalar ve Tesisler
    const PointOfInterest(
      id: 'saatli-kule',
      name: 'Saatli Kule',
      description: 'Kampüsün simge yapısı - Saatli Kule',
      latitude: 38.785613798353054,
      longitude: 35.409603239415674,
      category: 'Önemli Nokta',
    ),
    const PointOfInterest(
      id: 'ahmet-uzandac-kutuphanesi',
      name: 'Ahmet Uzandaç Kütüphanesi',
      description: 'Merkez kütüphane - Ahmet Uzandaç Kütüphanesi',
      latitude: 38.78494738158587,
      longitude: 35.40566410004457,
      category: 'Kütüphane',
    ),
    const PointOfInterest(
      id: 'yemek-hizmetleri',
      name: 'Yemek Hizmetleri',
      description: 'Kampüs yemekhane ve kafeterya',
      latitude: 38.785533170918555,
      longitude: 35.40589714978629,
      category: 'Yemek',
    ),
    const PointOfInterest(
      id: 'baldoktu-spor-salonu',
      name: 'Baldöktü Spor Salonu',
      description: 'Kapalı spor salonu',
      latitude: 38.784094334663344,
      longitude: 35.40373827398105,
      category: 'Spor',
    ),

    // Öğrenci Yurtları
    const PointOfInterest(
      id: 'nuh-yapislar-erkek-yurdu',
      name: 'Nuh Yapışlar Yımaz Özdemir Erkek Öğrenci Yurdu',
      description: 'Erkek öğrenci yurdu',
      latitude: 38.7848052078093,
      longitude: 35.4050042766544,
      category: 'Yurt',
    ),
    const PointOfInterest(
      id: 'sahabiye-erkek-yurdu-b',
      name: 'Sahabiye Erkek Öğrenci Yurdu B Blok',
      description: 'Erkek öğrenci yurdu - B Blok',
      latitude: 38.78573909109221,
      longitude: 35.40489412457194,
      category: 'Yurt',
    ),

    // Otobüs Durakları
    const PointOfInterest(
      id: 'otobus-duragi-2',
      name: 'Otobüs Durağı 2',
      description: 'Kampüs içi otobüs durağı',
      latitude: 38.78690220718738,
      longitude: 35.40586825605637,
      category: 'Ulaşım',
    ),
    const PointOfInterest(
      id: 'otobus-duragi-3',
      name: 'Otobüs Durağı 3',
      description: 'Kampüs içi otobüs durağı',
      latitude: 38.78472157604153,
      longitude: 35.406490220390495,
      category: 'Ulaşım',
    ),

    // Otoparklar
    const PointOfInterest(
      id: 'otopark-1',
      name: 'Otopark 1',
      description: 'Ana otopark alanı',
      latitude: 38.787006774092966,
      longitude: 35.407983689914914,
      category: 'Otopark',
    ),
    const PointOfInterest(
      id: 'otopark-2',
      name: 'Otopark 2',
      description: 'İkinci otopark alanı',
      latitude: 38.786979425840265,
      longitude: 35.40698685624173,
      category: 'Otopark',
    ),
    const PointOfInterest(
      id: 'misafir-otopark',
      name: 'Misafir Otoparkı',
      description: 'Misafir araçlar için otopark',
      latitude: 38.786244409412845,
      longitude: 35.41149464180089,
      category: 'Otopark',
    ),

    // Diğer Tesisler
    const PointOfInterest(
      id: 'ceylan-kirtasiye',
      name: 'Ceylan Kırtasiye',
      description: 'Kampüs kırtasiye',
      latitude: 38.78613645100621,
      longitude: 35.40638627939463,
      category: 'Hizmet',
    ),

    // İsimsiz Binalar (gelecekte isimlendirilecek)
    const PointOfInterest(
      id: 'bina-1',
      name: 'İsimsiz Bina 1',
      description: 'Kampüs binası - isimsiz',
      latitude: 38.78457522021548,
      longitude: 35.40816928318641,
      category: 'Bina',
    ),
    const PointOfInterest(
      id: 'bina-2',
      name: 'İsimsiz Bina 2',
      description: 'Kampüs binası - isimsiz',
      latitude: 38.78465885215492,
      longitude: 35.40591622768145,
      category: 'Bina',
    ),
    const PointOfInterest(
      id: 'bina-4',
      name: 'İsimsiz Bina 4',
      description: 'Kampüs binası - isimsiz',
      latitude: 38.785890313347316,
      longitude: 35.40570934053776,
      category: 'Bina',
    ),
    const PointOfInterest(
      id: 'bina-5',
      name: 'İsimsiz Bina 5',
      description: 'Kampüs binası - isimsiz',
      latitude: 38.7862329753523,
      longitude: 35.40532959437312,
      category: 'Bina',
    ),
    const PointOfInterest(
      id: 'bina-6',
      name: 'İsimsiz Bina 6',
      description: 'Kampüs binası - isimsiz',
      latitude: 38.786810509928955,
      longitude: 35.40551740362482,
      category: 'Bina',
    ),
  ];
}
