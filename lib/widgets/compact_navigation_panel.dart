import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CompactNavigationPanel extends StatelessWidget {
  final String destination;
  final String duration;
  final String distance;
  final String arrivalTime;
  final double progress; // 0.0 to 1.0
  final VoidCallback onEnd;
  final VoidCallback? onShowDirections;
  final VoidCallback? onCenterDestination;

  const CompactNavigationPanel({
    super.key,
    required this.destination,
    required this.duration,
    required this.distance,
    required this.arrivalTime,
    this.progress = 0.0,
    required this.onEnd,
    this.onShowDirections,
    this.onCenterDestination,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header Row: Title + End Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Yürüyerek',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      destination,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF202124),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: onEnd,
                child: const Text(
                  'Bitir',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5F6368),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Info Row: Time + Distance + Arrival
          Row(
            children: [
              Text(
                duration,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A73E8), // Google Blue
                ),
              ),
              const SizedBox(width: 16),
              Text(
                distance,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF5F6368),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                arrivalTime,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF5F6368),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Bar
          Row(
            children: [
              Transform.scale(
                scaleX: -1,
                child: const Text(
                  '🚶',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EAED),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A73E8),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '📍',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action Buttons: Talimatlar + Hedefe Git
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onShowDirections,
                  icon: const Icon(Icons.format_list_bulleted, size: 20),
                  label: const Text('Talimatlar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3252a8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onCenterDestination,
                  icon: const Icon(Icons.center_focus_strong, size: 20),
                  label: const Text('Hedefe Git'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3252a8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          
          // Bottom padding for safe area
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
