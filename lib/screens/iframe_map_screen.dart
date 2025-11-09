import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// Conditional imports for web-specific APIs
import 'iframe_map_screen_stub.dart'
    if (dart.library.html) 'iframe_map_screen_web.dart';

class IframeMapScreen extends StatelessWidget {
  const IframeMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const IframeMapScreenImpl();
    } else {
      // For mobile platforms, show a message or alternative view
      return Scaffold(
        appBar: AppBar(
          title: const Text('Iframe Harita'),
          backgroundColor: const Color(0xFF3252a8),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'Iframe map is only available on web platform',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }
}
