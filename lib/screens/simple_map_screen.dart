import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SimpleMapScreen extends StatefulWidget {
  const SimpleMapScreen({super.key});

  @override
  State<SimpleMapScreen> createState() => _SimpleMapScreenState();
}

class _SimpleMapScreenState extends State<SimpleMapScreen> {
  late GoogleMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Harita'),
        backgroundColor: const Color(0xFF3252a8),
        foregroundColor: Colors.white,
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          print('Google Maps Web başarıyla yüklendi!');
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(38.704200, 35.509500), // Kayseri Millet Bahçesi
          zoom: 16.0,
        ),
        markers: {
          const Marker(
            markerId: MarkerId('kayseri_millet_bahcesi'),
            position: LatLng(38.704200, 35.509500),
            infoWindow: InfoWindow(
              title: 'Kayseri Millet Bahçesi',
              snippet: 'Test marker',
            ),
          ),
        },
      ),
    );
  }
}