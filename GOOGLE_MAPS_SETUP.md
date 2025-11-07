# Google Maps API Key Kurulumu

Bu projeyi çalıştırmak için Google Maps API Key'e ihtiyacınız var.

## Adımlar:

### 1. Google Cloud Console'dan API Key Alın
1. [Google Cloud Console](https://console.cloud.google.com/) adresine gidin
2. Yeni bir proje oluşturun veya mevcut projenizi seçin
3. "APIs & Services" > "Credentials" bölümüne gidin
4. "Create Credentials" > "API Key" seçeneğine tıklayın
5. API Key'inizi kopyalayın

### 2. Gerekli API'ları Aktif Edin
Aşağıdaki API'ları aktif edin:
- Maps JavaScript API (Web için)
- Directions API (Navigasyon için)
- Maps SDK for Android (Android için)
- Maps SDK for iOS (iOS için)
- Places API (Opsiyonel)

### 3. API Key'i Projeye Ekleyin

#### a) Dart/Flutter (lib/config/api_keys.dart)
```bash
# Example dosyasını kopyalayın
cp lib/config/api_keys.dart.example lib/config/api_keys.dart

# Dosyayı düzenleyin ve YOUR_GOOGLE_MAPS_API_KEY_HERE yerine kendi key'inizi yazın
```

#### b) Android (android/app/src/main/AndroidManifest.xml)
`YOUR_GOOGLE_MAPS_API_KEY` yazan yeri kendi API key'iniz ile değiştirin:
```xml
<meta-data android:name="com.google.android.geo.API_KEY"
           android:value="BURAYA_API_KEYINIZI_YAZIPIN"/>
```

#### c) Web (web/index.html)
`YOUR_GOOGLE_MAPS_API_KEY` yazan yeri kendi API key'iniz ile değiştirin:
```html
<script async defer src="https://maps.googleapis.com/maps/api/js?key=BURAYA_API_KEYINIZI_YAZIN&libraries=geometry,places&callback=initMap"></script>
```

#### d) iOS (ios/Runner/AppDelegate.swift)
AppDelegate.swift dosyasında API key'i ekleyin (gerekirse):
```swift
GMSServices.provideAPIKey("BURAYA_API_KEYINIZI_YAZIN")
```

## Güvenlik Notları

⚠️ **ÖNEMLİ:**
- API Key'inizi asla GitHub'a yüklemeyin!
- `.gitignore` dosyası zaten `lib/config/api_keys.dart` dosyasını ignore ediyor
- Production ortamında API Key kısıtlamaları ekleyin (HTTP referrer, IP adresi vb.)

## API Key Kısıtlamaları (Önerilen)

Google Cloud Console'da API Key'iniz için kısıtlamalar ekleyin:
- **Application restrictions:** HTTP referrers (web), Android apps, iOS apps
- **API restrictions:** Sadece kullandığınız API'ları seçin
