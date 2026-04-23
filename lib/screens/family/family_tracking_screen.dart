import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class FamilyTrackingScreen extends StatelessWidget {
  const FamilyTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Family Tracking'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () {})],
      ),
      body: Column(children: [
        // Map placeholder
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Stack(children: [
              // Map mock
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [Color(0xFF0D1B3E), Color(0xFF1a2744)]),
                  ),
                  child: CustomPaint(painter: _MapGridPainter()),
                ),
              ),
              // Member pins
              ...[
                {'x': 0.4, 'y': 0.3, 'name': 'Arjun', 'color': AppColors.tertiary},
                {'x': 0.6, 'y': 0.5, 'name': 'Priya', 'color': Colors.green},
                {'x': 0.25, 'y': 0.65, 'name': 'Meera', 'color': AppColors.secondary},
              ].map((pin) => Positioned(
                left: MediaQuery.of(context).size.width * (pin['x'] as double) - 60,
                top: (MediaQuery.of(context).size.height * 0.45) * (pin['y'] as double),
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: (pin['color'] as Color).withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8)),
                    child: Text(pin['name'] as String, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                  Container(width: 2, height: 12, color: pin['color'] as Color),
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: pin['color'] as Color, shape: BoxShape.circle)),
                ]),
              )),
              // Controls
              Positioned(top: 12, right: 12, child: Column(children: [
                _MapBtn(icon: Icons.add, onTap: () {}),
                const SizedBox(height: 8),
                _MapBtn(icon: Icons.remove, onTap: () {}),
                const SizedBox(height: 8),
                _MapBtn(icon: Icons.my_location, onTap: () {}),
              ])),
            ]),
          ),
        ),
        // Member list
        Expanded(
          flex: 2,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: const [
              _TrackingMember(name: 'Arjun', location: 'School, Sector 12', speed: '0 km/h', battery: 78, color: AppColors.tertiary),
              SizedBox(height: 8),
              _TrackingMember(name: 'Priya', location: 'Home, Rohini', speed: '0 km/h', battery: 92, color: Colors.green),
              SizedBox(height: 8),
              _TrackingMember(name: 'Meera', location: 'Last seen: City Mall', speed: '—', battery: 12, color: AppColors.secondary),
            ],
          ),
        ),
      ]),
    );
  }
}

class _MapBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: AppColors.surfaceContainerHigh.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.outlineVariant)),
      child: Icon(icon, size: 18, color: AppColors.onSurface),
    ),
  );
}

class _TrackingMember extends StatelessWidget {
  final String name, location, speed;
  final int battery;
  final Color color;
  const _TrackingMember({required this.name, required this.location, required this.speed, required this.battery, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
    child: Row(children: [
      Container(width: 4, height: 44, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 12),
      CircleAvatar(radius: 18, backgroundColor: color.withValues(alpha: 0.2), child: Text(name[0], style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: color))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
        Text(location, style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant), overflow: TextOverflow.ellipsis),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(children: [
          const Icon(Icons.battery_full, size: 14, color: AppColors.onSurfaceVariant),
          Text('$battery%', style: GoogleFonts.inter(fontSize: 11, color: battery < 20 ? AppColors.secondary : AppColors.onSurfaceVariant)),
        ]),
        Text(speed, style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline)),
      ]),
    ]),
  );
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF1E40AF).withValues(alpha: 0.1)..strokeWidth = 0.8;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
    // Roads
    final road = Paint()..color = const Color(0xFF2D3449)..strokeWidth = 4;
    canvas.drawLine(Offset(size.width * 0.2, 0), Offset(size.width * 0.4, size.height), road);
    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.55), road);
  }
  @override
  bool shouldRepaint(_) => false;
}
