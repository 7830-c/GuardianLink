import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_button.dart';

class IncidentCommandViewScreen extends StatelessWidget {
  const IncidentCommandViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Incident GL-001', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.withValues(alpha: 0.5))),
            child: Row(children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('CRITICAL PRIORITY', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.redAccent, letterSpacing: 1)),
                Text('SOS Distress Signal', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
              ])),
            ]),
          ),
          const SizedBox(height: 16),
          
          // Map
          Container(
            height: 180,
            decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Icon(Icons.map, size: 40, color: AppColors.onSurfaceVariant)),
          ),
          const SizedBox(height: 16),
          
          // Info cards
          const _InfoBlock(title: 'Location Information', children: [
            _Row('Address', 'Connaught Place, New Delhi'),
            _Row('Coordinates', '28.6304° N, 77.2177° E'),
          ]),
          const SizedBox(height: 12),
          
          const _InfoBlock(title: 'Subject Details', children: [
            _Row('Name', 'Arjun Sharma'),
            _Row('Age', '14'),
            _Row('Phone', '+91 98765 43210'),
          ]),
          const SizedBox(height: 12),
          
          const _InfoBlock(title: 'Responder Status', children: [
            _Row('Volunteers', '3 En Route'),
            _Row('ETA', '4 minutes'),
          ]),
          
          const SizedBox(height: 32),
          GuardianButton(label: 'Dispatch Patrol Unit', icon: Icons.local_police, onPressed: () {}),
          const SizedBox(height: 12),
          GuardianButton(label: 'Mark as Resolved', outlined: true, onPressed: () => context.pop()),
        ]),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoBlock({required this.title, required this.children});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
      const Divider(color: AppColors.outlineVariant),
      ...children,
    ]),
  );
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      SizedBox(width: 100, child: Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant))),
      Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface))),
    ]),
  );
}
