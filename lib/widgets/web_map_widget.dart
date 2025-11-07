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
    if (kIsWeb) {
      _registerWebMapView();
    }
  }

  void _registerWebMapView() {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_mapViewType, (int viewId) {
      final mapElement = html.DivElement()
        ..id = 'google-map-$viewId'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none';

      // Initialize map after a short delay to ensure Google Maps API is loaded
      Future.delayed(const Duration(milliseconds: 500), () {
        _initializeGoogleMap('google-map-$viewId');
      });

      return mapElement;
    });
  }

  void _initializeGoogleMap(String elementId) {
    final script =
        '''
      function initGoogleMap_${elementId.replaceAll('-', '_')}() {
        const mapElement = document.getElementById('$elementId');
        
        if (!mapElement) {
          console.error('Map element not found: $elementId');
          return;
        }
        
        if (!window.google || !window.google.maps) {
          console.log('Google Maps API not ready, retrying in 1 second...');
          setTimeout(initGoogleMap_${elementId.replaceAll('-', '_')}, 1000);
          return;
        }
        
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
          
          // İlgi noktaları ekle
          const pois = [
            {
              position: { lat: 38.7315, lng: 35.4790 },
              title: '🍰 Kafeterya',
              info: 'Sıcak ve soğuk içecekler, atıştırmalıklar'
            },
            {
              position: { lat: 38.7308, lng: 35.4783 },
              title: '🚻 WC',
              info: 'Temiz ve modern tuvalet imkanları'
            },
            {
              position: { lat: 38.7318, lng: 35.4785 },
              title: '🎮 Oyun Alanı',
              info: 'Çocuklar için güvenli oyun alanı'
            },
            {
              position: { lat: 38.7305, lng: 35.4792 },
              title: '🅿️ Otopark',
              info: 'Ücretsiz araç park yeri'
            },
            {
              position: { lat: 38.7320, lng: 35.4780 },
              title: '🏃‍♂️ Yürüyüş Parkuru',
              info: 'Sağlık ve spor aktiviteleri için parkur'
            }
          ];
          
          pois.forEach((poi, index) => {
            const marker = new google.maps.Marker({
              position: poi.position,
              map: map,
              title: poi.title,
              icon: {
                url: 'data:image/svg+xml;charset=UTF-8,' + encodeURIComponent(
                  '<svg width="32" height="32" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z" fill="#FF5722" stroke="#D84315" stroke-width="1"/><circle cx="12" cy="9" r="2.5" fill="white"/></svg>'
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
