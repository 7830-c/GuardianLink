import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_card.dart';

class AlertHistoryScreen extends StatelessWidget {
  const AlertHistoryScreen({super.key});

  static const _alerts = [
    {'name': 'Arjun', 'type': 'SOS Alert', 'location': 'Connaught Place, Delhi', 'time': 'Today, 3:42 PM', 'status': 'Resolved', 'color': 'red'},
    {'name': 'Meera', 'type': 'Low Battery', 'location': 'City Mall, Delhi', 'time': 'Today, 1:15 PM', 'status': 'Dismissed', 'color': 'yellow'},
    {'name': 'Arjun', 'type': 'Geofence Exit', 'location': 'Left School Zone', 'time': 'Yesterday, 4:05 PM', 'status': 'Resolved', 'color': 'blue'},
    {'name': 'Priya', 'type': 'SOS Alert', 'location': 'Metro Station, Rohini', 'time': 'Apr 20, 7:22 PM', 'status': 'Resolved', 'color': 'red'},
    {'name': 'Meera', 'type': 'Geofence Exit', 'location': 'Left Home Zone', 'time': 'Apr 19, 2:30 PM', 'status': 'Acknowledged', 'color': 'blue'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Alert History'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [IconButton(icon: const Icon(Icons.filter_list), onPressed: () {})],
      ),
      body: Column(children: [
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: ['All', 'SOS', 'Geofence', 'Battery', 'Resolved'].map((f) {
            final active = f == 'All';
            return Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: active ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? AppColors.primaryContainer : AppColors.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Text(f, style: GoogleFonts.inter(fontSize: 13, color: active ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant, fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
            );
          }).toList()),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _alerts.length,
            itemBuilder: (_, i) {
              final a = _alerts[i];
              final color = a['color'] == 'red' ? AppColors.secondary : a['color'] == 'yellow' ? AppColors.tertiary : AppColors.primary;
              final icon = a['color'] == 'red' ? Icons.sos : a['color'] == 'yellow' ? Icons.battery_alert : Icons.location_off;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AlertCard(
                  title: '${a['name']} — ${a['type']}',
                  subtitle: a['location']!,
                  time: a['time']!,
                  accentColor: color,
                  icon: icon,
                  status: a['status'],
                  onTap: () => context.push('/family/emergency-alert'),
                ),
              );
            },
          ),
        ),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (i) {
          if (i == 0) context.pushReplacement('/family/dashboard');
          if (i == 1) context.pushReplacement('/family/tracking');
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
