import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_button.dart';
import '../../widgets/guardian_text_field.dart';
import '../../services/auth_service.dart'; // 1. Import AuthService

class PoliceLoginScreen extends StatefulWidget {
  const PoliceLoginScreen({super.key});
  @override
  State<PoliceLoginScreen> createState() => _PoliceLoginScreenState();
}

class _PoliceLoginScreenState extends State<PoliceLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(); // Firebase uses Email for login
  final _passCtrl = TextEditingController();
  final _auth = AuthService(); // 2. Initialize AuthService
  
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() { 
    _emailCtrl.dispose(); 
    _passCtrl.dispose(); 
    super.dispose(); 
  }

  // 3. Updated Login Logic
  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      try {
        // Calling Firebase Sign-In with Role Verification
        await _auth.signIn(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
          expectedRole: 'police', // Verification: Only police can enter here
        );

        if (!mounted) return;
        
        // Success: Navigate to Dashboard
        context.go('/police/command-center');
        
      } catch (e) {
        if (!mounted) return;
        // Show error (Wrong password, Not a police account, etc.)
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
              
              // Police badge icon
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withAlpha(80), 
                  borderRadius: BorderRadius.circular(16)
                ),
                child: const Icon(Icons.local_police, size: 36, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text('Law Enforcement Login', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              const SizedBox(height: 8),
              Text('Secure portal for first responders', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 32),
              
              // Warning box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withAlpha(80)),
                ),
                child: Row(children: [
                  const Icon(Icons.security, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Official Personnel Only', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    Text('Access is logged and monitored.', style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
                  ])),
                ]),
              ),
              const SizedBox(height: 24),
              
              // Email Field (Changed from Badge ID to Email)
              GuardianTextField(
                label: 'Email Address',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                validator: (v) => v?.isEmpty == true ? 'Enter your email' : null,
              ),
              const SizedBox(height: 16),
              
              // Password Field
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
              const SizedBox(height: 24),
              
              // Authenticate Button
              GuardianButton(
                label: 'Authenticate',
                icon: Icons.fingerprint,
                isLoading: _loading,
                onPressed: _login,
              ),
              const SizedBox(height: 32),
              
              // Register Link
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("Need an account? ", style: GoogleFonts.inter(color: AppColors.onSurfaceVariant, fontSize: 13)),
                GestureDetector(
                  onTap: () => context.go('/police/register'), 
                  child: Text('Register here', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600))
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}