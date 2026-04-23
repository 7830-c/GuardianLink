import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_button.dart';
import '../../widgets/guardian_text_field.dart';

class FamilyProfileScreen extends StatefulWidget {
  const FamilyProfileScreen({super.key});
  @override
  State<FamilyProfileScreen> createState() => _FamilyProfileScreenState();
}

class _FamilyProfileScreenState extends State<FamilyProfileScreen> {
  final _nameCtrl = TextEditingController(text: 'Raj Sharma');
  final _emailCtrl = TextEditingController(text: 'raj.sharma@example.com');
  final _phoneCtrl = TextEditingController(text: '+91 98765 43210');
  final _addressCtrl = TextEditingController(text: 'Rohini, New Delhi, 110085');
  bool _editing = false;

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose(); _addressCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [IconButton(icon: Icon(_editing ? Icons.close : Icons.edit_outlined), onPressed: () => setState(() => _editing = !_editing))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          // Avatar
          Stack(alignment: Alignment.bottomRight, children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF3755C3)]), boxShadow: [BoxShadow(color: AppColors.primaryContainer.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2)]),
              child: const Icon(Icons.person, size: 52, color: Colors.white),
            ),
            if (_editing) Container(
              width: 32, height: 32,
              decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
            ),
          ]),
          const SizedBox(height: 16),
          Text('Raj Sharma', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text('Guardian Account', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
          ]),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primaryContainer.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primary.withValues(alpha: 0.4))),
            child: Text('ID: GL-2024-7843', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 32),
          // Stats row
          const Row(children: [
            _ProfileStat(value: '3', label: 'Members'),
            _ProfileStat(value: '12', label: 'Alerts'),
            _ProfileStat(value: '98%', label: 'Safety Score'),
          ]),
          const SizedBox(height: 32),
          // Form fields
          GuardianTextField(label: 'Full Name', controller: _nameCtrl, readOnly: !_editing, prefixIcon: const Icon(Icons.person_outline, size: 18, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 16),
          GuardianTextField(label: 'Email Address', controller: _emailCtrl, readOnly: !_editing, prefixIcon: const Icon(Icons.email_outlined, size: 18, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 16),
          GuardianTextField(label: 'Phone Number', controller: _phoneCtrl, readOnly: !_editing, prefixIcon: const Icon(Icons.phone_outlined, size: 18, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 16),
          GuardianTextField(label: 'Home Address', controller: _addressCtrl, readOnly: !_editing, maxLines: 2, prefixIcon: const Icon(Icons.home_outlined, size: 18, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 24),
          if (_editing) GuardianButton(label: 'Save Changes', onPressed: () => setState(() => _editing = false)),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value, label;
  const _ProfileStat({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
    Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
  ]));
}
