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
                fullscreenControl: true,
                streetViewControl: true,
                mapTypeControl: true,
                zoomControl: true,
                gestureHandling: 'greedy'
              });
              
              console.log('✅ Harita oluşturuldu!');
              
              // Merkez marker
              var marker = new google.maps.Marker({
                position: { lat: 38.787374, lng: 35.407380 },
                map: map,
                title: 'NNY Kampüs Merkezi',
                icon: {
                  path: google.maps.SymbolPath.CIRCLE,
                  scale: 12,
                  fillColor: '#3252a8',
                  fillOpacity: 1,
                  strokeColor: '#ffffff',
                  strokeWeight: 3
                }
              });
              
              var infoWindow = new google.maps.InfoWindow({
                content: '<div style="padding:10px;"><h3 style="margin:0 0 5px 0;color:#3252a8;">🏛️ NNY Kampüs</h3><p style="margin:0;">Nuh Naci Yazgan Üniversitesi</p></div>'
              });
              
              marker.addListener('click', function() {
                infoWindow.open(map, marker);
              });
              
              // Otomatik aç
              setTimeout(function() {
                infoWindow.open(map, marker);
              }, 500);
              
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
