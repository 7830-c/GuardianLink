import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_button.dart';
import '../../widgets/guardian_text_field.dart';

class PoliceRegistrationScreen extends StatefulWidget {
  const PoliceRegistrationScreen({super.key});
  @override
  State<PoliceRegistrationScreen> createState() => _PoliceRegistrationScreenState();
}

class _PoliceRegistrationScreenState extends State<PoliceRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _badgeCtrl = TextEditingController();
  final _stationCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() { _nameCtrl.dispose(); _badgeCtrl.dispose(); _stationCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 16),
              IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.go('/police/login')),
              const SizedBox(height: 24),
              Text('Officer Registration', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              const SizedBox(height: 8),
              Text('Register for access to GuardianLink dispatch', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 32),
              
              GuardianTextField(label: 'Full Name', controller: _nameCtrl, prefixIcon: const Icon(Icons.person_outline, color: AppColors.onSurfaceVariant, size: 20), validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 16),
              GuardianTextField(label: 'Badge Number', controller: _badgeCtrl, prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.onSurfaceVariant, size: 20), validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 16),
              GuardianTextField(label: 'Precinct / Station Name', controller: _stationCtrl, prefixIcon: const Icon(Icons.local_police_outlined, color: AppColors.onSurfaceVariant, size: 20), validator: (v) => v?.isEmpty == true ? 'Required' : null),
              
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Your application will undergo department verification before access is granted.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.5))),
                ]),
              ),
              const SizedBox(height: 24),
              
              GuardianButton(
                label: 'Submit Verification',
                isLoading: _loading,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _loading = true);
                    await Future.delayed(const Duration(seconds: 2));
                    if (!context.mounted) return;
                    setState(() => _loading = false);
                    context.go('/police/login');
                  }
                },
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
