import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_button.dart';

class IncidentAcknowledgedScreen extends StatelessWidget {
  const IncidentAcknowledgedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              _buildCheckAnimation(),
              const SizedBox(height: 40),
              Text(
                'Response Acknowledged',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Thank you for responding. Dispatch has been notified that you are en route to the location.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildIncidentSummary(),
              const Spacer(),
              GuardianButton(
                label: 'View Navigation',
                icon: Icons.navigation_outlined,
                onPressed: () => context.go('/live-tracking'),
              ),
              const SizedBox(height: 12),
              GuardianButton(
                label: 'Back to Alerts',
                outlined: true,
                onPressed: () => context.go('/volunteer/active-alerts'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckAnimation() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 4),
      ),
      child: const Center(
        child: Icon(
          Icons.check_rounded,
          size: 70,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildIncidentSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
              const SizedBox(width: 12),
              Text(
                'Incident GL-8291',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.outlineVariant),
          _buildSummaryRow(Icons.person_outline, 'Subject', 'Arjun S.'),
          _buildSummaryRow(Icons.location_on_outlined, 'Location', 'Sector 14, Mall Road'),
          _buildSummaryRow(Icons.timer_outlined, 'Status', 'Volunteer Dispatched'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
