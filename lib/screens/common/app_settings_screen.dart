import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});
  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _notifications = true;
  bool _biometric = true;
  bool _darkMode = true;
  bool _autoSOS = false;
  bool _crashReport = true;
  bool _analyticsShare = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionHeader('General'),
          _toggle('Push Notifications', 'Receive alerts and updates', Icons.notifications_outlined, _notifications, (v) => setState(() => _notifications = v)),
          _toggle('Dark Mode', 'Use dark theme (recommended)', Icons.dark_mode_outlined, _darkMode, (v) => setState(() => _darkMode = v)),
          const SizedBox(height: 8),
          _sectionHeader('Safety & Emergency'),
          _toggle('Biometric Auth', 'Use fingerprint or face ID', Icons.fingerprint, _biometric, (v) => setState(() => _biometric = v)),
          _toggle('Auto SOS (Shake)', 'Shake phone rapidly to trigger SOS', Icons.vibration, _autoSOS, (v) => setState(() => _autoSOS = v)),
          const SizedBox(height: 8),
          _sectionHeader('Privacy & Data'),
          _toggle('Share Crash Reports', 'Help improve the app', Icons.bug_report_outlined, _crashReport, (v) => setState(() => _crashReport = v)),
          _toggle('Share Analytics', 'Anonymous usage data', Icons.analytics_outlined, _analyticsShare, (v) => setState(() => _analyticsShare = v)),
          const SizedBox(height: 8),
          _sectionHeader('About'),
          _navRow('Privacy Policy', Icons.privacy_tip_outlined, () => context.push('/help')),
          _navRow('Terms of Service', Icons.description_outlined, () => context.push('/help')),
          _navRow('Help & Support', Icons.help_outline, () => context.push('/help')),
          _navRow('Rate the App', Icons.star_outline, () {}),
          const SizedBox(height: 24),
          Center(child: Text('GuardianLink v1.0.0 • Sentinel Safety System', style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline))),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _sectionHeader(String t) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(t, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 0.5)),
  );

  Widget _toggle(String title, String sub, IconData icon, bool val, ValueChanged<bool> onChange) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4))),
    child: Row(children: [
      Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
        Text(sub, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
      ])),
      Switch(value: val, onChanged: onChange),
    ]),
  );

  Widget _navRow(String title, IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4))),
      child: Row(children: [
        Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface))),
        const Icon(Icons.chevron_right, size: 18, color: AppColors.outline),
      ]),
    ),
  );
}
