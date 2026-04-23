import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_map_view.dart';

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
        // Real Google Map
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(children: [
                GuardianMapView(
                  initialPosition: const LatLng(28.6139, 77.2090),
                  zoom: 13.0,
                  markers: {
                    Marker(markerId: const MarkerId('arjun'), position: const LatLng(28.6304, 77.2177), infoWindow: const InfoWindow(title: 'Arjun')),
                    Marker(markerId: const MarkerId('priya'), position: const LatLng(28.6100, 77.2300), infoWindow: const InfoWindow(title: 'Priya')),
                  },
                ),
              ]),
            ),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) context.pushReplacement('/family/dashboard');
          if (i == 2) context.pushReplacement('/family/alert-history');
          if (i == 3) context.pushReplacement('/family/settings');
          if (i == 4) context.pushReplacement('/family/profile-management');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Tracking'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), activeIcon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
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
