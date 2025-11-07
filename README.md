# NNY Kampüs Haritası 🎓

Nuh Naci Yazgan Üniversitesi öğrencileri ve ziyaretçileri için geliştirilmiş interaktif kampüs haritası ve navigasyon uygulaması. Flutter ile geliştirilmiş, kullanıcı dostu arayüzü ile kampüs içerisinde yön bulmayı kolaylaştırır.

## 📖 Proje Hakkında

Bu uygulama, Nuh Naci Yazgan Üniversitesi öğrencilerinin kampüs içerisinde kolayca yön bulabilmeleri ve kampüsteki önemli noktaları keşfedebilmeleri için tasarlanmıştır. Öğrenciler, fakülteler, kütüphane, yemekhaneler, yurtlar, otoparklar ve diğer önemli kampüs tesislerini harita üzerinde görebilir ve bu noktalara nasıl ulaşacaklarını öğrenebilirler.

## 🌟 Özellikler

- 🗺️ **Interaktif Kampüs Haritası**: Google Maps entegrasyonu ile detaylı kampüs haritası
- 📍 **23+ İlgi Noktası**: Fakülteler, yurtlar, kafeterya, kütüphane, spor salonu ve daha fazlası
- 🔍 **Akıllı Arama**: İlgi noktalarını isim ve kategori bazında hızlı arama
- 🧭 **Navigasyon**: Kampüs içerisinde yürüyerek yol tarifi
- 📱 **Modern Arayüz**: Kullanıcı dostu ve responsive tasarım
- 🌐 **GPS Entegrasyonu**: Mevcut konumunuzu gösterme ve mesafe hesaplama
- 🎨 **Kategori Bazlı Renkli İkonlar**: Her tesis türü için özel icon ve renk

## 📱 Platform Desteği

- ✅ **Web**: Chrome, Firefox, Safari, Edge
- ✅ **Android**: Android 5.0 ve üzeri
- ✅ **iOS**: iOS 11.0 ve üzeri

## 📋 Kampüs İçerikleri

### İlgi Noktaları ve Tesisler

#### 🏫 **Fakülteler (4)**
- Sağlık Bilimleri Fakültesi
- İktisadi ve İdari Bilimler Fakültesi
- Mühendislik Fakültesi
- Güzel Sanatlar ve Tasarım Fakültesi

#### 🏢 **Öğrenci Yurtları (2)**
- Nuh Yapışlar Yımaz Özdemir Erkek Öğrenci Yurdu
- Sahabiye Erkek Öğrenci Yurdu B Blok

#### 📚 **Önemli Binalar (4)**
- ⭐ Saatli Kule (Kampüs simgesi)
- 📖 Ahmet Uzandaç Kütüphanesi
- 🍽️ Yemek Hizmetleri
- 🏀 Baldöktü Spor Salonu

#### � **Otoparklar (3)**
- Otopark 1 (Ana otopark)
- Otopark 2
- Misafir Otoparkı

#### � **Ulaşım (2)**
- Otobüs Durağı 2
- Otobüs Durağı 3

#### � **Giriş Kapıları (2)**
- Ana Giriş Kapısı
- Lojmanlar Giriş

#### 🏪 **Diğer Hizmetler (1)**
- Ceylan Kırtasiye

### 🎨 Kategori İkonları

| Kategori | İkon | Renk |
|----------|------|------|
| Fakülte | 🏫 | Lacivert |
| Kütüphane | � | Kahverengi |
| Yemek | 🍽️ | Kırmızı |
| Spor | 🏀 | Yeşil |
| Yurt | 🏢 | Mor |
| Ulaşım | 🚌 | Turuncu |
| Otopark | 🅿️ | Gri |
| Hizmet | 🛍️ | Turkuaz |
| Önemli Nokta | ⭐ | Altın |
| Giriş Kapısı | 🚪 | Mavi |

## 🚀 Kurulum

### Gereksinimler
- Flutter 3.0.0 veya üzeri
- Dart 3.0.0 veya üzeri
- Google Maps API Key

### Google Cloud Ayarları
Google Cloud Console'dan aşağıdaki API'ları aktif edin:
1. **Maps JavaScript API** (Web için)
2. **Directions API** (Navigasyon için)
3. **Maps SDK for Android** (Android için)
4. **Maps SDK for iOS** (iOS için)

### Proje Kurulumu

```bash
# Projeyi klonlayın
git clone https://github.com/eisildak/nny_map.git
cd nny_map

# Bağımlılıkları yükleyin
flutter pub get

# JSON serializasyon dosyalarını oluşturun
flutter packages pub run build_runner build
```

### API Key Ayarları

⚠️ **Önemli**: Google Maps API Key'inizi güvenli bir şekilde saklayın ve GitHub'a yüklemeyin!

#### 1. API Key Dosyası Oluşturma
`lib/config/api_keys.dart` dosyasını oluşturun:
```dart
class ApiKeys {
  static const String googleMapsApiKey = 'YOUR_ACTUAL_API_KEY_HERE';
}
```

#### 2. Android
`android/app/src/main/AndroidManifest.xml` dosyasında:
```xml
<meta-data android:name="com.google.android.geo.API_KEY"
           android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
```

#### 3. iOS
`ios/Runner/AppDelegate.swift` dosyasında:
```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")
GeneratedPluginRegistrant.register(with: self)
return super.application(application, didFinishLaunchingWithOptions: launchOptions)
```

#### 4. Web
`web/index.html` dosyasında Google Maps JavaScript API script tag'ini güncelleyin.

## 🎯 Kullanım

### Web Uygulaması
```bash
flutter run -d chrome
```

### Android Uygulaması
```bash
flutter run -d android
```

### iOS Uygulaması
```bash
flutter run -d ios
```

### Ana Özellikler

1. **Harita Görünümü**: Uygulama açıldığında NNY Kampüsü merkez alınarak harita yüklenir
2. **Arama**: Üst menüdeki arama ikonu ile ilgi noktalarını arayabilirsiniz
3. **Navigasyon**: Bir noktaya tıkladığınızda "Yürüyerek Git" butonu ile navigasyon başlatılır
4. **Konum Takibi**: GPS ikonuna basarak mevcut konumunuza odaklanabilirsiniz
5. **Kategori Filtreleme**: Arama ekranında kategori bazlı filtreleme yapabilirsiniz
6. **Detaylı Bilgi**: Her POI için açıklama, kategori ve konum bilgileri gösterilir

### Önemli Notlar
- Navigasyon için konum izni gereklidir
- İnternet bağlantısı harita yükleme için gereklidir
- Tüm platformlarda (Web, Android, iOS) çalışır

## 🏗️ Proje Yapısı

```
lib/
├── main.dart                      # Uygulama giriş noktası
├── config/                        # Yapılandırma dosyaları
│   └── api_keys.dart             # Google Maps API Key
├── models/                        # Veri modelleri
│   ├── point_of_interest.dart    # POI modeli ve kampüs verileri
│   └── point_of_interest.g.dart  # JSON serializasyon
├── services/                      # İş mantığı servisleri
│   ├── location_service.dart     # GPS ve konum servisleri
│   └── map_service.dart          # Harita ve navigasyon servisleri
├── screens/                       # Ekran bileşenleri
│   ├── splash_screen.dart        # Açılış ekranı
│   ├── map_screen.dart           # Ana harita ekranı
│   ├── web_map_screen.dart       # Web için özelleştirilmiş ekran
│   └── simple_map_screen.dart    # Basit harita görünümü
└── widgets/                       # Yeniden kullanılabilir UI bileşenleri
    ├── search_widget.dart         # Arama widget'ı
    ├── poi_bottom_sheet.dart      # POI detay paneli
    ├── navigation_controls.dart   # Navigasyon kontrolleri
    ├── web_map_widget.dart        # Web harita widget'ı
    └── web_info_panel.dart        # Web bilgi paneli
```

## 🔧 Geliştirme

### Yeni İlgi Noktası Ekleme
`lib/models/point_of_interest.dart` dosyasındaki `POIData.kayseriMilletBahcesi` listesine yeni nokta ekleyin:

```dart
const PointOfInterest(
  id: 'yeni-bina',
  name: 'Yeni Bina Adı',
  description: 'Bina açıklaması',
  latitude: 38.78700,
  longitude: 35.40800,
  category: 'Fakülte', // veya başka bir kategori
),
```

### Yeni Kategori Ekleme
1. `lib/services/map_service.dart` dosyasında `_getMarkerIcon` metoduna yeni kategori ekleyin
2. Uygun icon ve renk seçin
3. `SearchWidget` ve `POIBottomSheet` widget'larında kategori filtrelerini güncelleyin

### Marker İkonlarını Özelleştirme
`lib/services/map_service.dart` dosyasında:
- `_createCustomMarker`: Icon ve renk özelleştirmesi
- `_getMarkerIcon`: Kategori bazlı icon seçimi

## � Kullanılan Teknolojiler

- **Flutter**: Cross-platform UI framework
- **Google Maps Flutter**: Harita görüntüleme
- **Provider**: State management
- **Geolocator**: Konum servisleri
- **HTTP**: API istekleri
- **JSON Annotation**: Veri serializasyonu

## 🎓 Lisans ve Kullanım

Bu proje Nuh Naci Yazgan Üniversitesi öğrencileri ve ziyaretçileri için geliştirilmiştir.

## 👨‍💻 Geliştirici

**Nuh Naci Yazgan Üniversitesi**  
Kayseri, Türkiye

## 📞 İletişim

Sorularınız veya önerileriniz için:
- 🌐 Web: [nny.edu.tr](https://nny.edu.tr)
- 📧 E-posta: info@nny.edu.tr

## 🚀 Gelecek Özellikler

- [ ] Etkinlik takvimi entegrasyonu
- [ ] Kampüs servisi takibi
- [ ] Offline harita desteği
- [ ] Çoklu dil desteği (Türkçe/İngilizce)
- [ ] QR kod ile POI bilgisi
- [ ] Kampüs içi bildirimler
- [ ] Öğrenci ders programı entegrasyonu
- [ ] Sınıf ve derslik bulucu

## 📝 Sürüm Geçmişi

### v1.0.0 (Kasım 2025)
- ✅ NNY Kampüsü için özelleştirilmiş harita
- ✅ 23+ ilgi noktası eklendi
- ✅ Web, Android ve iOS desteği
- ✅ Kategori bazlı renkli ikonlar
- ✅ Akıllı arama ve filtreleme
- ✅ GPS navigasyon desteği

---

**Made with ❤️ for NNY Students**