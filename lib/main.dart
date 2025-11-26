import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'screens/splash_screen.dart';
import 'screens/map_screen.dart';
import 'screens/simple_map_screen.dart';
import 'screens/iframe_map_screen.dart';
import 'services/location_service.dart';
import 'services/map_service.dart';
import 'services/indoor_navigation_service.dart';
import 'screens/indoor_navigation_screen.dart';
import 'services/web_integration_service.dart'
    if (dart.library.html) 'services/web_integration_service_web.dart';

void main() async {
  print('🚀 Dart main() started!');

  // Web için JS Interop'u hemen başlat (runZonedGuarded dışında)
  if (kIsWeb) {
    print('🌐 main.dart: Running on web, setting up JS interop immediately');
    try {
      WebIntegrationService.setup();
    } catch (e) {
      print('❌ Web setup error: $e');
    }
  }

  // Hata yakalama ekleyelim
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // iOS için sadece dikey yönelimi zorla
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      runApp(const NNYCampusMapApp());
    },
    (error, stack) {
      debugPrint('❌ HATA: $error');
      debugPrint('📍 STACK: $stack');
    },
  );
}

class NNYCampusMapApp extends StatefulWidget {
  // Changed to StatefulWidget
  const NNYCampusMapApp({super.key});

  @override
  State<NNYCampusMapApp> createState() => _NNYCampusMapAppState();
}

class _NNYCampusMapAppState extends State<NNYCampusMapApp> {
  // Added State class
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => MapService()),
        ChangeNotifierProxyProvider<MapService, IndoorNavigationService>(
          create: (context) {
            final service = IndoorNavigationService(
              mapService: Provider.of<MapService>(context, listen: false),
            );

            // Register for web JS interop
            if (kIsWeb) {
              print(
                '🌐 Registering IndoorNavigationService with WebIntegrationService...',
              );
              WebIntegrationService.registerService(service);
            }

            return service;
          },
          update: (context, mapService, previous) =>
              previous ?? IndoorNavigationService(mapService: mapService),
        ),
      ],
      child: MaterialApp(
        title: 'NNY Kampüs Haritası',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF3252a8), // Özel mavi renk
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF3252a8),
            foregroundColor: Colors.white,
            elevation: 2,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 4,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF3252a8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF3252a8), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/map': (context) => const MapScreen(),
          '/simple': (context) => const SimpleMapScreen(),
          '/iframe': (context) => const IframeMapScreen(),
          '/indoor': (context) => const IndoorNavigationScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
