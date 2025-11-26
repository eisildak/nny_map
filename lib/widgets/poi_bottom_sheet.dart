import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/point_of_interest.dart';
import '../services/map_service.dart';
import '../services/location_service.dart';
import '../services/indoor_navigation_service.dart';
import '../models/building.dart';

class POIBottomSheet extends StatelessWidget {
  final PointOfInterest poi;

  const POIBottomSheet({super.key, required this.poi});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      margin: const EdgeInsets.only(
        bottom: 80,
      ), // Lift up to avoid native buttons
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Çekme çubuğu
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // POI başlığı ve kategori
          Row(
            children: [
              CircleAvatar(
                backgroundColor: _getCategoryColor(poi.category),
                radius: 24,
                child: Icon(
                  _getCategoryIcon(poi.category),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poi.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      poi.category,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  final mapService = Provider.of<MapService>(
                    context,
                    listen: false,
                  );
                  mapService.stopNavigation();
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // POI açıklaması
          Text(poi.description, style: const TextStyle(fontSize: 16)),

          const SizedBox(height: 20),

          // Binaya gir butonu (Eğer POI bir bina ise)
          if (poi.hasIndoorMap)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton.icon(
                onPressed: () => _enterBuilding(context),
                icon: const Icon(Icons.meeting_room),
                label: const Text('Binaya Gir (İç Mekan Navigasyonu)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 2,
                ),
              ),
            ),

          // Aksiyon butonları
          Row(
            children: [
              // Navigasyonu başlat butonu
              Expanded(
                child: Consumer2<MapService, LocationService>(
                  builder: (context, mapService, locationService, child) {
                    return ElevatedButton.icon(
                      onPressed: () => _startNavigation(
                        context,
                        mapService,
                        locationService,
                      ),
                      icon: Icon(
                        locationService.currentPosition != null
                            ? Icons.directions_walk
                            : Icons.location_searching,
                      ),
                      label: Text(
                        locationService.currentPosition != null
                            ? 'Yürüyerek Git'
                            : 'Konum Al & Git',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              // Paylaş butonu
              ElevatedButton.icon(
                onPressed: () => _sharePOI(context),
                icon: const Icon(Icons.share),
                label: const Text('Paylaş'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.grey[700],
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Konum bilgisi
          Consumer<LocationService>(
            builder: (context, locationService, child) {
              if (locationService.currentPosition != null) {
                final distance = locationService.calculateDistance(
                  locationService.currentPosition!.latitude,
                  locationService.currentPosition!.longitude,
                  poi.latitude,
                  poi.longitude,
                );

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.blue[700],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Konumunuzdan ${distance.toInt()} metre uzaklıkta',
                        style: TextStyle(color: Colors.blue[700], fontSize: 14),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_off,
                      color: Colors.orange[700],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Mesafe bilgisi için konum iznini verin',
                      style: TextStyle(color: Colors.orange[700], fontSize: 14),
                    ),
                  ],
                ),
              );
            },
          ),

          // Alt boşluk (Safe area için)
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  void _startNavigation(
    BuildContext context,
    MapService mapService,
    LocationService locationService,
  ) async {
    print('Navigasyon başlatma talebi alındı...');

    // Eğer konum yoksa önce konum al
    if (locationService.currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konum alınıyor...'),
          duration: Duration(seconds: 2),
        ),
      );

      await locationService.getCurrentLocation();
    }

    // Konum var mı kontrol et
    if (locationService.currentPosition != null) {
      final userLocation = LatLng(
        locationService.currentPosition!.latitude,
        locationService.currentPosition!.longitude,
      );

      print(
        'Kullanıcı konumu: ${userLocation.latitude}, ${userLocation.longitude}',
      );
      print('Hedef: ${poi.latitude}, ${poi.longitude}');

      // Navigasyonu başlat
      await mapService.startNavigation(poi, userLocation);

      // Konum takibini başlat
      await locationService.startLocationTracking();
    } else {
      // Konum alınamadı, NNY Kampüs merkezinden başlat
      const defaultLocation = LatLng(
        38.787374,
        35.407380,
      ); // NNY Kampüs merkezi

      print(
        'Konum alınamadı, varsayılan konumdan başlatılıyor: ${defaultLocation.latitude}, ${defaultLocation.longitude}',
      );
      print('Hedef: ${poi.latitude}, ${poi.longitude}');

      await mapService.startNavigation(poi, defaultLocation);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${poi.name} noktasına rota çiziliyor (NNY Kampüs merkezinden)',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Durdur',
            onPressed: () => mapService.stopNavigation(),
          ),
        ),
      );
    }
  }

  void _enterBuilding(BuildContext context) {
    print('🏢 Binaya gir butonuna tıklandı!');
    try {
      // İç mekan navigasyon servisini al ve binayı ayarla
      final indoorService = Provider.of<IndoorNavigationService>(
        context,
        listen: false,
      );

      // POI'nin ilişkili olduğu binayı bul ve ayarla
      if (poi.buildingId != null) {
        final building = _getBuildingById(poi.buildingId!);
        if (building != null) {
          print('🏢 Binaya giriliyor: ${building.name}');
          indoorService.enterBuilding(building);

          // İç mekan navigasyon ekranına git
          Navigator.of(context).pushNamed('/indoor');
          print('✅ IndoorNavigationScreen pushNamed ile çağrıldı');
        } else {
          print('❌ HATA: Bina bulunamadı (buildingId: ${poi.buildingId})');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bina bilgisi bulunamadı')),
          );
        }
      } else {
        print('❌ HATA: POI için buildingId tanımlanmamış');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Bina bilgisi eksik')));
      }
    } catch (e) {
      print('❌ HATA: IndoorNavigationScreen açılamadı: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  Building? _getBuildingById(String buildingId) {
    // building.dart'tan binaları al ve bul
    final buildings = BuildingData.getAllBuildings();
    try {
      return buildings.firstWhere((b) => b.id == buildingId);
    } catch (e) {
      return null;
    }
  }

  void _sharePOI(BuildContext context) {
    // ignore: unused_local_variable
    final shareText =
        '''
� Nuh Naci Yazgan Üniversitesi - ${poi.name}

📍 Kategori: ${poi.category}
📝 ${poi.description}

🗺️ Konum: ${poi.latitude.toStringAsFixed(6)}, ${poi.longitude.toStringAsFixed(6)}

📱 NNY Kampüs Haritası ile paylaşıldı
''';

    // Gerçek uygulamada share_plus paketi kullanılabilir
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Paylaş fonksiyonu hazırlanıyor...'),
        action: SnackBarAction(
          label: 'Kopyala',
          onPressed: () {
            // Clipboard'a kopyalama burada yapılacak
          },
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    // Tüm kategoriler için mavi renk
    switch (category.toLowerCase()) {
      case 'wc':
        return const Color(0xFF3252a8);
      case 'kapı':
        return const Color(0xFF3252a8);
      case 'üniversite':
        return const Color(0xFF3252a8);
      default:
        return const Color(0xFF3252a8);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'wc':
        return Icons.wc;
      case 'kapı':
        return Icons.login;
      case 'üniversite':
        return Icons.school;
      default:
        return Icons.location_on;
    }
  }
}
