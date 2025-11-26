import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/indoor_navigation_service.dart';
import '../models/floor.dart';

class IndoorMapWidget extends StatefulWidget {
  const IndoorMapWidget({super.key});

  @override
  State<IndoorMapWidget> createState() => _IndoorMapWidgetState();
}

class _IndoorMapWidgetState extends State<IndoorMapWidget> {
  String _selectedFilter = 'all';

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
                indoorService.exitBuilding();
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

              // Mini map (küçük harita sağ altta)
              Positioned(right: 16, bottom: 100, child: _buildMiniMap(context)),

              // Room info bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildRoomInfoBar(context, indoorService),
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

  Widget _buildMiniMap(BuildContext context) {
    final indoorService = Provider.of<IndoorNavigationService>(
      context,
      listen: false,
    );
    final building = indoorService.currentBuilding;

    if (building == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        // Haritayı büyütmek için tıklanabilir (gelecekte eklenebilir)
      },
      child: Container(
        width: 150,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF3252A8), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              // Harita ikonu veya basitleştirilmiş görünüm
              Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.map, size: 40, color: Color(0xFF3252A8)),
                ),
              ),
              // Bina konumu göstergesi
              Positioned(
                left: 75,
                top: 50,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
              // Overlay - dış haritaya dön yazısı
              Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  color: Colors.black54,
                  child: const Text(
                    'Dış Harita',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
            color: Colors.white,
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
        backgroundColor: Colors.white.withOpacity(0.2),
        selectedColor: Colors.white.withOpacity(0.4),
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
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
        ),
      ),
    );
  }

  Widget _buildRoomInfoBar(
    BuildContext context,
    IndoorNavigationService service,
  ) {
    final node = service.selectedNode!;
    final icon = service.getRoomTypeIcon(node.type);
    final typeName = service.getRoomTypeName(node.type);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.roomNumber != null
                          ? 'Oda ${node.roomNumber}'
                          : node.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3252a8),
                      ),
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
                              fontSize: 14,
                              color: Color(0xFF3252a8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (node.description != null) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              node.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom painter for floor plan
class FloorPlanPainter extends CustomPainter {
  final Floor floor;
  final IndoorNode? selectedNode;
  final ui.Image? floorPlanImage;
  final String filterType;

  FloorPlanPainter({
    required this.floor,
    this.selectedNode,
    this.floorPlanImage,
    this.filterType = 'all',
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    final bgPaint = Paint()..color = const Color(0xFFF5F5F5);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    double scale = 1.0;
    double dx = 0.0;
    double dy = 0.0;

    // Draw floor plan image if available
    if (floorPlanImage != null) {
      final src = Size(
        floorPlanImage!.width.toDouble(),
        floorPlanImage!.height.toDouble(),
      );
      final fitted = applyBoxFit(BoxFit.contain, src, size);
      scale = fitted.destination.width / src.width;
      dx = (size.width - fitted.destination.width) / 2;
      dy = (size.height - fitted.destination.height) / 2;

      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.width, size.height),
        image: floorPlanImage!,
        fit: BoxFit.contain,
      );
    } else {
      // Fallback: Draw simple floor plan walls
      final wallPaint = Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), wallPaint);
    }

    // Draw walls and rooms (Overlay)
    final wallPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final roomPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.fill;

    final selectedRoomPaint = Paint()
      ..color = const Color(0xFF3252a8).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final highlightPaint = Paint()
      ..color = const Color(0xFF3252a8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Draw all nodes
    for (var node in floor.nodes) {
      if (node.roomNumber != null) {
        final isSelected = selectedNode?.id == node.id;

        // Check if node matches filter
        bool matchesFilter =
            filterType == 'all' ||
            (filterType == 'classroom' && node.type == NodeType.classroom) ||
            (filterType == 'office' && node.type == NodeType.office) ||
            (filterType == 'cafeteria' && node.type == NodeType.cafeteria) ||
            (filterType == 'stairs' && node.type == NodeType.stairs);

        // Transform coordinates
        final nodeX = node.x * scale + dx;
        final nodeY = node.y * scale + dy;

        final rect = Rect.fromCenter(
          center: Offset(nodeX, nodeY),
          width: 80,
          height: 60,
        );

        // Apply opacity for non-matching rooms
        final opacity = matchesFilter ? 1.0 : 0.3;

        // Draw room
        final roomPaintToUse = isSelected ? selectedRoomPaint : roomPaint;
        canvas.saveLayer(
          rect,
          Paint()..color = Colors.white.withOpacity(opacity),
        );
        canvas.drawRect(rect, roomPaintToUse);
        canvas.drawRect(rect, isSelected ? highlightPaint : wallPaint);
        canvas.restore();

        // Draw room number
        final textPainter = TextPainter(
          text: TextSpan(
            text: node.roomNumber,
            style: TextStyle(
              color: isSelected ? const Color(0xFF3252a8) : Colors.black87,
              fontSize: isSelected ? 18 : 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            nodeX - textPainter.width / 2,
            nodeY - textPainter.height / 2 + 8,
          ),
        );

        // Draw colored icon based on room type (matching React component)
        Color iconColor;

        switch (node.type) {
          case NodeType.classroom:
            iconColor = const Color(0xFF6366f1); // Purple for Amfi/Classrooms
            break;
          case NodeType.office:
            iconColor = const Color(0xFFf59e0b); // Orange for Offices
            break;
          case NodeType.cafeteria:
            iconColor = const Color(0xFFec4899); // Pink for Social
            break;
          case NodeType.restroom:
            iconColor = const Color(0xFF8b5cf6); // Purple for WC
            break;
          case NodeType.stairs:
            iconColor = const Color(0xFF64748b); // Gray for Stairs
            break;
          default:
            iconColor = const Color(0xFF10b981); // Green default
        }

        // Draw circular icon background
        final iconPaint = Paint()
          ..color = iconColor
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(nodeX, nodeY - 20), 16, iconPaint);

        // Draw white border
        final iconBorderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawCircle(Offset(nodeX, nodeY - 20), 16, iconBorderPaint);

        // Draw icon using TextPainter (emoji approach)
        String iconEmoji;
        switch (node.type) {
          case NodeType.classroom:
            iconEmoji = '👥';
            break;
          case NodeType.office:
            iconEmoji = '💼';
            break;
          case NodeType.cafeteria:
            iconEmoji = '☕';
            break;
          case NodeType.restroom:
            iconEmoji = '🚻';
            break;
          case NodeType.stairs:
            iconEmoji = '⬆️';
            break;
          default:
            iconEmoji = '🎓';
        }

        final iconTextPainter = TextPainter(
          text: TextSpan(text: iconEmoji, style: const TextStyle(fontSize: 16)),
          textDirection: TextDirection.ltr,
        );
        iconTextPainter.layout();
        iconTextPainter.paint(
          canvas,
          Offset(
            nodeX - iconTextPainter.width / 2,
            nodeY - 28 - iconTextPainter.height / 2,
          ),
        );
      }
    }

    // Draw user icon at entrance
    final entranceNode = floor.nodes.firstWhere(
      (node) => node.type == NodeType.entrance,
      orElse: () => floor.nodes.first,
    );

    // Transform entrance coordinates
    final entranceX = entranceNode.x * scale + dx;
    final entranceY = entranceNode.y * scale + dy;

    _drawUserIcon(canvas, Offset(entranceX, entranceY));
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

  @override
  bool shouldRepaint(FloorPlanPainter oldDelegate) {
    return oldDelegate.selectedNode != selectedNode ||
        oldDelegate.floorPlanImage != floorPlanImage ||
        oldDelegate.filterType != filterType;
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
