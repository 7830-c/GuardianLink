import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_button.dart';

class OfficerProfileScreen extends StatelessWidget {
  const OfficerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Officer Profile'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [IconButton(icon: const Icon(Icons.edit), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryContainer.withValues(alpha: 0.3), border: Border.all(color: AppColors.primary, width: 2)),
            child: const Icon(Icons.person, size: 50, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text('Inspector R.K. Singh', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
          Text('Badge: #784920', style: GoogleFonts.inter(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
            child: const Column(children: [
              _InfoRow(Icons.local_police_outlined, 'Precinct', 'Central Station, Zone 4'),
              Divider(color: AppColors.outlineVariant, height: 24),
              _InfoRow(Icons.phone_outlined, 'Contact', '+91 98765 43210'),
              Divider(color: AppColors.outlineVariant, height: 24),
              _InfoRow(Icons.email_outlined, 'Official Email', 'rksingh@police.gov.in'),
            ]),
          ),
          const SizedBox(height: 24),
          
          const Row(children: [
            Expanded(child: _StatBlock('142', 'Incidents Handled')),
            SizedBox(width: 12),
            Expanded(child: _StatBlock('A+', 'Response Rating')),
          ]),
          
          const SizedBox(height: 32),
          GuardianButton(label: 'Change Status (On Duty)', icon: Icons.sync, onPressed: () {}),
          const SizedBox(height: 12),
          GuardianButton(label: 'Sign Out', outlined: true, foregroundColor: Colors.redAccent, onPressed: () => context.go('/role-selection')),
        ]),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
    const SizedBox(width: 12),
    Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant))),
    Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
  ]);
}

class _StatBlock extends StatelessWidget {
  final String value, label;
  const _StatBlock(this.value, this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(color: AppColors.primaryContainer.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withValues(alpha: 0.3))),
    child: Column(children: [
      Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary)),
      const SizedBox(height: 4),
      Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
    ]),
  );
}
