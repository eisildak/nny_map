import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/map_screen.dart';
import 'screens/simple_map_screen.dart';
import 'screens/iframe_map_screen.dart';
import 'services/location_service.dart';
import 'services/map_service.dart';

void main() {
  runApp(const NNYCampusMapApp());
}

class NNYCampusMapApp extends StatelessWidget {
  const NNYCampusMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => MapService()),
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
        initialRoute: '/map',
        routes: {
          '/': (context) => const SplashScreen(),
          '/map': (context) => const MapScreen(),
          '/simple': (context) => const SimpleMapScreen(),
          '/iframe': (context) => const IframeMapScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
