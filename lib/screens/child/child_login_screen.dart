import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_button.dart';
import '../../widgets/guardian_text_field.dart';

class ChildLoginScreen extends StatefulWidget {
  const ChildLoginScreen({super.key});

  @override
  State<ChildLoginScreen> createState() => _ChildLoginScreenState();
}

class _ChildLoginScreenState extends State<ChildLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  bool _obscurePin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _isLoading = false);
        context.go('/child/home');
      }
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                  onPressed: () => context.go('/role-selection'),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.child_care, size: 36, color: AppColors.tertiary),
                ),
                const SizedBox(height: 24),
                Text('Welcome Back',
                    style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                const SizedBox(height: 8),
                Text('Sign in to your child account',
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 40),
                GuardianTextField(
                  label: 'Phone Number',
                  hint: '+91 00000 00000',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.onSurfaceVariant, size: 20),
                  validator: (v) => v?.isEmpty == true ? 'Enter your phone number' : null,
                ),
                const SizedBox(height: 16),
                GuardianTextField(
                  label: 'PIN / Password',
                  controller: _pinController,
                  obscureText: _obscurePin,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.onSurfaceVariant, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePin ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.onSurfaceVariant, size: 20),
                    onPressed: () => setState(() => _obscurePin = !_obscurePin),
                  ),
                  validator: (v) => v?.isEmpty == true ? 'Enter your PIN' : null,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text('Forgot PIN?',
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: 24),
                GuardianButton(
                  label: 'Sign In',
                  isLoading: _isLoading,
                  onPressed: _login,
                  backgroundColor: AppColors.tertiaryContainer,
                  foregroundColor: AppColors.onTertiaryContainer,
                ),
                const SizedBox(height: 32),
                // Divider
                Row(children: [
                  const Expanded(child: Divider(color: AppColors.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or', style: GoogleFonts.inter(color: AppColors.outline, fontSize: 13)),
                  ),
                  const Expanded(child: Divider(color: AppColors.outlineVariant)),
                ]),
                const SizedBox(height: 24),
                GuardianButton(
                  label: 'Sign in with Guardian Code',
                  outlined: true,
                  icon: Icons.qr_code_scanner,
                  onPressed: () {},
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ",
                        style: GoogleFonts.inter(color: AppColors.onSurfaceVariant, fontSize: 13)),
                    GestureDetector(
                      onTap: () => context.go('/child/register'),
                      child: Text('Register',
                          style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
