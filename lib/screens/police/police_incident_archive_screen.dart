import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_card.dart';

class PoliceIncidentArchiveScreen extends StatelessWidget {
  const PoliceIncidentArchiveScreen({super.key});

  static const _history = [
    {'id': 'GL-089', 'type': 'Distress Signal', 'location': 'Sector 14', 'date': 'Today, 10:15 AM', 'status': 'Resolved', 'priority': 'High'},
    {'id': 'GL-081', 'type': 'Missing Person', 'location': 'Central Park', 'date': 'Yesterday, 4:20 PM', 'status': 'Open', 'priority': 'Critical'},
    {'id': 'GL-070', 'type': 'Geofence Breach', 'location': 'School Zone A', 'date': 'Apr 20, 3:30 PM', 'status': 'Resolved', 'priority': 'Low'},
    {'id': 'GL-065', 'type': 'Medical Assist', 'location': 'Highway 4', 'date': 'Apr 18, 9:10 PM', 'status': 'Escalated', 'priority': 'Medium'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Incident Archive'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: Column(children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: _StatCard('142', 'Total Resolved')),
            SizedBox(width: 12),
            Expanded(child: _StatCard('3', 'Open Cases', color: Colors.amber)),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _history.length,
            itemBuilder: (_, i) {
              final inc = _history[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(inc['id']!, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    const Spacer(),
                    StatusChip(label: inc['status']!, color: inc['status'] == 'Resolved' ? Colors.green : inc['status'] == 'Open' ? Colors.amber : AppColors.tertiary),
                  ]),
                  const SizedBox(height: 8),
                  Text(inc['type']!, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(inc['location']!, style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
                  ]),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.outlineVariant),
                  const SizedBox(height: 4),
                  Row(children: [
                    Text(inc['date']!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.outline)),
                    const Spacer(),
                    Text('Priority: ${inc['priority']}', style: GoogleFonts.inter(fontSize: 12, color: inc['priority'] == 'Critical' ? Colors.redAccent : AppColors.outline)),
                  ]),
                ]),
              );
            },
          ),
        ),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) context.pushReplacement('/police/command-center');
          if (i == 2) context.pushReplacement('/police/settings');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Dispatch'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), activeIcon: Icon(Icons.folder), label: 'Archive'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatCard(this.value, this.label, {this.color = AppColors.primary});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
    child: Column(children: [
      Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
    ]),
  );
}
