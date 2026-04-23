import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_button.dart';

class EmergencyAlertViewScreen extends StatelessWidget {
  const EmergencyAlertViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          // Alert header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF7F1D1D), Color(0xFF991B1B)]),
            ),
            child: Row(children: [
              IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('🚨 SOS ALERT ACTIVE', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                Text('Arjun • Today at 3:42 PM', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                child: Text('ACTIVE', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Location card
                _InfoSection(
                  title: 'Last Known Location',
                  icon: Icons.location_on,
                  color: AppColors.secondary,
                  children: [
                    // Map stub
                    Container(
                      height: 160,
                      decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.map_outlined, size: 40, color: AppColors.onSurfaceVariant),
                        const SizedBox(height: 8),
                        Text('Connaught Place, New Delhi', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurface, fontWeight: FontWeight.w600)),
                        Text('28.6304° N, 77.2177° E', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                      ])),
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.access_time, size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('Updated 2 min ago', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    ]),
                  ],
                ),
                const SizedBox(height: 16),
                const _InfoSection(
                  title: 'Response Status',
                  icon: Icons.people,
                  color: AppColors.primary,
                  children: [
                    _ResponseItem(name: 'Ravi Kumar', role: 'Volunteer', status: 'En Route', distance: '0.8 km', eta: '3 min'),
                    SizedBox(height: 8),
                    _ResponseItem(name: 'Sunita Devi', role: 'Volunteer', status: 'Notified', distance: '1.2 km', eta: '—'),
                  ],
                ),
                const SizedBox(height: 16),
                const _InfoSection(
                  title: 'Alert Details',
                  icon: Icons.info_outline,
                  color: AppColors.onSurfaceVariant,
                  children: [
                    _DetailRow('Member', 'Arjun Sharma'),
                    _DetailRow('Alert Type', 'Manual SOS'),
                    _DetailRow('Battery Level', '67%'),
                    _DetailRow('Network', '4G LTE'),
                  ],
                ),
                const SizedBox(height: 24),
                GuardianButton(label: 'Call Arjun Now', icon: Icons.phone, backgroundColor: Colors.green[800], foregroundColor: Colors.white, onPressed: () {}),
                const SizedBox(height: 12),
                GuardianButton(label: 'Mark as Resolved', icon: Icons.check_circle_outline, onPressed: () => context.pop()),
                const SizedBox(height: 12),
                GuardianButton(label: 'Contact Police', icon: Icons.local_police, outlined: true, foregroundColor: AppColors.secondary, onPressed: () {}),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;
  const _InfoSection({required this.title, required this.icon, required this.color, required this.children});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, size: 18, color: color), const SizedBox(width: 8), Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: color))]),
      const SizedBox(height: 12),
      ...children,
    ]),
  );
}

class _ResponseItem extends StatelessWidget {
  final String name, role, status, distance, eta;
  const _ResponseItem({required this.name, required this.role, required this.status, required this.distance, required this.eta});
  @override
  Widget build(BuildContext context) => Row(children: [
    CircleAvatar(radius: 18, backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.3), child: Text(name[0], style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.primary))),
    const SizedBox(width: 10),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
      Text('$role • $distance away', style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
    ])),
    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.tertiary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)), child: Text(status, style: GoogleFonts.inter(fontSize: 11, color: AppColors.tertiary, fontWeight: FontWeight.w600))),
      Text('ETA: $eta', style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline)),
    ]),
  ]);
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Expanded(flex: 2, child: Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant))),
      Expanded(flex: 3, child: Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface))),
    ]),
  );
}
