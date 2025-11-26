import 'dart:html' as html;
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

      // Helper function to execute the building entry logic
      void executeBuildingEntry() {
        if (_indoorService == null) {
          print('❌ Service still not available');
          return;
        }

        print('📍 IndoorService found: $_indoorService');

        if (buildingName.contains('Mühendislik')) {
          print('🏢 Mühendislik Fakültesi selected, calling enterBuilding...');

          // Force add class immediately using dart:html
          try {
            print('⚡ Forcing indoor-mode class via dart:html...');
            html.document.body?.classes.add('indoor-mode');

            // Direct style manipulation to ensure visibility
            final flutterTarget = html.document.getElementById(
              'flutter-target',
            );
            if (flutterTarget != null) {
              print(
                '🔍 flutter-target found. Children count: ${flutterTarget.children.length}',
              );

              // Use cssText for maximum priority
              flutterTarget.style.cssText = '''
                display: block !important;
                position: fixed !important;
                top: 0 !important;
                left: 0 !important;
                width: 100% !important;
                height: 100% !important;
                z-index: 2147483647 !important;
                background-color: white !important;
                visibility: visible !important;
                opacity: 1 !important;
              ''';
              print('✅ Forced flutter-target styles with !important');
            } else {
              print('❌ flutter-target element not found!');
            }

            // Aggressively hide other elements
            print('🙈 Hiding all other body children...');
            int hiddenCount = 0;
            if (html.document.body != null) {
              for (final element in html.document.body!.children) {
                if (element.id != 'flutter-target' &&
                    element.tagName != 'SCRIPT') {
                  element.style.display = 'none';
                  hiddenCount++;
                }
              }
            }
            print('✅ Hidden $hiddenCount elements directly');

            print('✅ Forced indoor-mode class addition (dart:html)');
          } catch (e) {
            print('❌ Failed to force add indoor-mode class: $e');
          }

          _indoorService!.enterBuilding(BuildingData.engineeringFaculty);

          // Scroll to top
          html.window.scrollTo(0, 0);
          print('⬆️ Scrolled to top');
        } else {
          print('⚠️ Unknown building: $buildingName');
        }
      }

      try {
        if (_indoorService == null) {
          print(
            '⚠️ IndoorNavigationService not ready yet! Retrying in 100ms...',
          );

          // Retry after a short delay to allow service registration
          Future.delayed(const Duration(milliseconds: 100), () {
            executeBuildingEntry();
          });
          return;
        }

        // Service is ready, execute immediately
        executeBuildingEntry();
      } catch (e, stack) {
        print('❌ Error in flutter_enterBuilding: $e');
        print('Stack: $stack');
      }
    });

    js.context['flutter_enterBuilding'] = enterBuildingCallback;
    print('✅ WebIntegrationService: flutter_enterBuilding exposed to JS');
  }

  static void registerService(IndoorNavigationService service) {
    print(
      '🔌 WebIntegrationService: Registering IndoorNavigationService instance...',
    );
    _indoorService = service;

    // Listen to changes to toggle overlay mode
    service.addListener(() {
      if (service.isIndoorMode) {
        print('🏢 Indoor mode active: Adding overlay class (listener)');
        html.document.body?.classes.add('indoor-mode');

        // Force visibility via listener as well (redundancy for robustness)
        final flutterTarget = html.document.getElementById('flutter-target');
        if (flutterTarget != null) {
          flutterTarget.style.cssText = '''
            display: block !important;
            position: fixed !important;
            top: 0 !important;
            left: 0 !important;
            width: 100% !important;
            height: 100% !important;
            z-index: 2147483647 !important;
            background-color: white !important;
            visibility: visible !important;
            opacity: 1 !important;
          ''';
        }

        if (html.document.body != null) {
          for (final element in html.document.body!.children) {
            if (element.id != 'flutter-target' && element.tagName != 'SCRIPT') {
              element.style.display = 'none';
            }
          }
        }
      } else {
        print('🌳 Outdoor mode active: Removing overlay class (listener)');
        html.document.body?.classes.remove('indoor-mode');

        // Restore visibility via listener
        final flutterTarget = html.document.getElementById('flutter-target');
        if (flutterTarget != null) {
          // Clear all inline styles and force visibility
          flutterTarget.style.cssText = '';
          flutterTarget.style.removeProperty('position');
          flutterTarget.style.removeProperty('top');
          flutterTarget.style.removeProperty('left');
          flutterTarget.style.removeProperty('width');
          flutterTarget.style.removeProperty('height');
          flutterTarget.style.removeProperty('z-index');
          flutterTarget.style.removeProperty('display');
          flutterTarget.style.display = 'block';
        }

        // Restore other elements
        if (html.document.body != null) {
          for (final element in html.document.body!.children) {
            if (element.id != 'flutter-target' && element.tagName != 'SCRIPT') {
              element.style.removeProperty('display');
              element.style.display = '';
            }
          }
        }

        print('✅ Outdoor mode restored: All elements visible');
      }
    });
  }
}
