import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_button.dart';
import '../../widgets/guardian_text_field.dart';
import '../../services/auth_service.dart'; 

class LovedOneLoginScreen extends StatefulWidget {
  const LovedOneLoginScreen({super.key});

  @override
  State<LovedOneLoginScreen> createState() => _LovedOneLoginScreenState();
}

class _LovedOneLoginScreenState extends State<LovedOneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(); // Firebase needs Email
  final _pinController = TextEditingController(); // This acts as Password
  final _auth = AuthService(); // 2. AuthService Instance
  
  bool _obscurePin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  // 3. Updated Firebase Login Logic
  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _auth.signIn(
          email: _emailController.text.trim(),
          password: _pinController.text.trim(),
          expectedRole: 'loved_one', // Only Loved Ones can enter here
        );

        if (!mounted) return;
        
        // Success: Go to Arjun's Dashboard
        context.go('/loved-one/home');

      } catch (e) {
        if (!mounted) return;
        // Show Role Error or Auth Error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
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
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryContainer.withAlpha(80),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.favorite, size: 32, color: AppColors.tertiary),
                ),
                const SizedBox(height: 24),
                Text('Welcome Back',
                    style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                const SizedBox(height: 8),
                Text('Sign in to your personal safety account',
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 40),

                // Email Address Field
                GuardianTextField(
                  label: 'Email Address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  validator: (v) => v?.isEmpty == true ? 'Enter your email' : null,
                ),
                const SizedBox(height: 16),

                // PIN / Password Field
                GuardianTextField(
                  label: '6-Digit PIN',
                  controller: _pinController,
                  obscureText: _obscurePin,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePin ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                    onPressed: () => setState(() => _obscurePin = !_obscurePin),
                  ),
                  validator: (v) => v?.isEmpty == true ? 'Enter your PIN' : null,
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
                
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Don't have an account? ",
                      style: GoogleFonts.inter(color: AppColors.onSurfaceVariant, fontSize: 13)),
                  GestureDetector(
                    onTap: () => context.go('/loved-one/register'),
                    child: Text('Register',
                        style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}