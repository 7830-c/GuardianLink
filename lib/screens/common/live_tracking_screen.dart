import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class LiveTrackingScreen extends StatelessWidget {
  const LiveTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Live Tracking'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [
          IconButton(icon: const Icon(Icons.layers_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share_location_outlined), onPressed: () {}),
        ],
      ),
      body: Stack(children: [
        // Full-screen map
        Positioned.fill(
          child: Container(
            color: const Color(0xFF131B2E),
            child: CustomPaint(painter: _LiveMapPainter()),
          ),
        ),
        // Location pin
        Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 4)],
              ),
              child: const Icon(Icons.my_location, color: Colors.white, size: 28),
            ),
          ]),
        ),
        // Top info card
        Positioned(top: 16, left: 16, right: 16,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Row(children: [
              Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Location Sharing Active', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                Text('Connaught Place, New Delhi • Updated just now', style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
              ])),
              const Icon(Icons.gps_fixed, color: AppColors.primary, size: 20),
            ]),
          ),
        ),
        // Bottom panel
        Positioned(bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                const _MapStat('28.6304° N', 'Latitude'),
                Container(width: 1, height: 36, color: AppColors.outlineVariant),
                const _MapStat('77.2177° E', 'Longitude'),
                Container(width: 1, height: 36, color: AppColors.outlineVariant),
                const _MapStat('±5m', 'Accuracy'),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  icon: const Icon(Icons.stop, size: 16),
                  label: Text('Stop Sharing', style: GoogleFonts.inter(fontSize: 13)),
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.secondary, side: const BorderSide(color: AppColors.secondary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                )),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton.icon(
                  icon: const Icon(Icons.share, size: 16),
                  label: Text('Share Link', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer, foregroundColor: AppColors.onPrimaryContainer, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                )),
              ]),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _MapStat extends StatelessWidget {
  final String value, label;
  const _MapStat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
    Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline)),
  ]);
}

class _LiveMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = const Color(0xFF1E40AF).withValues(alpha: 0.08)..strokeWidth = 0.8;
    for (double x = 0; x < size.width; x += 25) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 25) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final road = Paint()..color = const Color(0xFF2D3449)..strokeWidth = 8;
    canvas.drawLine(Offset(0, size.height * 0.45), Offset(size.width, size.height * 0.48), road);
    canvas.drawLine(Offset(size.width * 0.48, 0), Offset(size.width * 0.52, size.height), road);
    final block = Paint()..color = const Color(0xFF171F33);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.1, size.height * 0.1, 80, 60), const Radius.circular(4)), block);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.6, size.height * 0.15, 100, 70), const Radius.circular(4)), block);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.1, size.height * 0.6, 90, 80), const Radius.circular(4)), block);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.65, size.height * 0.6, 85, 75), const Radius.circular(4)), block);
  }
  @override
  bool shouldRepaint(_) => false;
}
