import '../models/indoor_building.dart';

/// BFS (Breadth-First Search) kullanarak iki nokta arasındaki en kısa yolu bulur
class PathFinding {
  /// Tüm katlar arası bağlantıları içeren rota bulma
  static List<String>? findPath({
    required String startId,
    required String endId,
    required List<FloorNode> allNodes,
    required List<Edge> allEdges,
    List<Edge>? interFloorConnections,
  }) {
    if (startId == endId) return [startId];

    // Adjacency list oluştur
    final Map<String, List<String>> adjacencyList = {};

    // Tüm node'ları ekle
    for (var node in allNodes) {
      adjacencyList[node.id] = [];
    }

    // Edge'leri ekle (iki yönlü)
    for (var edge in allEdges) {
      if (adjacencyList.containsKey(edge.from) &&
          adjacencyList.containsKey(edge.to)) {
        adjacencyList[edge.from]!.add(edge.to);
        adjacencyList[edge.to]!.add(edge.from);
      }
    }

    // Katlar arası bağlantıları ekle (merdivenler)
    if (interFloorConnections != null) {
      for (var connection in interFloorConnections) {
        if (!adjacencyList.containsKey(connection.from)) {
          adjacencyList[connection.from] = [];
        }
        if (!adjacencyList.containsKey(connection.to)) {
          adjacencyList[connection.to] = [];
        }
        adjacencyList[connection.from]!.add(connection.to);
        adjacencyList[connection.to]!.add(connection.from);
      }
    }

    // BFS
    final List<List<String>> queue = [
      [startId],
    ];
    final Set<String> visited = {startId};

    while (queue.isNotEmpty) {
      final path = queue.removeAt(0);
      final node = path.last;

      if (node == endId) {
        return path;
      }

      final neighbors = adjacencyList[node] ?? [];
      for (final neighbor in neighbors) {
        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          final newPath = [...path, neighbor];
          queue.add(newPath);
        }
      }
    }

    return null; // Yol bulunamadı
  }
}
