import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/point_of_interest.dart';
import '../models/building.dart';
import '../config/api_keys.dart';

class MapService extends ChangeNotifier {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<PointOfInterest> _pois = [];
  List<PointOfInterest> _filteredPois = [];
  bool _isNavigating = false;
  PointOfInterest? _selectedPoi;
  Marker? _userLocationMarker;
  List<Map<String, dynamic>>? _currentRouteSteps;

  // Google API Key - Directions API için
  static const String _apiKey = ApiKeys.googleMapsApiKey;

  // NNY Üniversite Kampüsü merkez koordinatları
  static const LatLng nuhNaciYazganUniversitesi = LatLng(38.787374, 35.407380);

  // Getters
  GoogleMapController? get controller => _controller;
  Set<Marker> get markers => _getAllMarkers();
  Set<Polyline> get polylines => _polylines;
  List<PointOfInterest> get pois => _pois;
  List<PointOfInterest> get filteredPois => _filteredPois;
  bool get isNavigating => _isNavigating;
  PointOfInterest? get selectedPoi => _selectedPoi;
  List<Map<String, dynamic>>? get currentRouteSteps => _currentRouteSteps;

  // Tüm marker'ları (POI + kullanıcı konumu) döndür
  Set<Marker> _getAllMarkers() {
    Set<Marker> allMarkers = Set.from(_markers);
    if (_userLocationMarker != null) {
      allMarkers.add(_userLocationMarker!);
    }
    return allMarkers;
  }

  void setController(GoogleMapController controller) {
    _controller = controller;
    notifyListeners();
  }

  Future<void> initializePOIs() async {
    _pois = POIData.nuhNaciYazganUniversitesi;
    _filteredPois = List.from(_pois);
    // Cache'i temizle ki yeni boyuttaki marker'lar oluşturulsun
    _markerCache.clear();
    await _createMarkers();
    notifyListeners();
  }

  Future<void> _createMarkers() async {
    _markers.clear();

    for (PointOfInterest poi in _pois) {
      final icon = await _getMarkerIcon(poi.category);
      _markers.add(
        Marker(
          markerId: MarkerId(poi.id),
          position: LatLng(poi.latitude, poi.longitude),
          infoWindow: InfoWindow(
            title: poi.name,
            snippet: poi.description,
            onTap: () => selectPOI(poi),
          ),
          icon: icon,
          onTap: () => selectPOI(poi),
        ),
      );
    }
  }

  // Custom marker cache
  final Map<String, BitmapDescriptor> _markerCache = {};

  Future<BitmapDescriptor> _getMarkerIcon(String category) async {
    // Cache'den kontrol et
    if (_markerCache.containsKey(category)) {
      return _markerCache[category]!;
    }

    BitmapDescriptor icon;

    switch (category.toLowerCase()) {
      case 'kapı':
        icon = await _createCustomMarker(Icons.login, const Color(0xFF3252a8));
        break;
      case 'fakülte':
        icon = await _createCustomMarker(Icons.school, const Color(0xFF1e3a5f));
        break;
      case 'kütüphane':
        icon = await _createCustomMarker(
          Icons.local_library,
          const Color(0xFF8B4513),
        );
        break;
      case 'yemek':
        icon = await _createCustomMarker(
          Icons.restaurant,
          const Color(0xFFFF6347),
        );
        break;
      case 'spor':
        icon = await _createCustomMarker(
          Icons.sports_basketball,
          const Color(0xFF228B22),
        );
        break;
      case 'yurt':
        icon = await _createCustomMarker(
          Icons.apartment,
          const Color(0xFF4B0082),
        );
        break;
      case 'ulaşım':
        icon = await _createCustomMarker(
          Icons.directions_bus,
          const Color(0xFFFF8C00),
        );
        break;
      case 'otopark':
        icon = await _createCustomMarker(
          Icons.local_parking,
          const Color(0xFF808080),
        );
        break;
      case 'hizmet':
        icon = await _createCustomMarker(
          Icons.shopping_bag,
          const Color(0xFF20B2AA),
        );
        break;
      case 'önemli nokta':
        icon = await _createCustomMarker(Icons.star, const Color(0xFFFFD700));
        break;
      case 'bina':
        icon = await _createCustomMarker(
          Icons.business,
          const Color(0xFF696969),
        );
        break;
      case 'wc':
        icon = await _createCustomMarker(Icons.wc, const Color(0xFF3252a8));
        break;
      case 'üniversite':
        icon = await _createUniversityMarker();
        break;
      default:
        icon = await _createCustomMarker(
          Icons.location_on,
          const Color(0xFF3252a8),
        );
        break;
    }

    // Cache'e kaydet
    _markerCache[category] = icon;
    return icon;
  }

  Future<BitmapDescriptor> _createCustomMarker(
    IconData iconData,
    Color color,
  ) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const size = Size(30, 30);

    // Beyaz daire arka plan
    final backgroundPaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 1.2,
      backgroundPaint,
    );

    // Mavi çerçeve
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 1.2,
      borderPaint,
    );

    // Icon çiz
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: 12,
        fontFamily: iconData.fontFamily,
        color: color,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(uint8List);
  }

  Future<BitmapDescriptor> _createUniversityMarker() async {
    try {
      // NNY logosunu asset'ten yükle
      return await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/icons/nny_university_logo.png',
      );
    } catch (e) {
      // Logo yüklenemezse alternatif logoyu dene
      try {
        return await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(48, 48)),
          'assets/icons/nny_logo.png',
        );
      } catch (e2) {
        // Her ikisi de yüklenemezse custom marker oluştur
        return await _createCustomUniversityMarker();
      }
    }
  }

  Future<BitmapDescriptor> _createCustomUniversityMarker() async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const size = Size(48, 48);

    // Beyaz daire arka plan
    final backgroundPaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 2,
      backgroundPaint,
    );

    // NNY Logo çerçevesi (mavi gradient)
    final gradientPaint = Paint()
      ..shader =
          const LinearGradient(
            colors: [Color(0xFF1e3a5f), Color(0xFF3252a8)],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width / 2, size.height / 2),
              radius: size.width / 2 - 2,
            ),
          );

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 2,
      gradientPaint,
    );

    // NNY yazısı - büyütülmüş
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = const TextSpan(
      text: 'NNY',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(uint8List);
  }

  void selectPOI(PointOfInterest poi) {
    _selectedPoi = poi;

    // Haritayı seçili POI'ye odakla
    _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(poi.latitude, poi.longitude), 18.0),
    );

    notifyListeners();
  }

  Future<void> startNavigation(
    PointOfInterest destination,
    LatLng userLocation,
  ) async {
    _isNavigating = true;
    _selectedPoi = destination;

    print(
      'Navigasyon başlatılıyor: ${userLocation.latitude}, ${userLocation.longitude} -> ${destination.latitude}, ${destination.longitude}',
    );

    // Kullanıcı konum marker'ını oluştur
    await _createUserLocationMarker(userLocation);

    // Haritayı kullanıcı konumuna odakla
    await _focusOnUserLocation(userLocation);

    try {
      await _getDirections(
        userLocation,
        LatLng(destination.latitude, destination.longitude),
      );
    } catch (e) {
      debugPrint('Navigasyon hatası: $e');

      // Hata durumunda basit düz çizgi çiz
      _createStraightLine(
        userLocation,
        LatLng(destination.latitude, destination.longitude),
      );
    }

    notifyListeners();
  }

  Future<void> _getDirections(LatLng origin, LatLng destination) async {
    print('🗺️ Google Directions API çağrısı başlatılıyor...');
    print('📍 Başlangıç: ${origin.latitude}, ${origin.longitude}');
    print('🎯 Hedef: ${destination.latitude}, ${destination.longitude}');

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?'
      'origin=${origin.latitude},${origin.longitude}&'
      'destination=${destination.latitude},${destination.longitude}&'
      'mode=walking&'
      'language=tr&'
      'region=tr&'
      'units=metric&'
      'key=$_apiKey',
    );

    print('🌐 API URL: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('📡 HTTP Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ API Response Status: ${data['status']}');

        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];

          // Route bilgilerini log'la
          if (route['legs'] != null && route['legs'].isNotEmpty) {
            final leg = route['legs'][0];
            print('🚶 Mesafe: ${leg['distance']['text']}');
            print('⏱️ Süre: ${leg['duration']['text']}');
            print('📝 Adımlar: ${leg['steps']?.length ?? 0} adım');
          }

          final polylinePoints = route['overview_polyline']['points'];
          print(
            '🛤️ Polyline bulundu (${polylinePoints.length} karakter), yol çiziliyor...',
          );

          _createPolyline(polylinePoints);

          // Store route steps for later display
          if (route['legs'] != null && route['legs'].isNotEmpty) {
            _currentRouteSteps = List<Map<String, dynamic>>.from(
              route['legs'][0]['steps'] ?? [],
            );
          }

          // Route başarılı olduğunu bildir
          _showRouteSuccess(route);
        } else {
          print('❌ API Hatası: ${data['status']}');
          if (data['error_message'] != null) {
            print('📄 Hata Detayı: ${data['error_message']}');
          }

          // Hata mesajını kullanıcıya göster
          if (data['status'] == 'ZERO_RESULTS') {
            print('🚫 Bu nokta arasında yürüme rotası bulunamadı');
          }

          // API hatası durumunda düz çizgi çiz
          _createStraightLine(origin, destination);
        }
      } else {
        print('🔴 HTTP Hatası: ${response.statusCode}');
        print('📄 Response Body: ${response.body}');
        _createStraightLine(origin, destination);
      }
    } catch (e) {
      print('💥 Directions API Network Hatası: $e');
      _createStraightLine(origin, destination);
    }
  }

  void _showRouteSuccess(Map<String, dynamic> route) {
    try {
      if (route['legs'] != null && route['legs'].isNotEmpty) {
        final leg = route['legs'][0];
        final distance = leg['distance']?['text'] ?? 'Bilinmeyen mesafe';
        final duration = leg['duration']?['text'] ?? 'Bilinmeyen süre';

        print('✅ Rota başarıyla oluşturuldu: $distance, $duration');
      }
    } catch (e) {
      print('Route bilgileri parse edilemedi: $e');
    }
  }

  void _createStraightLine(LatLng origin, LatLng destination) {
    print(
      '⚠️ Google Maps rotası alınamadı, düz çizgi çiziliyor: $origin -> $destination',
    );

    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('fallback_route'),
        points: [origin, destination],
        color: Colors.orange, // Turuncu renk (fallback olduğunu göster)
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)], // Kesikli çizgi
        geodesic: true,
      ),
    );

    print('🟠 Fallback düz rota çizildi (turuncu kesikli çizgi)');
    notifyListeners();
  }

  void _createPolyline(String encodedPolyline) {
    List<LatLng> polylineCoordinates = _decodePolyline(encodedPolyline);
    print(
      '🛤️ Polyline decode edildi: ${polylineCoordinates.length} koordinat noktası',
    );

    if (polylineCoordinates.isEmpty) {
      print('⚠️ Polyline boş, düz çizgi çiziliyor');
      return;
    }

    // İlk ve son noktaları log'la
    if (polylineCoordinates.isNotEmpty) {
      print(
        '🚩 İlk nokta: ${polylineCoordinates.first.latitude}, ${polylineCoordinates.first.longitude}',
      );
      print(
        '🏁 Son nokta: ${polylineCoordinates.last.latitude}, ${polylineCoordinates.last.longitude}',
      );
    }

    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('walking_route'),
        points: polylineCoordinates,
        color: const Color(0xFF3252a8), // Mavi tema rengi
        width: 6, // Daha kalın çizgi
        patterns: [], // Düz çizgi (kesikli değil)
        geodesic: true, // Dünya eğriliğini dikkate al
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    );

    print('✅ Google Maps yürüme rotası çizildi!');
    notifyListeners();
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polylineCoordinates;
  }

  void searchPOIs(String query) {
    if (query.isEmpty) {
      _filteredPois = List.from(_pois);
    } else {
      _filteredPois = _pois
          .where(
            (poi) =>
                poi.name.toLowerCase().contains(query.toLowerCase()) ||
                poi.category.toLowerCase().contains(query.toLowerCase()) ||
                poi.description.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }

  void stopNavigation() {
    _isNavigating = false;
    _polylines.clear();
    _selectedPoi = null;
    _userLocationMarker = null; // Kullanıcı marker'ını temizle
    notifyListeners();
  }

  // Kullanıcı konum marker'ı oluştur
  Future<void> _createUserLocationMarker(LatLng userLocation) async {
    print(
      'Kullanıcı konum marker\'ı oluşturuluyor: ${userLocation.latitude}, ${userLocation.longitude}',
    );

    final icon = await _createUserLocationIcon();

    _userLocationMarker = Marker(
      markerId: const MarkerId('user_location'),
      position: userLocation,
      icon: icon,
      infoWindow: const InfoWindow(
        title: 'Konumunuz',
        snippet: 'Mevcut konumunuz',
      ),
      zIndex: 1000, // En üstte görünsün
    );
  }

  // Kullanıcı konum icon'u oluştur
  Future<BitmapDescriptor> _createUserLocationIcon() async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    // Dış çember (beyaz border)
    final outerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // İç çember (mavi)
    final innerPaint = Paint()
      ..color = const Color(0xFF3252a8)
      ..style = PaintingStyle.fill;

    // Pulse efekti için büyük çember (şeffaf)
    final pulsePaint = Paint()
      ..color = const Color(0xFF3252a8).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    const double size = 40.0;
    const double center = size / 2;

    // Pulse çember
    canvas.drawCircle(const Offset(center, center), 18, pulsePaint);

    // Dış çember (beyaz border)
    canvas.drawCircle(const Offset(center, center), 12, outerPaint);

    // İç çember (mavi)
    canvas.drawCircle(const Offset(center, center), 8, innerPaint);

    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  // Kullanıcı konumunu güncelle (takip sırasında)
  void updateUserLocation(LatLng newLocation) {
    if (!_isNavigating) return;

    print(
      'Kullanıcı konumu güncelleniyor: ${newLocation.latitude}, ${newLocation.longitude}',
    );

    _createUserLocationMarker(newLocation).then((_) {
      notifyListeners();

      // Kamerayı kullanıcı konumunda tut
      _controller?.animateCamera(CameraUpdate.newLatLng(newLocation));
    });
  }

  void centerOnNny() {
    _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(nuhNaciYazganUniversitesi, 17.0),
    );
  }

  // Haritayı kullanıcı konumuna odakla
  Future<void> _focusOnUserLocation(LatLng userLocation) async {
    if (_controller != null) {
      print(
        '🎯 Harita kullanıcı konumuna odaklanıyor: ${userLocation.latitude}, ${userLocation.longitude}',
      );

      await _controller!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: userLocation,
            zoom: 17.0, // Kullanıcı konumu için yüksek zoom
            tilt: 45.0, // Hafif açılı görünüm
            bearing: 0.0, // Kuzey yönü
          ),
        ),
      );

      // Animasyon tamamlandıktan sonra kısa bir bekleme
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  // Kullanıcı konumuna odaklanmak için public fonksiyon
  Future<void> focusOnUserLocation(LatLng userLocation) async {
    await _focusOnUserLocation(userLocation);
  }

  // Check if user is near a building (within 50 meters)
  Building? getNearbyBuilding(LatLng userLocation) {
    const double proximityThreshold = 50.0; // meters

    for (var building in BuildingData.getAllBuildings()) {
      final distance = _calculateDistanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        building.latitude,
        building.longitude,
      );

      if (distance <= proximityThreshold && building.hasIndoorMap) {
        return building;
      }
    }

    return null;
  }

  // Calculate distance between two coordinates in meters (Haversine formula)
  double _calculateDistanceBetween(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // meters
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}
