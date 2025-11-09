import 'package:flutter/material.dart';

// Stub implementation for non-web platforms
class IframeMapScreenImpl extends StatelessWidget {
  const IframeMapScreenImpl({super.key});

  @override
  Widget build(BuildContext context) {
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
