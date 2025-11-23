import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/indoor_navigation_service.dart';
import '../models/floor.dart';

class IndoorMapWidget extends StatelessWidget {
  const IndoorMapWidget({super.key});

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
                  // Floor info bar
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: const Color(0xFF3252a8),
                    child: Row(
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
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed: () {
                            _showRoomSearchDialog(context, indoorService);
                          },
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
        size: const Size(600, 700),
        painter: FloorPlanPainter(
          floor: floor,
          selectedNode: service.selectedNode,
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

  FloorPlanPainter({required this.floor, this.selectedNode});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw walls and rooms
    final wallPaint = Paint()
      ..color = Colors.white
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

    // Draw simple floor plan
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), wallPaint);

    // Draw all nodes
    for (var node in floor.nodes) {
      if (node.roomNumber != null) {
        final isSelected = selectedNode?.id == node.id;
        final rect = Rect.fromCenter(
          center: Offset(node.x, node.y),
          width: 80,
          height: 60,
        );

        // Draw room
        canvas.drawRect(rect, isSelected ? selectedRoomPaint : roomPaint);
        canvas.drawRect(rect, isSelected ? highlightPaint : wallPaint);

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
            node.x - textPainter.width / 2,
            node.y - textPainter.height / 2 + 8,
          ),
        );

        // Draw POI marker (clickable indicator)
        if (!isSelected) {
          final poiPaint = Paint()
            ..color = const Color(0xFF3252A8).withOpacity(0.7)
            ..style = PaintingStyle.fill;

          canvas.drawCircle(Offset(node.x + 30, node.y - 20), 6, poiPaint);

          canvas.drawCircle(
            Offset(node.x + 30, node.y - 20),
            6,
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5,
          );
        }
      }
    }

    // Draw user icon at entrance
    final entranceNode = floor.nodes.firstWhere(
      (node) => node.type == NodeType.entrance,
      orElse: () => floor.nodes.first,
    );

    _drawUserIcon(canvas, Offset(entranceNode.x, entranceNode.y));
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
    return oldDelegate.selectedNode != selectedNode;
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
