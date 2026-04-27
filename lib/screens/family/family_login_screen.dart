import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_button.dart';
import '../../widgets/guardian_text_field.dart';
import '../../services/auth_service.dart'; // 1. AuthService Import kiya

class FamilyLoginScreen extends StatefulWidget {
  const FamilyLoginScreen({super.key});
  @override
  State<FamilyLoginScreen> createState() => _FamilyLoginScreenState();
}

class _FamilyLoginScreenState extends State<FamilyLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService(); // 2. AuthService Instance
  
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() { 
    _emailCtrl.dispose(); 
    _passCtrl.dispose(); 
    super.dispose(); 
  }

  // 3. Updated Real Login Logic
  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      try {
        // Calling Firebase Sign-In with Role Verification
        await _auth.signIn(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
          expectedRole: 'family', // Strict check for family role
        );

        if (!mounted) return;
        
        // Success: Go to Family Dashboard
        context.go('/family/dashboard');

      } catch (e) {
        if (!mounted) return;
        // This will now catch "Unauthorized: Account is registered as police/volunteer"
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _loading = false);
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 16),
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), 
                onPressed: () => context.go('/role-selection')
              ),
              const SizedBox(height: 24),
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withAlpha(80), 
                  borderRadius: BorderRadius.circular(16)
                ),
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
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                validator: (v) => v?.isEmpty == true ? 'Enter your email' : null,
              ),
              const SizedBox(height: 16),
              GuardianTextField(
                label: 'Password',
                controller: _passCtrl,
                obscureText: _obscure,
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
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
              
              GuardianButton(
                label: 'Sign In', 
                isLoading: _loading, 
                onPressed: _login
              ),
              
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