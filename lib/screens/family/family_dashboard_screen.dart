import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_card.dart';

class FamilyDashboardScreen extends StatefulWidget {
  const FamilyDashboardScreen({super.key});
  @override
  State<FamilyDashboardScreen> createState() => _FamilyDashboardScreenState();
}

class _FamilyDashboardScreenState extends State<FamilyDashboardScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _members = [
    {'name': 'Arjun', 'status': 'Safe', 'location': 'School, Sector 12', 'time': '2 min ago', 'online': true},
    {'name': 'Priya', 'status': 'Safe', 'location': 'Home', 'time': '5 min ago', 'online': true},
    {'name': 'Meera', 'status': 'Unknown', 'location': 'Last seen: Mall', 'time': '45 min ago', 'online': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Family Dashboard', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                Text('All systems operational', style: GoogleFonts.inter(fontSize: 12, color: AppColors.tertiary)),
              ]),
              const Spacer(),
              IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.onSurface), onPressed: () {}),
              IconButton(icon: const Icon(Icons.settings_outlined, color: AppColors.onSurface), onPressed: () => context.push('/settings')),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Status overview
                const Row(children: [
                  Expanded(child: _StatCard(value: '3', label: 'Family Members', icon: Icons.people, color: AppColors.primary)),
                  SizedBox(width: 12),
                  Expanded(child: _StatCard(value: '2', label: 'Active', icon: Icons.check_circle, color: Colors.green)),
                  SizedBox(width: 12),
                  Expanded(child: _StatCard(value: '0', label: 'Alerts', icon: Icons.warning_amber, color: AppColors.secondary)),
                ]),
                const SizedBox(height: 24),
                // Active alert banner (mock)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.secondaryContainer.withValues(alpha: 0.6), AppColors.errorContainer.withValues(alpha: 0.3)]),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.info_outline, color: AppColors.secondary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text('Meera\'s location has not updated for 45 min', style: GoogleFonts.inter(fontSize: 13, color: AppColors.secondary))),
                    TextButton(onPressed: () => context.push('/family/emergency-alert'), child: Text('View', style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w700))),
                  ]),
                ),
                const SizedBox(height: 24),
                Text('Family Members', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                const SizedBox(height: 12),
                ..._members.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => context.push('/family/tracking'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Row(children: [
                        Stack(children: [
                          CircleAvatar(radius: 24, backgroundColor: AppColors.surfaceContainerHighest,
                              child: Text(m['name'][0], style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.primary))),
                          if (m['online']) Positioned(bottom: 0, right: 0, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: AppColors.surfaceContainerHigh, width: 2)))),
                        ]),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(m['name'], style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                          const SizedBox(height: 2),
                          Row(children: [
                            const Icon(Icons.location_on, size: 12, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 2),
                            Expanded(child: Text(m['location'], style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant), overflow: TextOverflow.ellipsis)),
                          ]),
                          const SizedBox(height: 2),
                          Text(m['time'], style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline)),
                        ])),
                        StatusChip(label: m['status'], color: m['status'] == 'Safe' ? Colors.green : AppColors.secondary),
                      ]),
                    ),
                  ),
                )),
                const SizedBox(height: 24),
                // Quick actions
                Text('Quick Actions', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _ActionBtn(icon: Icons.map_outlined, label: 'Live Map', color: AppColors.primary, onTap: () => context.push('/live-tracking'))),
                  const SizedBox(width: 12),
                  Expanded(child: _ActionBtn(icon: Icons.history, label: 'Alert History', color: AppColors.tertiary, onTap: () => context.push('/family/alert-history'))),
                  const SizedBox(width: 12),
                  Expanded(child: _ActionBtn(icon: Icons.person_add_outlined, label: 'Add Member', color: AppColors.onSurfaceVariant, onTap: () => context.push('/family/profile-management'))),
                ]),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) {
          setState(() => _selectedIndex = i);
          if (i == 1) context.push('/family/tracking');
          if (i == 2) context.push('/family/alert-history');
          if (i == 3) context.push('/family/settings');
          if (i == 4) context.push('/family/profile-management');
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

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatCard({required this.value, required this.label, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 6),
      Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
      Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant)),
    ]),
  );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
      child: Column(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(label, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant)),
      ]),
    ),
  );
}
