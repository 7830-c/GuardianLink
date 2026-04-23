import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class PoliceSettingsScreen extends StatefulWidget {
  const PoliceSettingsScreen({super.key});
  @override
  State<PoliceSettingsScreen> createState() => _PoliceSettingsScreenState();
}

class _PoliceSettingsScreenState extends State<PoliceSettingsScreen> {
  bool _pushAlerts = true;
  bool _audioAlerts = true;
  bool _locationTracking = true;
  bool _biometric = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Dispatch Settings'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _header('Alert Preferences'),
          _toggle('Push Notifications', 'Receive priority incident alerts', Icons.notifications_active_outlined, _pushAlerts, (v) => setState(() => _pushAlerts = v)),
          _toggle('Audio Alerts', 'Play siren tone for critical incidents', Icons.volume_up_outlined, _audioAlerts, (v) => setState(() => _audioAlerts = v)),
          const SizedBox(height: 16),
          _header('Operational'),
          _toggle('Continuous Location Sharing', 'Required for dispatch routing', Icons.location_on_outlined, _locationTracking, (v) => setState(() => _locationTracking = v)),
          _toggle('Biometric Authentication', 'Use fingerprint/face ID for quick access', Icons.fingerprint, _biometric, (v) => setState(() => _biometric = v)),
          const SizedBox(height: 16),
          _header('System'),
          _navRow('Department Protocols', Icons.gavel_outlined, () {}),
          _navRow('Update Duty Status', Icons.work_outline, () {}),
          _navRow('Sign Out', Icons.logout, () => context.go('/role-selection'), color: Colors.redAccent),
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (i) {
          if (i == 0) context.pushReplacement('/police/command-center');
          if (i == 1) context.pushReplacement('/police/archive');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Dispatch'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), activeIcon: Icon(Icons.folder), label: 'Archive'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _header(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 0.5)),
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
      Switch(value: val, onChanged: onChange, activeThumbColor: AppColors.primary),
    ]),
  );

  Widget _navRow(String title, IconData icon, VoidCallback onTap, {Color? color}) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4))),
      child: Row(children: [
        Icon(icon, size: 20, color: color ?? AppColors.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: color ?? AppColors.onSurface))),
        Icon(Icons.chevron_right, size: 18, color: color ?? AppColors.outline),
      ]),
    ),
  );
}
