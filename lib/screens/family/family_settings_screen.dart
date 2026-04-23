import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class FamilySettingsScreen extends StatefulWidget {
  const FamilySettingsScreen({super.key});
  @override
  State<FamilySettingsScreen> createState() => _FamilySettingsScreenState();
}

class _FamilySettingsScreenState extends State<FamilySettingsScreen> {
  bool _locationSharing = true;
  bool _emergencyAlerts = true;
  bool _volunteerAlerts = false;
  bool _biometricLock = true;
  bool _dataEncryption = true;
  String _alertRadius = '5 km';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Family Settings'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const _SectionHeader('Location & Tracking'),
          _SettingsTile(title: 'Real-time Location Sharing', subtitle: 'Share location with family members', value: _locationSharing, onChanged: (v) => setState(() => _locationSharing = v)),
          _SettingsTile(title: 'Location Update Frequency', subtitle: 'Every 30 seconds', trailing: _ChipSelector(const ['15s', '30s', '1m'], '30s', (_) {})),
          _SettingsTile(title: 'Alert Radius', subtitle: 'Geofence boundary for alerts', trailing: _ChipSelector(const ['1 km', '5 km', '10 km'], _alertRadius, (v) => setState(() => _alertRadius = v))),
          const SizedBox(height: 16),
          const _SectionHeader('Notifications'),
          _SettingsTile(title: 'Emergency Alerts', subtitle: 'SOS and critical safety alerts', value: _emergencyAlerts, onChanged: (v) => setState(() => _emergencyAlerts = v)),
          _SettingsTile(title: 'Volunteer Response Updates', subtitle: 'Get notified when volunteers respond', value: _volunteerAlerts, onChanged: (v) => setState(() => _volunteerAlerts = v)),
          const SizedBox(height: 16),
          const _SectionHeader('Security'),
          _SettingsTile(title: 'Biometric Lock', subtitle: 'Use fingerprint/face to unlock app', value: _biometricLock, onChanged: (v) => setState(() => _biometricLock = v)),
          _SettingsTile(title: 'End-to-End Encryption', subtitle: 'All data is encrypted', value: _dataEncryption, onChanged: (v) => setState(() => _dataEncryption = v)),
          const SizedBox(height: 16),
          const _SectionHeader('Account'),
          _NavTile(icon: Icons.person_outline, title: 'Manage Profile', onTap: () => context.push('/family/profile')),
          _NavTile(icon: Icons.group_outlined, title: 'Manage Family Members', onTap: () {}),
          _NavTile(icon: Icons.help_outline, title: 'Help & Support', onTap: () => context.push('/help')),
          _NavTile(icon: Icons.logout, title: 'Sign Out', color: AppColors.secondary, onTap: () => context.go('/role-selection')),
          const SizedBox(height: 24),
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        onTap: (i) {
          if (i == 0) context.pushReplacement('/family/dashboard');
          if (i == 1) context.pushReplacement('/family/tracking');
          if (i == 2) context.pushReplacement('/family/alert-history');
          if (i == 4) context.pushReplacement('/family/profile-management');
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 0.5)),
  );
}

class _SettingsTile extends StatelessWidget {
  final String title, subtitle;
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final Widget? trailing;
  const _SettingsTile({required this.title, required this.subtitle, this.value, this.onChanged, this.trailing});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4))),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
        const SizedBox(height: 2),
        Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
      ])),
      if (value != null && onChanged != null) Switch(value: value!, onChanged: onChanged),
      if (trailing != null) trailing!,
    ]),
  );
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;
  const _NavTile({required this.icon, required this.title, required this.onTap, this.color});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
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

class _ChipSelector extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;
  const _ChipSelector(this.options, this.selected, this.onSelect);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: options.map((o) => GestureDetector(
    onTap: () => onSelect(o),
    child: Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: o == selected ? AppColors.primaryContainer : AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(o, style: GoogleFonts.inter(fontSize: 11, color: o == selected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant)),
    ),
  )).toList());
}
