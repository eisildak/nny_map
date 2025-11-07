import 'package:flutter/material.dart';

// Stub implementation for non-web platforms
class SimpleWebMapWidget extends StatelessWidget {
  const SimpleWebMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: const Center(child: Text('Map not available on this platform')),
    );
  }
}
