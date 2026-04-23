import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_button.dart';
import '../../widgets/guardian_text_field.dart';

class VolunteerLoginScreen extends StatefulWidget {
  const VolunteerLoginScreen({super.key});
  @override
  State<VolunteerLoginScreen> createState() => _VolunteerLoginScreenState();
}

class _VolunteerLoginScreenState extends State<VolunteerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) { setState(() => _loading = false); context.go('/volunteer/active-alerts'); }
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
              IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.go('/role-selection')),
              const SizedBox(height: 24),
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: AppColors.secondaryContainer.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.volunteer_activism, size: 36, color: AppColors.secondary),
              ),
              const SizedBox(height: 24),
              Text('Volunteer Responder', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              const SizedBox(height: 8),
              Text('Sign in to respond to community alerts', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 32),
              // Volunteer ID badge
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.verified_user, color: AppColors.secondary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Verified Volunteer Network', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                    Text('Community-verified responders only', style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
                  ])),
                ]),
              ),
              const SizedBox(height: 24),
              GuardianTextField(
                label: 'Volunteer ID / Email',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.onSurfaceVariant, size: 20),
                validator: (v) => v?.isEmpty == true ? 'Enter your ID or email' : null,
              ),
              const SizedBox(height: 16),
              GuardianTextField(
                label: 'Password',
                controller: _passCtrl,
                obscureText: _obscure,
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.onSurfaceVariant, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.onSurfaceVariant, size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
                validator: (v) => v?.isEmpty == true ? 'Enter your password' : null,
              ),
              const SizedBox(height: 24),
              GuardianButton(
                label: 'Sign In',
                isLoading: _loading,
                onPressed: _login,
                backgroundColor: AppColors.secondaryContainer,
                foregroundColor: AppColors.onSecondaryContainer,
              ),
              const SizedBox(height: 32),
              Row(children: [
                const Expanded(child: Divider(color: AppColors.outlineVariant)),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('or', style: GoogleFonts.inter(color: AppColors.outline, fontSize: 13))),
                const Expanded(child: Divider(color: AppColors.outlineVariant)),
              ]),
              const SizedBox(height: 24),
              GuardianButton(label: 'Apply to Become a Volunteer', outlined: true, icon: Icons.person_add_outlined, onPressed: () => context.go('/volunteer/register')),
              const SizedBox(height: 32),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("New volunteer? ", style: GoogleFonts.inter(color: AppColors.onSurfaceVariant, fontSize: 13)),
                GestureDetector(onTap: () => context.go('/volunteer/register'), child: Text('Register here', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600))),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
