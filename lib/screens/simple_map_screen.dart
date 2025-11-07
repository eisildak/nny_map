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
  void initState() {
    super.initState();
    print('===== SimpleMapScreen initState başladı =====');
  }

  @override
  Widget build(BuildContext context) {
    print('===== SimpleMapScreen build çağrıldı =====');
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
          target: LatLng(38.787374, 35.407380), // Nuh Naci Yazgan Üniversitesi
          zoom: 16.0,
        ),
        markers: {
          const Marker(
            markerId: MarkerId('nny_kampus'),
            position: LatLng(38.787374, 35.407380),
            infoWindow: InfoWindow(
              title: 'NNY Kampüsü',
              snippet: 'Nuh Naci Yazgan Üniversitesi',
            ),
          ),
        },
      ),
    );
  }
}
