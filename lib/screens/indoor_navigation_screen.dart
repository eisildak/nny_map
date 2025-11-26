import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../models/indoor_building.dart';
import '../config/building_data.dart';
import '../services/pathfinding_service.dart';
import '../widgets/indoor_map_painter.dart';
import '../widgets/indoor_poi_bottom_sheet.dart';

/// İç mekan navigasyon ekranı
class IndoorNavigationScreen extends StatefulWidget {
  const IndoorNavigationScreen({super.key});

  @override
  State<IndoorNavigationScreen> createState() => _IndoorNavigationScreenState();
}

class _IndoorNavigationScreenState extends State<IndoorNavigationScreen>
    with SingleTickerProviderStateMixin {
  int _currentFloor = 0;
  String _startPoint = 'giris';
  String? _endPoint;
  List<String> _path = [];
  bool _devMode = false;
  Offset _mousePosition = Offset.zero;
  final Map<int, ui.Image?> _floorImages = {};
  FloorPOI? _selectedPOI;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    print('🏗️ IndoorNavigationScreen initState çalıştı');
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _calculatePath() {
    if (_endPoint == null) {
      setState(() {
        _path = [];
      });
      return;
    }

    final calculatedPath = PathFinding.findPath(
      startId: _startPoint,
      endId: _endPoint!,
      allNodes: EngineeringBuildingData.allNodes,
      allEdges: EngineeringBuildingData.allEdges,
      interFloorConnections: EngineeringBuildingData.interFloorConnections,
    );

    setState(() {
      _path = calculatedPath ?? [];
    });
  }

  Future<void> _pickImage() async {
    try {
      // Dosya seçici kullan (DWG, JPEG, PNG destekler)
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'dwg', 'pdf'],
        withData: true,
      );

      if (result != null && result.files.first.bytes != null) {
        final bytes = result.files.first.bytes!;
        final extension = result.files.first.extension?.toLowerCase();

        // DWG dosyası ise uyarı ver
        if (extension == 'dwg') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'DWG dosyası seçildi. Lütfen önce JPEG/PNG formatına dönüştürün.',
                ),
                duration: Duration(seconds: 4),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        // Resim yükle
        final ui.Image loadedImage = await _loadImage(bytes);

        setState(() {
          _floorImages[_currentFloor] = loadedImage;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kat planı yüklendi: ${result.files.first.name}'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resim yükleme hatası: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<ui.Image> _loadImage(Uint8List bytes) async {
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  @override
  Widget build(BuildContext context) {
    final building = EngineeringBuildingData.building;
    final currentFloorData = building.getFloor(_currentFloor);

    if (currentFloorData == null) {
      return const Scaffold(body: Center(child: Text('Kat bulunamadı')));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kampüs Navigasyon',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Mühendislik Fakültesi',
              style: TextStyle(fontSize: 12, color: Colors.blue[200]),
            ),
          ],
        ),
        actions: [
          // Dev Mode Toggle
          TextButton(
            onPressed: () {
              setState(() {
                _devMode = !_devMode;
              });
            },
            style: TextButton.styleFrom(
              backgroundColor: _devMode
                  ? const Color(0xFFFBBF24)
                  : Colors.transparent,
              foregroundColor: _devMode ? Colors.black : Colors.blue[200],
              side: BorderSide(
                color: _devMode
                    ? const Color(0xFFF59E0B)
                    : Colors.blue.shade400,
              ),
            ),
            child: Text(
              _devMode ? 'Geliştirici Modu AÇIK' : 'Geliştirici Modu',
              style: const TextStyle(fontSize: 11),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E40AF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16),
                SizedBox(width: 4),
                Text('Kiosk v1.1', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Sol Panel
          Container(
            width: 320,
            color: Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Harita Yükleme
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.upload_file,
                              size: 16,
                              color: Color(0xFF9A3412),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Harita Arkaplanı Yükle',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9A3412),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bu kat (${currentFloorData.name}) için PNG/JPG planı yükleyin.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFC2410C),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image, size: 16),
                          label: const Text('Resim Seç'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFED7AA),
                            foregroundColor: const Color(0xFF9A3412),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Başlangıç
                  const Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'BAŞLANGIÇ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _startPoint,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: 'giris',
                        child: Text('📍 Bina Ana Giriş'),
                      ),
                      ...EngineeringBuildingData.targetNodes.map((node) {
                        return DropdownMenuItem(
                          value: node.id,
                          child: Text(node.label),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _startPoint = value!;
                        _calculatePath();
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Ok işareti
                  const Center(
                    child: Icon(Icons.arrow_downward, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // Hedef
                  const Row(
                    children: [
                      Icon(Icons.navigation, size: 16, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'HEDEF',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _endPoint,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    hint: const Text('Hedef Seçiniz...'),
                    items: [
                      // Tüm POI'ları ekle
                      ...EngineeringBuildingData.building.floors.values
                          .expand((floor) => floor.pois)
                          .map((poi) {
                            return DropdownMenuItem(
                              value: poi.id,
                              child: Row(
                                children: [
                                  Text(
                                    _getPOIIcon(poi.category),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${poi.roomNumber ?? ''} ${poi.name}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _endPoint = value;
                        _calculatePath();
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // Kat Seçimi
                  const Divider(),
                  const Row(
                    children: [
                      Icon(Icons.layers, size: 18, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'Kat Seçimi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [0, 1, 2].map((floorId) {
                      final floorData = building.getFloor(floorId);
                      final isActive = _currentFloor == floorId;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _currentFloor = floorId;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isActive
                                  ? const Color(0xFF2563EB)
                                  : Colors.grey[100],
                              foregroundColor: isActive
                                  ? Colors.white
                                  : Colors.grey[600],
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: isActive ? 4 : 0,
                            ),
                            child: Text(
                              floorData?.name ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Sağ Panel: Harita
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: Stack(
                children: [
                  // Kat bilgisi
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentFloorData.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_devMode)
                            Row(
                              children: [
                                const Icon(
                                  Icons.mouse,
                                  size: 12,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'X: ${_mousePosition.dx.toInt()}, Y: ${_mousePosition.dy.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Canvas harita
                  Center(
                    child: MouseRegion(
                      onHover: (event) {
                        if (_devMode) {
                          setState(() {
                            _mousePosition = event.localPosition;
                          });
                        }
                      },
                      child: GestureDetector(
                        onTapUp: (details) {
                          _handleCanvasTap(
                            details.localPosition,
                            currentFloorData,
                          );
                        },
                        child: Container(
                          width: 800,
                          height: 650,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: IndoorMapPainter(
                                    floor: currentFloorData,
                                    path: _path,
                                    startNodeId: _startPoint,
                                    endNodeId: _endPoint,
                                    floorImage: _floorImages[_currentFloor],
                                    devMode: _devMode,
                                    animationOffset:
                                        _animationController.value * 15,
                                    selectedPOI: _selectedPOI,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _selectedPOI != null
          ? IndoorPOIBottomSheet(
              poi: _selectedPOI!,
              onNavigate: () {
                // POI'ya navigasyon başlat
                setState(() {
                  _endPoint = _selectedPOI!.id;
                  _calculatePath();
                });
                // Bottom sheet'i kapat
                setState(() {
                  _selectedPOI = null;
                });
              },
              onClose: () {
                setState(() {
                  _selectedPOI = null;
                });
              },
            )
          : null,
    );
  }

  void _handleCanvasTap(Offset position, BuildingFloor floor) {
    // Tıklanan konuma yakın POI var mı kontrol et
    const tapRadius = 30.0; // Tap alanı

    FloorPOI? tappedPOI;
    double minDistance = tapRadius;

    for (final poi in floor.pois) {
      final distance = (Offset(poi.x, poi.y) - position).distance;
      if (distance < minDistance) {
        minDistance = distance;
        tappedPOI = poi;
      }
    }

    if (tappedPOI != null) {
      setState(() {
        _selectedPOI = tappedPOI;
      });
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
}
