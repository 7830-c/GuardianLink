import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_button.dart';
import '../../widgets/guardian_text_field.dart';

class FamilyLoginScreen extends StatefulWidget {
  const FamilyLoginScreen({super.key});
  @override
  State<FamilyLoginScreen> createState() => _FamilyLoginScreenState();
}

class _FamilyLoginScreenState extends State<FamilyLoginScreen> {
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
              IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.go('/role-selection')),
              const SizedBox(height: 24),
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: AppColors.primaryContainer.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.family_restroom, size: 36, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text('Family Guardian', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              const SizedBox(height: 8),
              Text('Sign in to monitor & protect your family', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 40),
              GuardianTextField(
                label: 'Email Address',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.onSurfaceVariant, size: 20),
                validator: (v) => v?.isEmpty == true ? 'Enter your email' : null,
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
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: () {}, child: Text('Forgot Password?', style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary))),
              ),
              const SizedBox(height: 24),
              GuardianButton(label: 'Sign In', isLoading: _loading, onPressed: _login),
              const SizedBox(height: 32),
              Row(children: [
                const Expanded(child: Divider(color: AppColors.outlineVariant)),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('or', style: GoogleFonts.inter(color: AppColors.outline, fontSize: 13))),
                const Expanded(child: Divider(color: AppColors.outlineVariant)),
              ]),
              const SizedBox(height: 24),
              GuardianButton(label: 'Continue with Google', outlined: true, icon: Icons.g_mobiledata, onPressed: () {}),
              const SizedBox(height: 32),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("New to GuardianLink? ", style: GoogleFonts.inter(color: AppColors.onSurfaceVariant, fontSize: 13)),
                GestureDetector(
                  onTap: () => context.go('/family/register'),
                  child: Text('Create Account', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
