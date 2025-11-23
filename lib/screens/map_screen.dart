import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../services/map_service.dart';
import '../services/location_service.dart';
import '../services/indoor_navigation_service.dart';
import '../models/building.dart';
import '../widgets/search_widget.dart';
import '../widgets/poi_bottom_sheet.dart';
import '../widgets/navigation_controls.dart';
import '../widgets/indoor_map_widget.dart';
import '../widgets/simple_web_map_widget_stub.dart';
import '../widgets/compact_navigation_panel.dart';
import '../services/web_integration_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _waitForGoogleMaps();
      
      // Force IndoorNavigationService creation for web JS interop
      if (kIsWeb) {
        print('📱 MapScreen: Forcing IndoorNavigationService creation...');
        final indoorService = Provider.of<IndoorNavigationService>(
          context,
          listen: false,
        );
        print('✅ MapScreen: IndoorNavigationService accessed: $indoorService');
      }
    });
  }

  void _waitForGoogleMaps() async {
    if (kIsWeb) {
      // Web'de Google Maps API'nin yüklenmesini bekle
      print('🔄 Waiting for Google Maps API...');
      int attempts = 0;
      while (attempts < 50) {
        // Max 5 saniye bekle
        await Future.delayed(Duration(milliseconds: 100));
        attempts++;
      }
      print('✅ Google Maps API loading completed!');
    }

    _initializeServices();
    _setupLocationListener();
  }

  void _setupLocationListener() {
    final locationService = Provider.of<LocationService>(
      context,
      listen: false,
    );
    final mapService = Provider.of<MapService>(context, listen: false);

    // LocationService'i dinle ve konum değişikliklerini MapService'e ilet
    locationService.addListener(() {
      if (locationService.isTracking &&
          locationService.currentPosition != null &&
          mapService.isNavigating) {
        final newLocation = LatLng(
          locationService.currentPosition!.latitude,
          locationService.currentPosition!.longitude,
        );

        // MapService'de kullanıcı konumunu güncelle
        mapService.updateUserLocation(newLocation);
      }
    });
  }

  Future<void> _initializeServices() async {
    final mapService = Provider.of<MapService>(context, listen: false);
    final locationService = Provider.of<LocationService>(
      context,
      listen: false,
    );

    // POI'ları initialize et
    await mapService.initializePOIs();

    // Konum servisini başlat ama bekleme - arkaplanda çalışsın
    _requestLocationWithDialog(locationService);
  }

  Future<void> _requestLocationWithDialog(
    LocationService locationService,
  ) async {
    try {
      await locationService.getCurrentLocation();

      if (locationService.currentPosition != null) {
        // Konum başarıyla alındı
        print('Konum başarıyla alındı: ${locationService.currentPosition}');
        return;
      }
    } catch (e) {
      print('Konum alma hatası: $e');
    }

    // Konum alınamadıysa kullanıcıya seçenek sun
    if (mounted && locationService.currentPosition == null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Konum İzni'),
            content: const Text(
              'Navigasyon ve yakındaki noktaları gösterebilmek için konum izni gerekli.\n\n'
              'İzin vermek istiyor musunuz?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // İzin verilmezse varsayılan konuma git
                  _mapController.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      MapService.nuhNaciYazganUniversitesi,
                      16.0,
                    ),
                  );
                },
                child: const Text('Hayır'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await locationService.getCurrentLocation();

                  if (locationService.currentPosition != null) {
                    // Konum alındı, haritayı güncelle
                    _mapController.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(
                          locationService.currentPosition!.latitude,
                          locationService.currentPosition!.longitude,
                        ),
                        17.0,
                      ),
                    );
                  } else {
                    // Hala konum alınamadı, kullanıcıya bilgi ver
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            locationService.error ??
                                'Konum alınamadı. Lütfen cihaz ayarlarından konum servisini açın.',
                          ),
                          duration: const Duration(seconds: 4),
                          action: SnackBarAction(
                            label: 'Ayarlar',
                            onPressed: () {
                              // Kullanıcıyı ayarlara yönlendir
                            },
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Evet'),
              ),
            ],
          );
        },
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    print('🗺️ Google Maps onMapCreated called!');
    print('🌐 Platform: ${kIsWeb ? 'WEB' : 'MOBILE'}');
    _mapController = controller;
    final mapService = Provider.of<MapService>(context, listen: false);
    mapService.setController(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IndoorNavigationService>(
      builder: (context, indoorService, child) {
        debugPrint(
          '🗺️ MapScreen build: isIndoorMode=${indoorService.isIndoorMode}',
        );
        // If in indoor mode, show indoor map
        if (indoorService.isIndoorMode) {
          return const IndoorMapWidget();
        }

        // Otherwise show outdoor map
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Nuh Naci Yazgan Üniversitesi'),
            actions: [
              IconButton(
                icon: Icon(_showSearch ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    _showSearch = !_showSearch;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: () {
                  final locationService = Provider.of<LocationService>(
                    context,
                    listen: false,
                  );
                  locationService.getCurrentLocation();
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              // Ana harita - Web ve mobile için farklı widget
              if (kIsWeb)
                // Web için özel harita widget'ı
                const SimpleWebMapWidget()
              else
                // Mobile için Flutter GoogleMap widget
                Consumer<MapService>(
                  builder: (context, mapService, child) {
                    return GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: const CameraPosition(
                        target: MapService.nuhNaciYazganUniversitesi,
                        zoom: 17.0,
                      ),
                      markers: mapService.markers,
                      polylines: mapService.polylines,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      buildingsEnabled: true,
                      trafficEnabled: false,
                      mapType: MapType.hybrid, // Satellite + roads view
                      onTap: (LatLng position) {
                        // Haritaya tıklandığında search'ü kapat
                        if (_showSearch) {
                          setState(() {
                            _showSearch = false;
                          });
                        }
                      },
                    );
                  },
                ),

              // Arama widget'ı
              if (_showSearch)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: SearchWidget(
                    onClose: () {
                      setState(() {
                        _showSearch = false;
                      });
                    },
                  ),
                ),


              // Navigasyon kontrolleri
              const Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: NavigationControls(),
              ),

              // Loading indicator
              Consumer<LocationService>(
                builder: (context, locationService, child) {
                  if (locationService.isLoading) {
                    return Container(
                      color: Colors.black26,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF3252a8),
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
                  

            // Floating Action Buttons - Position changes based on bottom sheet
            Positioned(
              right: 16,
              bottom: Provider.of<MapService>(context).selectedPoi != null
                  ? 350.0 // Move up when any bottom sheet is visible
                  : 16.0, // Normal position otherwise
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // NNY button
                  FloatingActionButton(
                    heroTag: "center_fab",
                    onPressed: () {
                      final mapService = Provider.of<MapService>(
                        context,
                        listen: false,
                      );
                      mapService.centerOnNny();
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.park, color: Colors.white),
                  ),
                  const SizedBox(height: 16),

                  // Location button
                  Consumer<LocationService>(
                    builder: (context, locationService, child) {
                      return FloatingActionButton(
                        heroTag: "location_fab",
                        onPressed: locationService.isLoading
                            ? null
                            : () async {
                                await locationService.getCurrentLocation();

                                if (locationService.currentPosition != null) {
                                  print(
                                    'Konuma gidiliyor: ${locationService.currentPosition!.latitude}, ${locationService.currentPosition!.longitude}',
                                  );
                                  _mapController.animateCamera(
                                    CameraUpdate.newLatLngZoom(
                                      LatLng(
                                        locationService.currentPosition!.latitude,
                                        locationService.currentPosition!.longitude,
                                      ),
                                      17.0,
                                    ),
                                  );

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          locationService.error != null
                                              ? 'Varsayılan konum gösteriliyor'
                                              : 'Mevcut konumunuz gösteriliyor',
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                } else {
                                  _mapController.animateCamera(
                                    CameraUpdate.newLatLngZoom(
                                      MapService.nuhNaciYazganUniversitesi,
                                      16.0,
                                    ),
                                  );

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Konum alınamadı, NNY gösteriliyor',
                                        ),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                              },
                        backgroundColor: locationService.currentPosition != null
                            ? const Color(0xFF3252a8)
                            : Colors.grey[400],
                        child: locationService.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.gps_fixed, color: Colors.white),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),

          // Bottom Sheet: POI Details OR Navigation Panel
          bottomSheet: Consumer<MapService>(
            builder: (context, mapService, child) {
              // 1. Navigation Panel (if navigating)
              if (mapService.isNavigating && mapService.selectedPoi != null) {
                final locationService = Provider.of<LocationService>(
                  context,
                  listen: false,
                );
                
                // Calculate values for compact panel
                final distance = locationService.currentPosition != null
                    ? locationService.calculateDistance(
                        locationService.currentPosition!.latitude,
                        locationService.currentPosition!.longitude,
                        mapService.selectedPoi!.latitude,
                        mapService.selectedPoi!.longitude,
                      )
                    : 0.0;
                
                // Estimate duration: ~80 meters per minute walking speed
                final durationMinutes = (distance / 80).ceil();
                final durationText = durationMinutes < 60
                    ? '$durationMinutes dk'
                    : '${(durationMinutes / 60).toStringAsFixed(1)} sa';
                
                final distanceText = distance >= 1000
                    ? '${(distance / 1000).toStringAsFixed(1)} km'
                    : '${distance.toInt()} m';
                
                // Calculate arrival time (24-hour format)
                final now = DateTime.now();
                final arrivalTime = now.add(Duration(minutes: durationMinutes));
                final hours = arrivalTime.hour.toString().padLeft(2, '0');
                final minutes = arrivalTime.minute.toString().padLeft(2, '0');
                final arrivalText = '$hours:$minutes';
                
                return CompactNavigationPanel(
                  destination: mapService.selectedPoi!.name,
                  duration: durationText,
                  distance: distanceText,
                  arrivalTime: arrivalText,
                  progress: 0.05,
                  onEnd: () {
                    mapService.stopNavigation();
                    locationService.stopLocationTracking();
                  },
                  onShowDirections: () {
                    // Show directions modal
                    _showDirectionsModal(context, mapService);
                  },
                  onCenterDestination: () {
                    // Center on destination
                    _centerOnDestination(mapService);
                  },
                );
              }

              // 2. POI Details (if selected but not navigating)
              if (!mapService.isNavigating && mapService.selectedPoi != null) {
                return POIBottomSheet(poi: mapService.selectedPoi!);
              }
              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  void _showDirectionsModal(BuildContext context, MapService mapService) {
    final steps = mapService.currentRouteSteps;
    if (steps == null || steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Talimatlar kullanılamıyor'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.navigation, color: Color(0xFF3252a8)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${mapService.selectedPoi?.name ?? "Hedef"}\'e ${steps.length} adımda ulaşın',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF202124),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Steps list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: steps.length,
                  itemBuilder: (context, index) {
                    final step = steps[index];
                    final instruction = step['html_instructions'] ?? '';
                    final distance = step['distance']?['text'] ?? '';
                    final duration = step['duration']?['text'] ?? '';

                    // Remove HTML tags from instruction
                    final cleanInstruction = instruction
                        .replaceAll(RegExp(r'<[^>]*>'), ' ')
                        .replaceAll('&nbsp;', ' ')
                        .trim();

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF3252a8),
                        foregroundColor: Colors.white,
                        child: Text('${index + 1}'),
                      ),
                      title: Text(
                        cleanInstruction,
                        style: const TextStyle(fontSize: 15),
                      ),
                      subtitle: distance.isNotEmpty
                          ? Text('$distance • $duration')
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _centerOnDestination(MapService mapService) {
    if (mapService.selectedPoi == null) return;

    final destination = LatLng(
      mapService.selectedPoi!.latitude,
      mapService.selectedPoi!.longitude,
    );

    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: destination,
          zoom: 18.0,
          tilt: 0,
        ),
      ),
    );
  }
}
