import 'package:flutter/foundation.dart';
import '../models/building.dart';
import '../models/floor.dart';
import 'map_service.dart';

class IndoorNavigationService extends ChangeNotifier {
  final MapService? _mapService;

  IndoorNavigationService({MapService? mapService}) : _mapService = mapService;
  Building? _currentBuilding;
  Floor? _currentFloor;
  IndoorNode? _selectedNode;
  int _selectedNodeIndex = 0;
  List<IndoorNode> _availableNodes = [];

  Building? get currentBuilding => _currentBuilding;
  Floor? get currentFloor => _currentFloor;
  IndoorNode? get selectedNode => _selectedNode;
  int get selectedNodeIndex => _selectedNodeIndex;
  List<IndoorNode> get availableNodes => _availableNodes;

  bool get isIndoorMode => _currentBuilding != null;
  bool get hasPrevious => _selectedNodeIndex > 0;
  bool get hasNext => _selectedNodeIndex < _availableNodes.length - 1;

  // Enter building and show ground floor
  void enterBuilding(Building building) {
    debugPrint('🏢 enterBuilding çağrıldı: ${building.name}');

    try {
      // 1. Stop any active wayfinding/navigation
      if (_mapService != null) {
        debugPrint(
          '📍 MapService mevcut, navigasyon durumu: ${_mapService.isNavigating}',
        );
        if (_mapService.isNavigating) {
          _mapService.stopNavigation();
          debugPrint('🛑 Wayfinding sonlandırıldı');
        }
      } else {
        debugPrint('⚠️ MapService null!');
      }

      _currentBuilding = building;

      // Find ground floor (floorNumber = 0)
      try {
        _currentFloor = building.floors.firstWhere(
          (floor) => floor.floorNumber == 0,
        );
      } catch (e) {
        // If no ground floor, take first floor
        _currentFloor =
            building.floors.isNotEmpty ? building.floors.first : null;
        debugPrint('⚠️ Giriş katı bulunamadı, ilk kat seçildi: $_currentFloor');
      }

      // Get all accessible rooms (exclude corridors, stairs)
      if (_currentFloor != null) {
        _availableNodes = _currentFloor!.nodes
            .where(
              (node) =>
                  node.type != NodeType.corridor &&
                  node.type != NodeType.stairs &&
                  node.type != NodeType.elevator &&
                  node.roomNumber != null,
            )
            .toList();

        // Sort by room number
        _availableNodes.sort(
          (a, b) => (a.roomNumber ?? '').compareTo(b.roomNumber ?? ''),
        );

        // Select first node
        if (_availableNodes.isNotEmpty) {
          _selectedNodeIndex = 0;
          _selectedNode = _availableNodes[0];
        }
      } else {
        debugPrint('❌ Kat bulunamadı!');
      }

      debugPrint(
        '✅ enterBuilding tamamlandı. Bina: ${_currentBuilding?.name}, Kat: ${_currentFloor?.name}',
      );
    } catch (e, stack) {
      debugPrint('❌ enterBuilding hatası: $e');
      debugPrint('📍 Stack: $stack');
    } finally {
      notifyListeners();
    }
  }

  // Exit building and return to outdoor map
  void exitBuilding() {
    _currentBuilding = null;
    _currentFloor = null;
    _selectedNode = null;
    _selectedNodeIndex = 0;
    _availableNodes = [];
    notifyListeners();
  }

  // Navigate to next room
  void nextRoom() {
    if (hasNext) {
      _selectedNodeIndex++;
      _selectedNode = _availableNodes[_selectedNodeIndex];
      notifyListeners();
    }
  }

  // Navigate to previous room
  void previousRoom() {
    if (hasPrevious) {
      _selectedNodeIndex--;
      _selectedNode = _availableNodes[_selectedNodeIndex];
      notifyListeners();
    }
  }

  // Select specific room by index
  void selectRoomByIndex(int index) {
    if (index >= 0 && index < _availableNodes.length) {
      _selectedNodeIndex = index;
      _selectedNode = _availableNodes[index];
      notifyListeners();
    }
  }

  // Select specific room by ID
  void selectRoomById(String nodeId) {
    final index = _availableNodes.indexWhere((node) => node.id == nodeId);
    if (index != -1) {
      selectRoomByIndex(index);
    }
  }

  // Change floor
  void changeFloor(int floorNumber) {
    if (_currentBuilding == null) return;

    try {
      _currentFloor = _currentBuilding!.floors.firstWhere(
        (floor) => floor.floorNumber == floorNumber,
      );

      // Update available nodes for new floor
      _availableNodes = _currentFloor!.nodes
          .where(
            (node) =>
                node.type != NodeType.corridor &&
                node.type != NodeType.stairs &&
                node.type != NodeType.elevator &&
                node.roomNumber != null,
          )
          .toList();

      _availableNodes.sort(
        (a, b) => (a.roomNumber ?? '').compareTo(b.roomNumber ?? ''),
      );

      // Reset selection
      if (_availableNodes.isNotEmpty) {
        _selectedNodeIndex = 0;
        _selectedNode = _availableNodes[0];
      } else {
        _selectedNode = null;
        _selectedNodeIndex = 0;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Floor not found: $floorNumber');
    }
  }

  // Get room type icon
  String getRoomTypeIcon(NodeType type) {
    switch (type) {
      case NodeType.classroom:
        return '🎓';
      case NodeType.office:
        return '💼';
      case NodeType.lab:
        return '🔬';
      case NodeType.restroom:
        return '🚻';
      case NodeType.cafeteria:
        return '🍽️';
      case NodeType.entrance:
        return '🚪';
      case NodeType.exit:
        return '🚪';
      case NodeType.hall:
        return '🏛️';
      case NodeType.storage:
        return '📦';
      default:
        return '📍';
    }
  }

  // Get room type name in Turkish
  String getRoomTypeName(NodeType type) {
    switch (type) {
      case NodeType.classroom:
        return 'Sınıf';
      case NodeType.office:
        return 'Ofis';
      case NodeType.lab:
        return 'Laboratuvar';
      case NodeType.restroom:
        return 'Tuvalet';
      case NodeType.cafeteria:
        return 'Kafeterya';
      case NodeType.entrance:
        return 'Giriş';
      case NodeType.exit:
        return 'Çıkış';
      case NodeType.hall:
        return 'Hol';
      case NodeType.storage:
        return 'Depo';
      case NodeType.corridor:
        return 'Koridor';
      case NodeType.stairs:
        return 'Merdiven';
      case NodeType.elevator:
        return 'Asansör';
      default:
        return 'Diğer';
    }
  }
}
