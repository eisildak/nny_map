import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import '../config/api_keys.dart';

class IframeMapScreen extends StatefulWidget {
  const IframeMapScreen({super.key});

  @override
  State<IframeMapScreen> createState() => _IframeMapScreenState();
}

class _IframeMapScreenState extends State<IframeMapScreen> {
  final String viewType = 'iframe-google-map';

  @override
  void initState() {
    super.initState();

    // Register the iframe view
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..style.border = 'none'
        ..style.height = '100%'
        ..style.width = '100%'
        ..src =
            'https://www.google.com/maps/embed/v1/view?key=${ApiKeys.googleMapsApiKey}&center=38.787374,35.407380&zoom=16&maptype=satellite';

      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iframe Harita Testi'),
        backgroundColor: const Color(0xFF3252a8),
        foregroundColor: Colors.white,
      ),
      body: HtmlElementView(viewType: viewType),
    );
  }
}
