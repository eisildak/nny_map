import 'package:flutter_test/flutter_test.dart';
import 'package:nny_map/services/indoor_navigation_service.dart';
import 'package:nny_map/services/map_service.dart';
import 'package:nny_map/models/building.dart';

class MockMapService extends MapService {
  bool stopNavigationCalled = false;

  @override
  bool get isNavigating => true;

  @override
  void stopNavigation() {
    stopNavigationCalled = true;
  }
}

void main() {
  test('enterBuilding should set currentBuilding and notify listeners', () {
    final mapService = MockMapService();
    final indoorService = IndoorNavigationService(mapService: mapService);

    bool notified = false;
    indoorService.addListener(() {
      notified = true;
    });

    indoorService.enterBuilding(BuildingData.engineeringFaculty);

    expect(indoorService.currentBuilding, isNotNull);
    expect(indoorService.currentBuilding!.name, 'Mühendislik Fakültesi');
    expect(indoorService.currentFloor, isNotNull);
    expect(indoorService.isIndoorMode, true);
    expect(mapService.stopNavigationCalled, true);
    expect(notified, true);
  });
}
