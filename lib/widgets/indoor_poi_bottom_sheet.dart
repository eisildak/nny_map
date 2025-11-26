import 'package:flutter/material.dart';
import '../models/indoor_building.dart';

/// İç mekan POI detay paneli
class IndoorPOIBottomSheet extends StatelessWidget {
  final FloorPOI poi;
  final VoidCallback onNavigate;
  final VoidCallback onClose;

  const IndoorPOIBottomSheet({
    super.key,
    required this.poi,
    required this.onNavigate,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Çekme çubuğu
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Başlık
          Row(
            children: [
              CircleAvatar(
                backgroundColor: _getCategoryColor(poi.category),
                radius: 28,
                child: Text(
                  _getCategoryIcon(poi.category),
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (poi.roomNumber != null)
                      Text(
                        poi.roomNumber!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    Text(
                      poi.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getCategoryName(poi.category),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: onClose),
            ],
          ),

          const SizedBox(height: 16),

          // Açıklama
          Text(poi.description, style: const TextStyle(fontSize: 16)),

          const SizedBox(height: 20),

          // İletişim bilgileri
          if (poi.phone != null || poi.email != null || poi.openHours != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (poi.phone != null)
                    _InfoRow(icon: Icons.phone, text: poi.phone!),
                  if (poi.email != null)
                    _InfoRow(icon: Icons.email, text: poi.email!),
                  if (poi.openHours != null && poi.openHours!.isNotEmpty)
                    _InfoRow(
                      icon: Icons.access_time,
                      text: poi.openHours!.join('\n'),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // Navigasyon butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onNavigate,
              icon: const Icon(Icons.directions_walk),
              label: const Text('Buraya Git'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Color _getCategoryColor(POICategory category) {
    switch (category) {
      case POICategory.ofis:
        return const Color(0xFF8B5CF6);
      case POICategory.derslik:
        return const Color(0xFF3B82F6);
      case POICategory.lab:
        return const Color(0xFF10B981);
      case POICategory.amfi:
        return const Color(0xFFF59E0B);
      case POICategory.yonetim:
        return const Color(0xFFEF4444);
      case POICategory.servis:
        return const Color(0xFF6B7280);
      case POICategory.toplanti:
        return const Color(0xFF8B5CF6);
      case POICategory.kutuphane:
        return const Color(0xFF06B6D4);
      case POICategory.diger:
        return const Color(0xFF9CA3AF);
    }
  }

  String _getCategoryIcon(POICategory category) {
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

  String _getCategoryName(POICategory category) {
    switch (category) {
      case POICategory.ofis:
        return 'Ofis';
      case POICategory.derslik:
        return 'Derslik';
      case POICategory.lab:
        return 'Laboratuvar';
      case POICategory.amfi:
        return 'Amfi';
      case POICategory.yonetim:
        return 'Yönetim';
      case POICategory.servis:
        return 'Servis';
      case POICategory.toplanti:
        return 'Toplantı Salonu';
      case POICategory.kutuphane:
        return 'Kütüphane';
      case POICategory.diger:
        return 'Diğer';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6B7280)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
            ),
          ),
        ],
      ),
    );
  }
}
