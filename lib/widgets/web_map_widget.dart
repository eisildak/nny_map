import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Web-only imports with conditional compilation
import 'dart:html' as html show window, document, DivElement, ScriptElement;
import 'dart:ui_web' as ui;

class WebMapWidget extends StatefulWidget {
  const WebMapWidget({super.key});

  @override
  State<WebMapWidget> createState() => _WebMapWidgetState();
}

class _WebMapWidgetState extends State<WebMapWidget> {
  final String _mapViewType = 'web-google-map';

  @override
  void initState() {
    super.initState();
    print('🌐 WebMapWidget initState başladı');
    if (kIsWeb) {
      print('✅ kIsWeb = true, harita kaydı yapılıyor...');
      _registerWebMapView();
    } else {
      print('❌ kIsWeb = false!');
    }
  }

  void _registerWebMapView() {
    print('📝 _registerWebMapView çağrıldı');
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_mapViewType, (int viewId) {
      print('🏭 ViewFactory çağrıldı, viewId: $viewId');
      final mapElement = html.DivElement()
        ..id = 'google-map-$viewId'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none';

      print('📦 Map element oluşturuldu: google-map-$viewId');

      // Initialize map after a short delay to ensure Google Maps API is loaded
      Future.delayed(const Duration(milliseconds: 500), () {
        print('⏰ 500ms bekleme tamamlandı, harita initialize ediliyor...');
        _initializeGoogleMap('google-map-$viewId');
      });

      return mapElement;
    });
    print('✅ registerViewFactory tamamlandı');
  }

  void _initializeGoogleMap(String elementId) {
    print('🗺️ _initializeGoogleMap çağrıldı: $elementId');
    final script =
        '''
      function initGoogleMap_${elementId.replaceAll('-', '_')}() {
        console.log('🚀 JavaScript initGoogleMap fonksiyonu çalıştı: $elementId');
        const mapElement = document.getElementById('$elementId');
        
        if (!mapElement) {
          console.error('❌ Map element bulunamadı: $elementId');
          return;
        }
        
        console.log('✅ Map element bulundu:', mapElement);
        
        if (!window.google || !window.google.maps) {
          console.log('⏳ Google Maps API henüz hazır değil, 1 saniye sonra tekrar denenecek...');
          setTimeout(initGoogleMap_${elementId.replaceAll('-', '_')}, 1000);
          return;
        }
        
        console.log('✅ window.google.maps mevcut!');
        
        try {
          const map = new google.maps.Map(mapElement, {
            center: { lat: 38.787374, lng: 35.407380 }, // Nuh Naci Yazgan Üniversitesi
            zoom: 16,
            mapTypeId: 'hybrid',
            streetViewControl: true,
            fullscreenControl: true,
            mapTypeControl: true,
            zoomControl: true,
            gestureHandling: 'greedy',
            styles: [
              {
                featureType: 'poi',
                elementType: 'labels',
                stylers: [{ visibility: 'on' }]
              }
            ]
          });
          
          // NNY Kampüs merkez marker
          const centerMarker = new google.maps.Marker({
            position: { lat: 38.787374, lng: 35.407380 },
            map: map,
            title: 'Nuh Naci Yazgan Üniversitesi - Kampüs Merkezi',
            icon: {
              url: 'data:image/svg+xml;charset=UTF-8,' + encodeURIComponent(
                '<svg width="40" height="40" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z" fill="#2196F3" stroke="#1976D2" stroke-width="2"/><circle cx="12" cy="9" r="3" fill="white"/></svg>'
              ),
              scaledSize: new google.maps.Size(40, 40)
            }
          });
          
          const centerInfoWindow = new google.maps.InfoWindow({
            content: '<div style="text-align: center;"><h3>� Nuh Naci Yazgan Üniversitesi</h3><p>İnteraktif kampüs haritası ve navigasyon rehberi</p></div>',
            maxWidth: 300
          });
          
          centerMarker.addListener('click', () => {
            centerInfoWindow.open(map, centerMarker);
          });
          
          // NNY Kampüs ilgi noktaları
          const pois = [
            {
              position: { lat: 38.788505, lng: 35.407142 },
              title: '�️ Sağlık Bilimleri Fakültesi',
              info: 'Hemşirelik, Beslenme ve Diyetetik bölümleri'
            },
            {
              position: { lat: 38.787910, lng: 35.406831 },
              title: '🏛️ İİBF',
              info: 'İktisadi ve İdari Bilimler Fakültesi'
            },
            {
              position: { lat: 38.787001, lng: 35.407812 },
              title: '🏛️ Mühendislik Fakültesi',
              info: 'Bilgisayar, Elektrik-Elektronik, Endüstri Mühendisliği'
            },
            {
              position: { lat: 38.786412, lng: 35.408523 },
              title: '🏛️ Güzel Sanatlar Fakültesi',
              info: 'Grafik Tasarım, İç Mimarlık bölümleri'
            },
            {
              position: { lat: 38.787876, lng: 35.407891 },
              title: '� Ahmet Uzandaç Kütüphanesi',
              info: 'Merkez kütüphane - Geniş çalışma alanları'
            },
            {
              position: { lat: 38.787512, lng: 35.407234 },
              title: '⏰ Saatli Kule',
              info: 'Kampüs simge yapısı'
            },
            {
              position: { lat: 38.786823, lng: 35.407456 },
              title: '� Baldöktü Spor Salonu',
              info: 'Kapalı spor kompleksi'
            },
            {
              position: { lat: 38.788134, lng: 35.408912 },
              title: '🏠 Kız Öğrenci Yurdu',
              info: 'Kampüs içi konaklama'
            },
            {
              position: { lat: 38.786234, lng: 35.409123 },
              title: '🏠 Erkek Öğrenci Yurdu',
              info: 'Kampüs içi konaklama'
            },
            {
              position: { lat: 38.787654, lng: 35.406123 },
              title: '🅿️ Ana Otopark',
              info: 'Kampüs ana park alanı'
            },
            {
              position: { lat: 38.788901, lng: 35.408234 },
              title: '🚌 Kampüs İçi Durak',
              info: 'Servis araçları durağı'
            },
            {
              position: { lat: 38.785678, lng: 35.407890 },
              title: '🏪 Ceylan Kırtasiye',
              info: 'Kırtasiye ve fotokopi hizmetleri'
            }
          ];
          
          pois.forEach((poi, index) => {
            const marker = new google.maps.Marker({
              position: poi.position,
              map: map,
              title: poi.title,
              icon: {
                url: 'data:image/svg+xml;charset=UTF-8,' + encodeURIComponent(
                  '<svg width="32" height="32" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z" fill="#3252a8" stroke="#1a2d5e" stroke-width="1"/><circle cx="12" cy="9" r="2.5" fill="white"/></svg>'
                ),
                scaledSize: new google.maps.Size(32, 32)
              }
            });
            
            const infoWindow = new google.maps.InfoWindow({
              content: '<div><h4>' + poi.title + '</h4><p>' + poi.info + '</p></div>',
              maxWidth: 250
            });
            
            marker.addListener('click', () => {
              infoWindow.open(map, marker);
            });
          });
          
          console.log('✅ Google Maps başarıyla yüklendi: $elementId');
          
        } catch (error) {
          console.error('❌ Google Maps hatası:', error);
        }
      }
      
      // Haritayı başlat
      initGoogleMap_${elementId.replaceAll('-', '_')}();
    ''';

    final scriptElement = html.ScriptElement()..text = script;
    html.document.head!.append(scriptElement);
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const Center(
        child: Text('Bu widget sadece web platformunda çalışır.'),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: HtmlElementView(viewType: _mapViewType),
    );
  }
}
