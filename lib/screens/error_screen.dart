import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/guardian_button.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.errorContainer.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wifi_off_rounded, size: 50, color: AppColors.error),
              ),
              const SizedBox(height: 32),
              Text(
                'Connection Lost',
                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.onSurface),
              ),
              const SizedBox(height: 12),
              Text(
                'Unable to reach the GuardianLink servers.\nPlease check your internet connection and try again.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant, height: 1.6),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: const Column(
                  children: [
                    _TroubleshootItem(icon: Icons.wifi, label: 'Check your WiFi or mobile data'),
                    SizedBox(height: 12),
                    _TroubleshootItem(icon: Icons.signal_cellular_alt, label: 'Ensure you have a strong signal'),
                    SizedBox(height: 12),
                    _TroubleshootItem(icon: Icons.refresh, label: 'Restart the application'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              GuardianButton(
                label: 'Try Again',
                icon: Icons.refresh,
                onPressed: () => context.go('/splash'),
              ),
              const SizedBox(height: 12),
              GuardianButton(
                label: 'Go to Home',
                outlined: true,
                onPressed: () => context.go('/role-selection'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TroubleshootItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TroubleshootItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}
