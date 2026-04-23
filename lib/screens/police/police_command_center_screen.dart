import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class PoliceCommandCenterScreen extends StatefulWidget {
  const PoliceCommandCenterScreen({super.key});
  @override
  State<PoliceCommandCenterScreen> createState() => _PoliceCommandCenterScreenState();
}

class _PoliceCommandCenterScreenState extends State<PoliceCommandCenterScreen> {
  int _selectedIndex = 0;

  static const _activeIncidents = [
    {'id': 'GL-001', 'type': 'SOS Alert', 'location': 'Connaught Place', 'time': '2 min ago', 'status': 'Unassigned', 'priority': 'High'},
    {'id': 'GL-002', 'type': 'Distress Signal', 'location': 'Rajiv Chowk', 'time': '5 min ago', 'status': 'En Route', 'priority': 'Critical'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
              border: Border(bottom: BorderSide(color: AppColors.primary, width: 2)),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primaryContainer.withValues(alpha: 0.3), shape: BoxShape.circle),
                child: const Icon(Icons.local_police, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Command Center', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
                Text('Central Dispatch Unit', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary)),
              ]),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red)),
                child: Text('2 Critical', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.redAccent)),
              ),
            ]),
          ),
          
          // Map stub
          Container(
            height: 220,
            decoration: BoxDecoration(color: const Color(0xFF131B2E), border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3))),
            child: Stack(children: [
              Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.map_outlined, color: AppColors.onSurfaceVariant, size: 40),
                const SizedBox(height: 8),
                Text('Live Incident Map', style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
              ])),
              Positioned(bottom: 12, right: 12, child: FloatingActionButton.small(
                onPressed: () {},
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.my_location, color: Colors.white),
              )),
            ]),
          ),
          
          // List
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Active Incidents', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              Text('Filter', style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ]),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _activeIncidents.length,
              itemBuilder: (_, i) {
                final inc = _activeIncidents[i];
                final isCritical = inc['priority'] == 'Critical';
                return GestureDetector(
                  onTap: () => context.push('/police/incident-command-view'),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isCritical ? Colors.red.withValues(alpha: 0.5) : AppColors.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Column(children: [
                      if (isCritical) Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.2), borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
                        child: Center(child: Text('CRITICAL PRIORITY', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.redAccent, letterSpacing: 1))),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: isCritical ? Colors.red.withValues(alpha: 0.1) : AppColors.primaryContainer.withValues(alpha: 0.2), shape: BoxShape.circle),
                            child: Icon(Icons.warning_rounded, color: isCritical ? Colors.redAccent : AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(inc['type']!, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                            const SizedBox(height: 4),
                            Text(inc['location']!, style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: 8),
                            Row(children: [
                              Text(inc['id']!, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                              const SizedBox(width: 12),
                              const Icon(Icons.access_time, size: 12, color: AppColors.outline),
                              const SizedBox(width: 4),
                              Text(inc['time']!, style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline)),
                            ]),
                          ])),
                          const Icon(Icons.chevron_right, color: AppColors.outline),
                        ]),
                      ),
                    ]),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) {
          setState(() => _selectedIndex = i);
          if (i == 1) context.push('/police/archive');
          if (i == 2) context.push('/police/settings'); // Replace with proper routing if needed
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
