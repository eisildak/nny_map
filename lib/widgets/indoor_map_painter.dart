import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/indoor_building.dart';

/// İç mekan harita çizimini yapan custom painter
class IndoorMapPainter extends CustomPainter {
  final BuildingFloor floor;
  final List<String> path;
  final String? startNodeId;
  final String? endNodeId;
  final ui.Image? floorImage;
  final bool devMode;
  final double animationOffset;
  final FloorPOI? selectedPOI;
  final Function(FloorPOI)? onPOITap;

  IndoorMapPainter({
    required this.floor,
    required this.path,
    this.startNodeId,
    this.endNodeId,
    this.floorImage,
    this.devMode = false,
    this.animationOffset = 0,
    this.selectedPOI,
    this.onPOITap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Arka plan veya harita resmi çiz
    if (floorImage != null) {
      _drawFloorImage(canvas, size);
    } else {
      _drawDefaultBackground(canvas, size);
    }

    // 2. Bağlantıları (edge'leri) çiz
    _drawEdges(canvas);

    // 3. Aktif rotayı çiz
    if (path.length > 1) {
      _drawPath(canvas);
    }

    // 4. Node'ları çiz
    _drawNodes(canvas);

    // 5. POI'ları çiz
    _drawPOIs(canvas);
  }

  void _drawFloorImage(Canvas canvas, Size size) {
    if (floorImage == null) return;

    final srcRect = Rect.fromLTWH(
      0,
      0,
      floorImage!.width.toDouble(),
      floorImage!.height.toDouble(),
    );
    final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawImageRect(floorImage!, srcRect, dstRect, Paint());
  }

  void _drawDefaultBackground(Canvas canvas, Size size) {
    // Açık gri arka plan
    final bgPaint = Paint()..color = const Color(0xFFF3F4F6);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Bina çerçevesi
    final borderPaint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(const Rect.fromLTWH(50, 50, 700, 550), borderPaint);
  }

  void _drawEdges(Canvas canvas) {
    final edgePaint = Paint()
      ..color = floorImage != null
          ? const Color(0x4D2563EB) // Resim varsa yarı saydam mavi
          : const Color(0xFFE5E7EB) // Resim yoksa açık gri
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    for (final edge in floor.edges) {
      final n1 = floor.findNode(edge.from);
      final n2 = floor.findNode(edge.to);

      if (n1 != null && n2 != null) {
        canvas.drawLine(Offset(n1.x, n1.y), Offset(n2.x, n2.y), edgePaint);
      }
    }
  }

  void _drawPath(Canvas canvas) {
    final pathPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Kesikli çizgi efekti için Path ve PathMetric kullan
    final pathToDraw = Path();
    bool isDrawing = false;

    for (int i = 0; i < path.length - 1; i++) {
      final n1 = floor.findNode(path[i]);
      final n2 = floor.findNode(path[i + 1]);

      if (n1 != null && n2 != null) {
        if (!isDrawing) {
          pathToDraw.moveTo(n1.x, n1.y);
          isDrawing = true;
        }
        pathToDraw.lineTo(n2.x, n2.y);
      } else {
        isDrawing = false;
      }
    }

    // Animasyonlu kesikli çizgi
    canvas.drawPath(_createDashedPath(pathToDraw, animationOffset), pathPaint);
  }

  Path _createDashedPath(Path source, double offset) {
    final Path dashedPath = Path();
    const double dashWidth = 10.0;
    const double dashSpace = 5.0;

    final pathMetrics = source.computeMetrics();

    for (final metric in pathMetrics) {
      double distance = -offset;
      bool draw = true;

      while (distance < metric.length) {
        final length = draw ? dashWidth : dashSpace;
        final nextDistance = distance + length;

        if (draw && distance >= 0) {
          final startDistance = distance.clamp(0.0, metric.length);
          final endDistance = nextDistance.clamp(0.0, metric.length);

          dashedPath.addPath(
            metric.extractPath(startDistance, endDistance),
            Offset.zero,
          );
        }

        distance = nextDistance;
        draw = !draw;
      }
    }

    return dashedPath;
  }

  void _drawNodes(Canvas canvas) {
    for (final node in floor.nodes) {
      // Koridor node'ları sadece dev mode'da göster
      if (node.type == NodeType.koridor && !devMode) {
        continue;
      }

      Color nodeColor;
      double nodeSize;

      if (node.id == startNodeId) {
        nodeColor = const Color(0xFF60A5FA); // Mavi - başlangıç
        nodeSize = floorImage != null ? 10 : 30;
      } else if (node.id == endNodeId) {
        nodeColor = const Color(0xFFF87171); // Kırmızı - hedef
        nodeSize = floorImage != null ? 10 : 30;
      } else if (node.type == NodeType.merdiven) {
        nodeColor = const Color(0xFFFBBF24); // Sarı - merdiven
        nodeSize = floorImage != null ? 10 : 30;
      } else if (node.type == NodeType.koridor) {
        nodeColor = const Color(0xFFFF0000).withOpacity(0.5); // Dev mode
        nodeSize = 5;
      } else {
        nodeColor = floorImage != null
            ? Colors.white.withOpacity(0.7)
            : const Color(0xFFE5E7EB);
        nodeSize = floorImage != null ? 10 : 30;
      }

      final nodePaint = Paint()..color = nodeColor;

      if (floorImage != null || node.type == NodeType.koridor) {
        // Resim varsa veya koridor ise daire çiz
        canvas.drawCircle(Offset(node.x, node.y), nodeSize, nodePaint);

        if (floorImage != null && node.type != NodeType.koridor) {
          // Beyaz kenarlık
          final borderPaint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
          canvas.drawCircle(Offset(node.x, node.y), nodeSize, borderPaint);
        }
      } else {
        // Resim yoksa kare çiz
        final rect = Rect.fromCenter(
          center: Offset(node.x, node.y),
          width: nodeSize * 2,
          height: nodeSize * 2,
        );
        canvas.drawRect(rect, nodePaint);
      }

      // Label çiz (koridor hariç)
      if (node.type != NodeType.koridor) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: node.label,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        textPainter.layout();

        final offset = Offset(
          node.x - textPainter.width / 2,
          node.y + (floorImage != null ? -nodeSize - 20 : nodeSize + 5),
        );

        textPainter.paint(canvas, offset);
      }
    }
  }

  void _drawPOIs(Canvas canvas) {
    for (final poi in floor.pois) {
      final isSelected = selectedPOI?.id == poi.id;
      final poiSize = isSelected ? 16.0 : 12.0;

      // POI kategorisine göre renk
      final poiColor = _getPOIColor(poi.category);

      // POI marker çiz
      final markerPaint = Paint()..color = poiColor;
      final borderPaint = Paint()
        ..color = isSelected ? Colors.white : poiColor.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 3 : 2;

      // Pin şeklinde marker
      final pinPath = Path();
      pinPath.addOval(
        Rect.fromCircle(
          center: Offset(poi.x, poi.y - poiSize / 2),
          radius: poiSize / 2,
        ),
      );
      pinPath.moveTo(poi.x, poi.y);
      pinPath.lineTo(poi.x - poiSize / 3, poi.y - poiSize);
      pinPath.lineTo(poi.x + poiSize / 3, poi.y - poiSize);
      pinPath.close();

      canvas.drawPath(pinPath, markerPaint);
      canvas.drawPath(pinPath, borderPaint);

      // POI ikonu çiz
      final iconPainter = TextPainter(
        text: TextSpan(
          text: _getPOIIcon(poi.category),
          style: TextStyle(fontSize: poiSize * 0.6, color: Colors.white),
        ),
        textDirection: TextDirection.ltr,
      );
      iconPainter.layout();
      iconPainter.paint(
        canvas,
        Offset(
          poi.x - iconPainter.width / 2,
          poi.y - poiSize / 2 - iconPainter.height / 2 - poiSize / 4,
        ),
      );

      // POI ismi (sadece seçiliyse veya resim yoksa)
      if (isSelected || floorImage == null) {
        final labelPainter = TextPainter(
          text: TextSpan(
            text: poi.roomNumber ?? poi.name,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF1E3A8A)
                  : const Color(0xFF374151),
              fontSize: isSelected ? 13 : 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              backgroundColor: Colors.white.withOpacity(0.9),
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        labelPainter.layout();

        final labelOffset = Offset(poi.x - labelPainter.width / 2, poi.y + 8);

        // Label arka planı
        final labelBgRect = Rect.fromLTWH(
          labelOffset.dx - 4,
          labelOffset.dy - 2,
          labelPainter.width + 8,
          labelPainter.height + 4,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(labelBgRect, const Radius.circular(4)),
          Paint()..color = Colors.white.withOpacity(0.9),
        );

        labelPainter.paint(canvas, labelOffset);
      }
    }
  }

  Color _getPOIColor(POICategory category) {
    switch (category) {
      case POICategory.ofis:
        return const Color(0xFF8B5CF6); // Mor
      case POICategory.derslik:
        return const Color(0xFF3B82F6); // Mavi
      case POICategory.lab:
        return const Color(0xFF10B981); // Yeşil
      case POICategory.amfi:
        return const Color(0xFFF59E0B); // Turuncu
      case POICategory.yonetim:
        return const Color(0xFFEF4444); // Kırmızı
      case POICategory.servis:
        return const Color(0xFF6B7280); // Gri
      case POICategory.toplanti:
        return const Color(0xFF8B5CF6); // Mor
      case POICategory.kutuphane:
        return const Color(0xFF06B6D4); // Cyan
      case POICategory.diger:
        return const Color(0xFF9CA3AF); // Açık gri
    }
  }

  String _getPOIIcon(POICategory category) {
    switch (category) {
      case POICategory.ofis:
        return '👤';
      case POICategory.derslik:
        return '📚';
      case POICategory.lab:
        return '🔬';
      case POICategory.amfi:
        return '🎓';
      case POICategory.yonetim:
        return '🏛️';
      case POICategory.servis:
        return '🚻';
      case POICategory.toplanti:
        return '👥';
      case POICategory.kutuphane:
        return '📖';
      case POICategory.diger:
        return '📍';
    }
  }

  @override
  bool shouldRepaint(IndoorMapPainter oldDelegate) {
    return oldDelegate.floor != floor ||
        oldDelegate.path != path ||
        oldDelegate.startNodeId != startNodeId ||
        oldDelegate.endNodeId != endNodeId ||
        oldDelegate.floorImage != floorImage ||
        oldDelegate.devMode != devMode ||
        oldDelegate.animationOffset != animationOffset ||
        oldDelegate.selectedPOI != selectedPOI;
  }
}
