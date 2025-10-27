import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Stub implementation for non-web platforms
class WebMapWidget extends StatelessWidget {
  const WebMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Text('Map not available on this platform'),
      ),
    );
  }
}