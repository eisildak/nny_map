import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import 'indoor_navigation_service.dart';
import '../models/building.dart';

class WebIntegrationService {
  static IndoorNavigationService? _indoorService;
  
  // Initialize JS interop immediately
  static void setup() {
    if (!kIsWeb) return;
    
    print('🔌 WebIntegrationService: Initializing JS Interop...');
    
    // Define the function immediately, even if service is null
    final enterBuildingCallback = js.allowInterop((String buildingName) {
      print('💙 Flutter received enterBuilding call: $buildingName');
      
      try {
        if (_indoorService == null) {
          print('⚠️ IndoorNavigationService not ready yet! Waiting...');
          // Optional: You could implement a queue here if needed
          return;
        }

        print('📍 IndoorService found: $_indoorService');

        if (buildingName.contains('Mühendislik')) {
          print('🏢 Mühendislik Fakültesi selected, calling enterBuilding...');
          _indoorService!.enterBuilding(BuildingData.engineeringFaculty);
          
          // Scroll to top to show the Flutter app (Indoor Map)
          js.context.callMethod('scrollTo', [0, 0]);
          print('⬆️ Scrolled to top');
        } else {
          print('⚠️ Unknown building: $buildingName');
        }
      } catch (e, stack) {
        print('❌ Error in flutter_enterBuilding: $e');
        print('Stack: $stack');
      }
    });

    js.context['flutter_enterBuilding'] = enterBuildingCallback;
    print('✅ WebIntegrationService: flutter_enterBuilding exposed to JS');
  }
  
  static void registerService(IndoorNavigationService service) {
    print('🔌 WebIntegrationService: Registering IndoorNavigationService instance...');
    _indoorService = service;
  }
}
