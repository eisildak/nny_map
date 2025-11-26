import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/indoor_navigation_service.dart';
import '../models/floor.dart';
import 'dart:html' as html;

class IndoorMapWidget extends StatefulWidget {
  const IndoorMapWidget({super.key});

  @override
  State<IndoorMapWidget> createState() => _IndoorMapWidgetState();
}

class _IndoorMapWidgetState extends State<IndoorMapWidget> {
  String _selectedFilter = 'all';
  IndoorNode? _routeStartNode;
  IndoorNode? _routeEndNode;
  bool _showRoutePreview = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<IndoorNavigationService>(
      builder: (context, indoorService, child) {
        debugPrint(
          '🏗️ IndoorMapWidget build: isIndoorMode=${indoorService.isIndoorMode}, currentFloor=${indoorService.currentFloor?.name}',
        );

        if (!indoorService.isIndoorMode) {
          return const SizedBox.shrink();
        }

        if (indoorService.currentFloor == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Hata'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => indoorService.exitBuilding(),
              ),
            ),
            body: const Center(
              child: Text(
                'Kat planı yüklenemedi.\nLütfen tekrar deneyin.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(indoorService.currentBuilding!.name),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                // Exit the building
                indoorService.exitBuilding();

                // Force page reload to return to outdoor map
                html.window.location.reload();
              },
            ),
          ),
          body: Stack(
            children: [
              // Main floor plan view
              Column(
                children: [
                  // Floor info bar with filters
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: const Color(0xFF3252a8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.map, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              indoorService.currentFloor!.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            // Search button
                            IconButton(
                              icon: const Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _showRoomSearchDialog(context, indoorService);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Filter Buttons
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip('all', 'Tümü'),
                              _buildFilterChip(
                                'classroom',
                                'Amfiler & Derslikler',
                              ),
                              _buildFilterChip('office', 'Ofisler'),
                              _buildFilterChip('cafeteria', 'Sosyal'),
                              _buildFilterChip('stairs', 'Dolaşım'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Floor plan display
                  Expanded(
                    child: Container(
                      color: Colors.grey[100],
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Center(
                          child: _buildFloorPlan(context, indoorService),
                        ),
                      ),
                    ),
                  ),

                  // Selected room info
                  if (indoorService.selectedNode != null)
                    _buildRoomInfoBar(context, indoorService),
                ],
              ),

              // Route preview overlay (bottom-left corner)
              if (_showRoutePreview &&
                  _routeStartNode != null &&
                  _routeEndNode != null)
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: _buildRoutePreview(context, indoorService),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showRoomSearchDialog(
    BuildContext context,
    IndoorNavigationService service,
  ) {
    showDialog(
      context: context,
      builder: (context) => _RoomSearchDialog(service: service),
    );
  }

  Widget _buildFilterChip(String filter, String label) {
    final isSelected = _selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: const Color(0xFF3252a8),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = filter;
          });
        },
        backgroundColor: Colors.white.withOpacity(0.9),
        selectedColor: Colors.white,
        checkmarkColor: const Color(0xFF3252a8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? const Color(0xFF3252a8)
                : Colors.white.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
      ),
    );
  }

  Widget _buildRoutePreview(
    BuildContext context,
    IndoorNavigationService service,
  ) {
    if (_routeStartNode == null || _routeEndNode == null) {
      return const SizedBox.shrink();
    }

    final startNode = _routeStartNode!;
    final endNode = _routeEndNode!;

    // Calculate distance
    final dx = endNode.x - startNode.x;
    final dy = endNode.y - startNode.y;
    final distance = ((dx * dx + dy * dy).abs() * 0.1).toStringAsFixed(0);

    // Calculate estimated time (assuming 1.4 m/s walking speed)
    final timeMinutes = (double.parse(distance) / 1.4 / 60).ceil();

    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route header with Finish button
          Row(
            children: [
              Expanded(
                child: Text(
                  endNode.roomNumber ?? endNode.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  // Close route and clear selection
                  setState(() {
                    _showRoutePreview = false;
                    _routeStartNode = null;
                    _routeEndNode = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10b981),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Finish',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Time display
          Text(
            TimeOfDay.now().format(context),
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),

          const SizedBox(height: 12),

          // Instructions button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showRouteInstructions(
                  context,
                  startNode,
                  endNode,
                  distance,
                  timeMinutes,
                );
              },
              icon: const Icon(Icons.list_alt, size: 18),
              label: const Text('Talimatlar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3252a8),
                side: const BorderSide(color: Color(0xFF3252a8)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // From/To info (compact)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10b981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      startNode.roomNumber ?? startNode.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3252a8),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      endNode.roomNumber ?? endNode.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRouteInstructions(
    BuildContext context,
    IndoorNode startNode,
    IndoorNode endNode,
    String distance,
    int timeMinutes,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text(
                    'Talimatlar',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Instructions list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Step 1
                  _buildInstructionStep(
                    icon: Icons.my_location,
                    color: const Color(0xFF10b981),
                    title: 'Başlangıç Noktası',
                    subtitle: startNode.roomNumber ?? startNode.name,
                  ),

                  // Step 2
                  _buildInstructionStep(
                    icon: Icons.directions_walk,
                    color: const Color(0xFF3252a8),
                    title: 'Mavi çizgiyi takip edin',
                    subtitle: '$distance metre, yaklaşık $timeMinutes dakika',
                  ),

                  // Step 3
                  _buildInstructionStep(
                    icon: Icons.place,
                    color: const Color(0xFF3252a8),
                    title: 'Varış Noktası',
                    subtitle: endNode.roomNumber ?? endNode.name,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: Colors.grey[300],
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorPlan(
    BuildContext context,
    IndoorNavigationService service,
  ) {
    final floor = service.currentFloor!;

    return GestureDetector(
      onTapUp: (details) {
        // Find which node was tapped
        final localPosition = details.localPosition;
        for (var node in floor.nodes) {
          if (node.roomNumber != null) {
            final rect = Rect.fromCenter(
              center: Offset(node.x, node.y),
              width: 80,
              height: 60,
            );
            if (rect.contains(localPosition)) {
              service.selectRoomById(node.id);
              break;
            }
          }
        }
      },
      child: CustomPaint(
        size: const Size(750, 600),
        painter: FloorPlanPainter(
          floor: floor,
          selectedNode: service.selectedNode,
          filterType: _selectedFilter,
          routeStart: _routeStartNode,
          routeEnd: _routeEndNode,
        ),
      ),
    );
  }

  Widget _buildRoomInfoBar(
    BuildContext context,
    IndoorNavigationService service,
  ) {
    final node = service.selectedNode!;
    final typeName = service.getRoomTypeName(node.type);

    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                node.roomNumber != null ? 'Oda ${node.roomNumber}' : node.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3252a8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3252a8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      typeName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF3252a8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (node.description != null) ...[
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        node.description!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Rota Oluştur Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showRouteSetupDialog(context, service, node);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3252a8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Rota Oluştur',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRouteSetupDialog(
    BuildContext context,
    IndoorNavigationService service,
    IndoorNode destination,
  ) {
    setState(() {
      _routeEndNode = destination;
      _routeStartNode = null;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RouteSetupDialog(
        service: service,
        destination: destination,
        onRouteSelected: (startNode) {
          setState(() {
            _routeStartNode = startNode;
            _showRoutePreview = true;
          });
          Navigator.pop(context);
        },
      ),
    );
  }
}

// Custom painter for floor plan
class FloorPlanPainter extends CustomPainter {
  final Floor floor;
  final IndoorNode? selectedNode;
  final String filterType;
  final IndoorNode? routeStart;
  final IndoorNode? routeEnd;

  FloorPlanPainter({
    required this.floor,
    this.selectedNode,
    this.filterType = 'all',
    this.routeStart,
    this.routeEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    final bgPaint = Paint()..color = const Color(0xFFF5F5F5);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw building outline (matching React SVG path)
    _drawBuildingOutline(canvas);

    // Draw rooms
    for (var node in floor.nodes) {
      if (node.roomNumber != null) {
        _drawRoom(canvas, node);
      }
    }

    // Draw route if both start and end are set
    if (routeStart != null && routeEnd != null) {
      _drawRoute(canvas, routeStart!, routeEnd!);
    }

    // Draw user icon at entrance
    final entranceNode = floor.nodes.firstWhere(
      (node) => node.type == NodeType.entrance,
      orElse: () => floor.nodes.first,
    );
    _drawUserIcon(canvas, Offset(entranceNode.x, entranceNode.y));
  }

  void _drawBuildingOutline(Canvas canvas) {
    // SVG Path from React: "M 10 10 L 170 10 L 170 140 L 580 140 L 580 10 L 740 10 L 740 460 L 580 460 L 580 300 L 465 300 L 465 500 L 415 500 L 415 530 L 335 530 L 335 300 L 170 300 L 170 460 L 10 460 Z"
    final path = Path()
      ..moveTo(10, 10)
      ..lineTo(170, 10)
      ..lineTo(170, 140)
      ..lineTo(580, 140)
      ..lineTo(580, 10)
      ..lineTo(740, 10)
      ..lineTo(740, 460)
      ..lineTo(580, 460)
      ..lineTo(580, 300)
      ..lineTo(465, 300)
      ..lineTo(465, 500)
      ..lineTo(415, 500)
      ..lineTo(415, 530)
      ..lineTo(335, 530)
      ..lineTo(335, 300)
      ..lineTo(170, 300)
      ..lineTo(170, 460)
      ..lineTo(10, 460)
      ..close();

    final buildingPaint = Paint()
      ..color =
          const Color(0xFFe2e8f0) // Light gray fill
      ..style = PaintingStyle.fill;

    final buildingStroke = Paint()
      ..color =
          const Color(0xFF64748b) // Dark gray stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, buildingPaint);
    canvas.drawPath(path, buildingStroke);
  }

  void _drawRoom(Canvas canvas, IndoorNode node) {
    final isSelected = selectedNode?.id == node.id;

    // Check if node matches filter
    bool matchesFilter =
        filterType == 'all' ||
        (filterType == 'classroom' && node.type == NodeType.classroom) ||
        (filterType == 'office' && node.type == NodeType.office) ||
        (filterType == 'cafeteria' && node.type == NodeType.cafeteria) ||
        (filterType == 'stairs' && node.type == NodeType.stairs);

    final opacity = matchesFilter ? 1.0 : 0.3;

    // Get room dimensions based on type (matching React component)
    Map<String, double> dimensions = _getRoomDimensions(node);
    double width = dimensions['width']!;
    double height = dimensions['height']!;

    // Convert center coordinates to top-left
    final x = node.x - width / 2;
    final y = node.y - height / 2;

    // Get room color based on type
    Color roomColor = _getRoomColor(node.type);

    if (isSelected) {
      roomColor = const Color(0xFF3252a8).withOpacity(0.5);
    }

    // Draw room rectangle
    final roomPaint = Paint()
      ..color = roomColor.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(x, y, width, height);
    canvas.drawRect(rect, roomPaint);

    // Draw room border
    final borderPaint = Paint()
      ..color = isSelected
          ? const Color(0xFF3252a8)
          : (node.type == NodeType.corridor
                ? Colors.black38
                : const Color(0xFF64748b))
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 3 : (node.type == NodeType.corridor ? 1 : 2);

    // Corridors use dashed border (simplified as solid for now)
    canvas.drawRect(rect, borderPaint);

    // Draw stairs pattern
    if (node.type == NodeType.stairs) {
      _drawStairsPattern(canvas, rect);
    }

    // Draw icon
    _drawRoomIcon(canvas, Offset(node.x, node.y - 20), node.type, opacity);

    // Draw room number
    final textPainter = TextPainter(
      text: TextSpan(
        text: node.roomNumber,
        style: TextStyle(
          color: isSelected ? const Color(0xFF3252a8) : Colors.black87,
          fontSize: isSelected ? 16 : 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        node.x - textPainter.width / 2,
        node.y - textPainter.height / 2 + 5,
      ),
    );
  }

  Map<String, double> _getRoomDimensions(IndoorNode node) {
    // Match React component dimensions
    String roomId = node.id.toLowerCase();

    if (roomId.contains('amfi')) {
      return {'width': 140.0, 'height': 120.0};
    } else if (roomId.contains('derslik')) {
      return {'width': 65.0, 'height': 80.0};
    } else if (roomId.contains('ofis') || roomId.contains('office')) {
      return {'width': 50.0, 'height': 50.0};
    } else if (roomId.contains('koridor') || node.type == NodeType.corridor) {
      // Corridors have variable sizes
      if (roomId.contains('ana')) {
        return {'width': 240.0, 'height': 40.0};
      }
      return {'width': 200.0, 'height': 30.0};
    } else if (roomId.contains('giris') || node.type == NodeType.entrance) {
      return {'width': 80.0, 'height': 30.0};
    } else if (roomId.contains('merdiven') || node.type == NodeType.stairs) {
      // Merdiven boyutları - sol ve sağ dar, orta geniş
      if (roomId.contains('orta')) {
        return {'width': 60.0, 'height': 100.0}; // Orta merdiven geniş
      }
      return {
        'width': 40.0,
        'height': 140.0,
      }; // Sol/Sağ merdivenler dar ve uzun
    } else if (roomId.contains('guvenlik')) {
      return {'width': 40.0, 'height': 40.0};
    } else if (node.type == NodeType.cafeteria) {
      return {'width': 90.0, 'height': 70.0};
    }

    // Default
    return {'width': 60.0, 'height': 60.0};
  }

  Color _getRoomColor(NodeType type) {
    switch (type) {
      case NodeType.classroom:
        return const Color(0xFFddd6fe); // Light purple for Amfi/Classrooms
      case NodeType.office:
        return const Color(0xFFfef3c7); // Light yellow for Offices
      case NodeType.cafeteria:
        return const Color(0xFFfce7f3); // Light pink for Social
      case NodeType.restroom:
        return const Color(0xFFede9fe); // Light purple for WC
      case NodeType.stairs:
        return const Color(0xFFf1f5f9); // Light gray for Stairs
      case NodeType.corridor:
        return Colors.white; // White for corridors
      case NodeType.entrance:
        return const Color(0xFFdcfce7); // Light green for entrance
      default:
        return const Color(0xFFe0f2fe); // Light blue default
    }
  }

  void _drawStairsPattern(Canvas canvas, Rect rect) {
    final stairPaint = Paint()
      ..color = const Color(0xFF94a3b8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw simple stair lines
    for (int i = 1; i < 5; i++) {
      double y = rect.top + (rect.height / 5) * i;
      canvas.drawLine(
        Offset(rect.left + 5, y),
        Offset(rect.right - 5, y),
        stairPaint,
      );
    }
  }

  void _drawRoomIcon(
    Canvas canvas,
    Offset position,
    NodeType type,
    double opacity,
  ) {
    // Get icon color based on room type
    Color iconColor;
    String iconEmoji;

    switch (type) {
      case NodeType.classroom:
        iconColor = const Color(0xFF6366f1);
        iconEmoji = '👥';
        break;
      case NodeType.office:
        iconColor = const Color(0xFFf59e0b);
        iconEmoji = '💼';
        break;
      case NodeType.cafeteria:
        iconColor = const Color(0xFFec4899);
        iconEmoji = '☕';
        break;
      case NodeType.restroom:
        iconColor = const Color(0xFF8b5cf6);
        iconEmoji = '🚻';
        break;
      case NodeType.stairs:
        iconColor = const Color(0xFF64748b);
        iconEmoji = '⬆️';
        break;
      case NodeType.entrance:
        iconColor = const Color(0xFF10b981);
        iconEmoji = '🚪';
        break;
      default:
        iconColor = const Color(0xFF10b981);
        iconEmoji = '🎓';
    }

    // Draw circular icon background
    final iconPaint = Paint()
      ..color = iconColor.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, 14, iconPaint);

    // Draw white border
    final iconBorderPaint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(position, 14, iconBorderPaint);

    // Draw emoji icon
    final iconTextPainter = TextPainter(
      text: TextSpan(
        text: iconEmoji,
        style: TextStyle(
          fontSize: 14,
          color: Colors.white.withOpacity(opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconTextPainter.layout();
    iconTextPainter.paint(
      canvas,
      Offset(
        position.dx - iconTextPainter.width / 2,
        position.dy - iconTextPainter.height / 2,
      ),
    );
  }

  void _drawUserIcon(Canvas canvas, Offset position) {
    // Draw circular background
    final circlePaint = Paint()
      ..color = const Color(0xFF3252A8)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Main circle
    canvas.drawCircle(position, 20, circlePaint);
    canvas.drawCircle(position, 20, borderPaint);

    // Draw simple person icon using TextPainter
    final iconPainter = TextPainter(
      text: const TextSpan(text: '👤', style: TextStyle(fontSize: 24)),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        position.dx - iconPainter.width / 2,
        position.dy - iconPainter.height / 2,
      ),
    );
  }

  void _drawRoute(Canvas canvas, IndoorNode start, IndoorNode end) {
    // Draw route line from start to end
    final routePaint = Paint()
      ..color = const Color(0xFF3252a8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Draw dashed line effect
    final path = Path();
    path.moveTo(start.x, start.y);
    path.lineTo(end.x, end.y);

    canvas.drawPath(path, routePaint);

    // Draw start marker (green)
    final startMarkerPaint = Paint()
      ..color = const Color(0xFF10b981)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(start.x, start.y), 12, startMarkerPaint);

    final startBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(Offset(start.x, start.y), 12, startBorderPaint);

    // Draw end marker (blue)
    final endMarkerPaint = Paint()
      ..color = const Color(0xFF3252a8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(end.x, end.y), 12, endMarkerPaint);

    final endBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(Offset(end.x, end.y), 12, endBorderPaint);
  }

  double _calculateDistance(IndoorNode start, IndoorNode end) {
    final dx = end.x - start.x;
    final dy = end.y - start.y;
    // Assume 1 pixel = 0.1 meters for display purposes
    return (dx * dx + dy * dy).abs() * 0.1;
  }

  @override
  bool shouldRepaint(FloorPlanPainter oldDelegate) {
    return oldDelegate.selectedNode != selectedNode ||
        oldDelegate.filterType != filterType ||
        oldDelegate.routeStart != routeStart ||
        oldDelegate.routeEnd != routeEnd;
  }
}

// Route setup dialog
class _RouteSetupDialog extends StatefulWidget {
  final IndoorNavigationService service;
  final IndoorNode destination;
  final Function(IndoorNode) onRouteSelected;

  const _RouteSetupDialog({
    required this.service,
    required this.destination,
    required this.onRouteSelected,
  });

  @override
  State<_RouteSetupDialog> createState() => _RouteSetupDialogState();
}

class _RouteSetupDialogState extends State<_RouteSetupDialog> {
  IndoorNode? _selectedStartNode;
  final TextEditingController _searchController = TextEditingController();
  List<IndoorNode> _filteredNodes = [];

  @override
  void initState() {
    super.initState();
    _filteredNodes = _getAvailableNodes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<IndoorNode> _getAvailableNodes() {
    if (widget.service.currentFloor == null) return [];

    return widget.service.currentFloor!.nodes
        .where(
          (node) =>
              node.id != widget.destination.id &&
              node.roomNumber != null &&
              node.type != NodeType.corridor &&
              node.type != NodeType.stairs,
        )
        .toList()
      ..sort((a, b) => (a.roomNumber ?? '').compareTo(b.roomNumber ?? ''));
  }

  void _filterNodes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredNodes = _getAvailableNodes();
      } else {
        _filteredNodes = _getAvailableNodes()
            .where(
              (node) =>
                  (node.roomNumber?.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ??
                      false) ||
                  node.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Set a route',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'In order to establish a route, select/search for a POI as a starting point and a destination.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Starting point input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Starting point',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _searchController,
                  onChanged: _filterNodes,
                  decoration: InputDecoration(
                    hintText: 'Search for starting point',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _selectedStartNode != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _selectedStartNode = null;
                                _searchController.clear();
                                _filteredNodes = _getAvailableNodes();
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF3252a8)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF3252a8),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Swap button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.swap_vert, size: 32),
                      onPressed: () {
                        // Swap functionality can be added here
                      },
                      color: const Color(0xFF3252a8),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Destination (fixed)
                const Text(
                  'TO',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.place, color: Color(0xFF3252a8)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.destination.roomNumber ??
                              widget.destination.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Get Directions button
          if (_selectedStartNode != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onRouteSelected(_selectedStartNode!);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3252a8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Rota Oluştur',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Available nodes list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filteredNodes.length,
              itemBuilder: (context, index) {
                final node = _filteredNodes[index];
                final isSelected = _selectedStartNode?.id == node.id;

                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF3252a8)
                          : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.room,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  title: Text(
                    node.roomNumber ?? node.name,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? const Color(0xFF3252a8)
                          : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    widget.service.getRoomTypeName(node.type),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFF3252a8))
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedStartNode = node;
                      _searchController.text = node.roomNumber ?? node.name;
                    });
                  },
                  selected: isSelected,
                  selectedTileColor: const Color(0xFF3252a8).withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Room search dialog
class _RoomSearchDialog extends StatefulWidget {
  final IndoorNavigationService service;

  const _RoomSearchDialog({required this.service});

  @override
  State<_RoomSearchDialog> createState() => _RoomSearchDialogState();
}

class _RoomSearchDialogState extends State<_RoomSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<IndoorNode> _filteredRooms = [];

  @override
  void initState() {
    super.initState();
    _filteredRooms = widget.service.availableNodes;
    _searchController.addListener(_filterRooms);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterRooms() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredRooms = widget.service.availableNodes;
      } else {
        _filteredRooms = widget.service.availableNodes.where((node) {
          final roomNumber = node.roomNumber?.toLowerCase() ?? '';
          final name = node.name.toLowerCase();
          return roomNumber.contains(query) || name.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        height: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF3252A8)),
                const SizedBox(width: 8),
                const Text(
                  'Oda Ara',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3252A8),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search field
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Oda numarası veya isim...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF3252A8),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Results
            Expanded(
              child: _filteredRooms.isEmpty
                  ? const Center(
                      child: Text(
                        'Oda bulunamadı',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredRooms.length,
                      itemBuilder: (context, index) {
                        final node = _filteredRooms[index];
                        final icon = widget.service.getRoomTypeIcon(node.type);
                        final typeName = widget.service.getRoomTypeName(
                          node.type,
                        );

                        return ListTile(
                          leading: Text(
                            icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(
                            node.roomNumber != null
                                ? 'Oda ${node.roomNumber}'
                                : node.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(typeName),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            widget.service.selectRoomById(node.id);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
