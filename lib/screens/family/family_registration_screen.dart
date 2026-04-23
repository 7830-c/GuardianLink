import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_button.dart';
import '../../widgets/guardian_text_field.dart';

class FamilyRegistrationScreen extends StatefulWidget {
  const FamilyRegistrationScreen({super.key});
  @override
  State<FamilyRegistrationScreen> createState() => _FamilyRegistrationScreenState();
}

class _FamilyRegistrationScreenState extends State<FamilyRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _agreed = false;

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  void _register() async {
    if (_formKey.currentState!.validate() && _agreed) {
      setState(() => _loading = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) { setState(() => _loading = false); context.go('/family/dashboard'); }
    }
  }

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
              IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.go('/family/login')),
              const SizedBox(height: 24),
              Text('Create Account', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              const SizedBox(height: 8),
              Text('Set up your guardian profile', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 32),
              // Avatar picker
              Center(
                child: Stack(children: [
                  Container(
                    width: 80, height: 80,
                    decoration: const BoxDecoration(color: AppColors.surfaceContainerHighest, shape: BoxShape.circle),
                    child: const Icon(Icons.person, size: 44, color: AppColors.onSurfaceVariant),
                  ),
                  Positioned(bottom: 0, right: 0, child: Container(
                    width: 26, height: 26,
                    decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle),
                    child: const Icon(Icons.add, size: 16, color: Colors.white),
                  )),
                ]),
              ),
              const SizedBox(height: 24),
              GuardianTextField(label: 'Full Name', controller: _nameCtrl, prefixIcon: const Icon(Icons.person_outline, color: AppColors.onSurfaceVariant, size: 20), validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 16),
              GuardianTextField(label: 'Email Address', controller: _emailCtrl, keyboardType: TextInputType.emailAddress, prefixIcon: const Icon(Icons.email_outlined, color: AppColors.onSurfaceVariant, size: 20), validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 16),
              GuardianTextField(label: 'Phone Number', controller: _phoneCtrl, keyboardType: TextInputType.phone, prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.onSurfaceVariant, size: 20), validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 16),
              GuardianTextField(label: 'Password', controller: _passCtrl, obscureText: true, prefixIcon: const Icon(Icons.lock_outline, color: AppColors.onSurfaceVariant, size: 20), validator: (v) => (v?.length ?? 0) < 8 ? 'Min 8 characters' : null),
              const SizedBox(height: 20),
              Row(children: [
                Checkbox(
                  value: _agreed,
                  onChanged: (v) => setState(() => _agreed = v ?? false),
                  activeColor: AppColors.primaryContainer,
                ),
                Expanded(child: Text.rich(TextSpan(children: [
                  TextSpan(text: 'I agree to the ', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
                  TextSpan(text: 'Terms of Service', style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                  TextSpan(text: ' and ', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
                  TextSpan(text: 'Privacy Policy', style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                ]))),
              ]),
              const SizedBox(height: 24),
              GuardianButton(label: 'Create Account', isLoading: _loading, onPressed: _agree ? _register : null),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Already have an account? ', style: GoogleFonts.inter(color: AppColors.onSurfaceVariant, fontSize: 13)),
                GestureDetector(onTap: () => context.go('/family/login'), child: Text('Sign In', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600))),
              ]),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ),
    );
  }

  bool get _agree => _agreed;
}
