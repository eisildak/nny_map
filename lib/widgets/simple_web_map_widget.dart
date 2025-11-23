import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;

class SimpleWebMapWidget extends StatefulWidget {
  const SimpleWebMapWidget({super.key});

  @override
  State<SimpleWebMapWidget> createState() => _SimpleWebMapWidgetState();
}

class _SimpleWebMapWidgetState extends State<SimpleWebMapWidget> {
  final String _viewType =
      'simple-web-map-${DateTime.now().millisecondsSinceEpoch}';
  bool _registered = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _registerView();
      // JS Interop is handled globally by WebIntegrationService
      print('🔌 SimpleWebMapWidget: JS Interop handled by WebIntegrationService');
    }
  }

  void _registerView() {
    if (_registered) return;

    print('🌐 SimpleWebMapWidget: Registering view factory...');

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      print('📦 View factory çağrıldı, viewId: $viewId');

      // Div element oluştur
      final div = html.DivElement()
        ..id = 'map-container-$viewId'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none'
        ..style.margin = '0'
        ..style.padding = '0';

      // Harita JavaScript'ini ekle
      final script =
          '''
        (function() {
          console.log('🚀 Harita scripti çalışıyor...');
          
          function initializeMap() {
            console.log('🗺️ initializeMap fonksiyonu çağrıldı');
            
            var mapDiv = document.getElementById('map-container-$viewId');
            if (!mapDiv) {
              console.error('❌ Map div bulunamadı!');
              setTimeout(initializeMap, 100);
              return;
            }
            console.log('✅ Map div bulundu');
            
            if (!window.google || !window.google.maps) {
              console.log('⏳ Google Maps API bekleniyor...');
              setTimeout(initializeMap, 200);
              return;
            }
            console.log('✅ Google Maps API hazır');
            
            try {
              var map = new google.maps.Map(mapDiv, {
                center: { lat: 38.787374, lng: 35.407380 },
                zoom: 16,
                mapTypeId: 'hybrid',
                disableDefaultUI: true,  // Tüm varsayılan kontrolleri kapat
                fullscreenControl: true,   // Sadece ihtiyaç duyduğumuz kontrolleri aç
                streetViewControl: true,
                mapTypeControl: true,
                zoomControl: true,
                gestureHandling: 'greedy',
                zoomControlOptions: {
                  position: google.maps.ControlPosition.RIGHT_CENTER
                }
              });
              
              console.log('✅ Harita oluşturuldu!');
              
              // Sol alt köşe için kontrol panel'i oluştur
              var controlDiv = document.createElement('div');
              controlDiv.style.position = 'absolute';
              controlDiv.style.bottom = '20px';
              controlDiv.style.left = '10px';
              controlDiv.style.display = 'flex';
              controlDiv.style.flexDirection = 'column';
              controlDiv.style.gap = '10px';
              controlDiv.style.zIndex = '1000';
              
              // Konum butonu
              var locationButton = document.createElement('button');
              locationButton.style.backgroundColor = '#3252a8';
              locationButton.style.border = 'none';
              locationButton.style.borderRadius = '50%';
              locationButton.style.boxShadow = '0 2px 6px rgba(0,0,0,0.3)';
              locationButton.style.cursor = 'pointer';
              locationButton.style.width = '56px';
              locationButton.style.height = '56px';
              locationButton.style.padding = '0';
              locationButton.style.outline = 'none';
              locationButton.innerHTML = '<div style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;"><svg width="24" height="24" viewBox="0 0 24 24" fill="white"><path d="M12 8c-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4-1.79-4-4-4zm8.94 3c-.46-4.17-3.77-7.48-7.94-7.94V1h-2v2.06C6.83 3.52 3.52 6.83 3.06 11H1v2h2.06c.46 4.17 3.77 7.48 7.94 7.94V23h2v-2.06c4.17-.46 7.48-3.77 7.94-7.94H23v-2h-2.06zM12 19c-3.87 0-7-3.13-7-7s3.13-7 7-7 7 3.13 7 7-3.13 7-7 7z"/></svg></div>';
              locationButton.title = 'Konumumu Göster';
              
              // Hover efekti
              locationButton.onmouseover = function() {
                this.style.backgroundColor = '#4a6bc8';
                this.style.transform = 'scale(1.05)';
              };
              locationButton.onmouseout = function() {
                this.style.backgroundColor = '#3252a8';
                this.style.transform = 'scale(1)';
              };
              
              // Konum butonu tıklama
              locationButton.onclick = function() {
                console.log('📍 Konum butonu tıklandı');
                if (navigator.geolocation) {
                  navigator.geolocation.getCurrentPosition(function(position) {
                    var pos = {
                      lat: position.coords.latitude,
                      lng: position.coords.longitude
                    };
                    map.setCenter(pos);
                    map.setZoom(18);
                    
                    // Mevcut konumu göster
                    new google.maps.Marker({
                      position: pos,
                      map: map,
                      icon: {
                        path: google.maps.SymbolPath.CIRCLE,
                        scale: 8,
                        fillColor: '#4285F4',
                        fillOpacity: 1,
                        strokeColor: '#ffffff',
                        strokeWeight: 2
                      },
                      title: 'Mevcut Konumum'
                    });
                  }, function() {
                    console.error('Konum alınamadı');
                    alert('Konum bilgisi alınamadı. Lütfen konum izinlerini kontrol edin.');
                  });
                } else {
                  alert('Tarayıcınız konum servislerini desteklemiyor.');
                }
              };
              
              // Yön butonu
              var directionButton = document.createElement('button');
              directionButton.style.backgroundColor = '#3252a8';
              directionButton.style.border = 'none';
              directionButton.style.borderRadius = '50%';
              directionButton.style.boxShadow = '0 2px 6px rgba(0,0,0,0.3)';
              directionButton.style.cursor = 'pointer';
              directionButton.style.width = '56px';
              directionButton.style.height = '56px';
              directionButton.style.padding = '0';
              directionButton.style.outline = 'none';
              directionButton.innerHTML = '<div style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;"><svg width="24" height="24" viewBox="0 0 24 24" fill="white"><path d="M12 2L4.5 20.29l.71.71L12 18l6.79 3 .71-.71z"/></svg></div>';
              directionButton.title = 'Navigasyon';
              
              // Hover efekti
              directionButton.onmouseover = function() {
                this.style.backgroundColor = '#4a6bc8';
                this.style.transform = 'scale(1.05)';
              };
              directionButton.onmouseout = function() {
                this.style.backgroundColor = '#3252a8';
                this.style.transform = 'scale(1)';
              };
              
              // Yön butonu tıklama
              directionButton.onclick = function() {
                console.log('🧭 Navigasyon butonu tıklandı');
                // Navigasyon fonksiyonalitesi buraya eklenebilir
                alert('Navigasyon özelliği yakında eklenecek!');
              };
              
              // Butonları kontrol paneline ekle
              controlDiv.appendChild(locationButton);
              controlDiv.appendChild(directionButton);
              
              // Kontrol panelini haritaya ekle
              mapDiv.appendChild(controlDiv);
              
              console.log('✅ Tüm harita elemanları yüklendi!');
              
            } catch (error) {
              console.error('❌ Harita hatası:', error);
            }
          }
          
          // Hemen başlat
          setTimeout(initializeMap, 500);
        })();
      ''';

      final scriptElement = html.ScriptElement()..text = script;
      div.append(scriptElement);

      print('✅ View factory element döndürüldü');
      return div;
    });

    _registered = true;
    print('✅ View factory kaydedildi: $_viewType');
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const Center(
        child: Text('Bu widget sadece web platformunda çalışır'),
      );
    }

    print('🎨 SimpleWebMapWidget build çağrıldı');

    return Container(
      color: Colors.grey[200],
      child: HtmlElementView(
        viewType: _viewType,
        onPlatformViewCreated: (int id) {
          print('✅ Platform view oluşturuldu, id: $id');
        },
      ),
    );
  }
}
