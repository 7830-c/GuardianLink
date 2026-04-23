import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_button.dart';
import '../../widgets/guardian_text_field.dart';

class ProfileManagementScreen extends StatefulWidget {
  const ProfileManagementScreen({super.key});
  @override
  State<ProfileManagementScreen> createState() => _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> {
  bool _editing = false;
  final _nameCtrl = TextEditingController(text: 'Raj Sharma');
  final _emailCtrl = TextEditingController(text: 'raj.sharma@example.com');
  final _phoneCtrl = TextEditingController(text: '+91 98765 43210');
  final _bioCtrl = TextEditingController(text: 'Protecting my family with GuardianLink since 2024.');

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose(); _bioCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [IconButton(icon: Icon(_editing ? Icons.close : Icons.edit_outlined), onPressed: () => setState(() => _editing = !_editing))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          // Header
          Stack(alignment: Alignment.bottomRight, children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF3755C3)]), boxShadow: [BoxShadow(color: AppColors.primaryContainer.withValues(alpha: 0.5), blurRadius: 20)]),
              child: const Icon(Icons.person, size: 54, color: Colors.white),
            ),
            if (_editing) Container(width: 32, height: 32, decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle), child: const Icon(Icons.camera_alt, size: 16, color: Colors.white)),
          ]),
          const SizedBox(height: 16),
          Text('Raj Sharma', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primaryContainer.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(20)),
            child: Text('Guardian Account  •  ID: GL-2024-7843', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 24),
          // Stats
          const Row(children: [
            _Stat('3', 'Members'),
            _Stat('12', 'Alerts'),
            _Stat('98%', 'Safety'),
            _Stat('4.8★', 'Rating'),
          ]),
          const SizedBox(height: 24),
          // Emergency contacts section
          const _SectionLabel('Emergency Contacts'),
          const _ContactCard(name: 'Sita Sharma', relation: 'Sister', phone: '+91 87654 32109'),
          const SizedBox(height: 8),
          const _ContactCard(name: 'Dr. Vikram', relation: 'Family Doctor', phone: '+91 76543 21098'),
          if (_editing) Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: Text('Add Emergency Contact', style: GoogleFonts.inter(fontSize: 13)),
              onPressed: () {},
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary), minimumSize: const Size(double.infinity, 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            ),
          ),
          const SizedBox(height: 16),
          const _SectionLabel('Personal Information'),
          GuardianTextField(label: 'Full Name', controller: _nameCtrl, readOnly: !_editing, prefixIcon: const Icon(Icons.person_outline, size: 18, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 12),
          GuardianTextField(label: 'Email', controller: _emailCtrl, readOnly: !_editing, prefixIcon: const Icon(Icons.email_outlined, size: 18, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 12),
          GuardianTextField(label: 'Phone', controller: _phoneCtrl, readOnly: !_editing, prefixIcon: const Icon(Icons.phone_outlined, size: 18, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 12),
          GuardianTextField(label: 'Bio', controller: _bioCtrl, readOnly: !_editing, maxLines: 2),
          const SizedBox(height: 24),
          if (_editing) GuardianButton(label: 'Save Changes', icon: Icons.save_outlined, onPressed: () => setState(() => _editing = false)),
          const SizedBox(height: 12),
          GuardianButton(label: 'Help & Support', icon: Icons.help_outline, outlined: true, onPressed: () => context.push('/help')),
          const SizedBox(height: 12),
          GuardianButton(label: 'Sign Out', outlined: true, foregroundColor: AppColors.secondary, onPressed: () => context.go('/role-selection')),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Align(alignment: Alignment.centerLeft, child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 0.5))),
  );
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
    Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
  ]));
}

class _ContactCard extends StatelessWidget {
  final String name, relation, phone;
  const _ContactCard({required this.name, required this.relation, required this.phone});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4))),
    child: Row(children: [
      CircleAvatar(radius: 18, backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.3), child: Text(name[0], style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.primary))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
        Text(relation, style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
      ])),
      Text(phone, style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
    ]),
  );
}
