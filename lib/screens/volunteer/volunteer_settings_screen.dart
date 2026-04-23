import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_button.dart';

class VolunteerSettingsScreen extends StatefulWidget {
  const VolunteerSettingsScreen({super.key});

  @override
  State<VolunteerSettingsScreen> createState() => _VolunteerSettingsScreenState();
}

class _VolunteerSettingsScreenState extends State<VolunteerSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationSharing = true;
  bool _audioAlerts = true;
  double _radius = 5.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Account Settings'),
            _buildSettingTile(
              title: 'Profile Information',
              subtitle: 'Update your personal details and skills',
              icon: Icons.person_outline,
              onTap: () => context.push('/volunteer/profile'),
            ),
            _buildSettingTile(
              title: 'Verification Status',
              subtitle: 'Verified Responder',
              icon: Icons.verified_user_outlined,
              trailing: const Icon(Icons.check_circle, color: Colors.green, size: 20),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Response Preferences'),
            _buildSwitchTile(
              title: 'Active Duty',
              subtitle: 'Receive emergency alerts in your area',
              value: _notificationsEnabled,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
              icon: Icons.power_settings_new,
            ),
            _buildSwitchTile(
              title: 'Location Sharing',
              subtitle: 'Share your location for better dispatching',
              value: _locationSharing,
              onChanged: (val) => setState(() => _locationSharing = val),
              icon: Icons.location_on_outlined,
            ),
            _buildSwitchTile(
              title: 'Audio Alerts',
              subtitle: 'Play siren sound for critical incidents',
              value: _audioAlerts,
              onChanged: (val) => setState(() => _audioAlerts = val),
              icon: Icons.volume_up_outlined,
            ),
            const SizedBox(height: 16),
            Text(
              'Response Radius (${_radius.toInt()} km)',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            Slider(
              value: _radius,
              min: 1,
              max: 20,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.outlineVariant,
              onChanged: (val) => setState(() => _radius = val),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Security & System'),
            _buildSettingTile(
              title: 'Privacy Policy',
              icon: Icons.privacy_tip_outlined,
              onTap: () {},
            ),
            _buildSettingTile(
              title: 'Terms of Service',
              icon: Icons.description_outlined,
              onTap: () {},
            ),
            _buildSettingTile(
              title: 'Help & Support',
              icon: Icons.help_outline,
              onTap: () => context.push('/help'),
            ),
            const SizedBox(height: 32),
            GuardianButton(
              label: 'Sign Out',
              outlined: true,
              foregroundColor: Colors.redAccent,
              onPressed: () => context.go('/role-selection'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    String? subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.onSurfaceVariant),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              )
            : null,
        trailing: trailing ?? const Icon(Icons.chevron_right, size: 20, color: AppColors.outline),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: AppColors.onSurfaceVariant),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        activeThumbColor: AppColors.primary,
      ),
    );
  }
}
