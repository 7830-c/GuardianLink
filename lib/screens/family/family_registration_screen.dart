import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_button.dart';
import '../../widgets/guardian_text_field.dart';
import '../../services/auth_service.dart'; // Import AuthService

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
  
  final _auth = AuthService(); // Initialize AuthService instance
  bool _loading = false;
  bool _agreed = false;

  @override
  void dispose() { 
    _nameCtrl.dispose(); 
    _emailCtrl.dispose(); 
    _phoneCtrl.dispose(); 
    _passCtrl.dispose(); 
    super.dispose(); 
  }

  // Logic to handle family member registration
  void _handleRegistration() async {
    print("Registering family member...");
    if (_formKey.currentState!.validate() && _agreed) {
      setState(() => _loading = true);
      
      try {
        // Calling the register method from AuthService
        await _auth.register(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
          role: 'family', // Setting role as 'family'
          additionalData: {
            'name': _nameCtrl.text.trim(),
            'phone': _phoneCtrl.text.trim(),
            'agreedToTerms': _agreed,
          },
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );

        // Redirect to family dashboard after successful signup
        context.go('/family/dashboard');

      } catch (e) {
        if (!mounted) return;
        // Display error message if registration fails
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
                onPressed: () => context.go('/family/login')
              ),
              const SizedBox(height: 24),
              Text('Create Account', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              const SizedBox(height: 8),
              Text('Set up your guardian profile', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 32),
              
              // Profile Avatar Placeholder
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
              
              // Full Name Field
              GuardianTextField(
                label: 'Full Name', 
                controller: _nameCtrl, 
                prefixIcon: const Icon(Icons.person_outline, size: 20), 
                validator: (v) => v?.isEmpty == true ? 'Required' : null
              ),
              const SizedBox(height: 16),

              // Email Address Field
              GuardianTextField(
                label: 'Email Address', 
                controller: _emailCtrl, 
                keyboardType: TextInputType.emailAddress, 
                prefixIcon: const Icon(Icons.email_outlined, size: 20), 
                validator: (v) => v?.isEmpty == true ? 'Required' : null
              ),
              const SizedBox(height: 16),

              // Phone Number Field
              GuardianTextField(
                label: 'Phone Number', 
                controller: _phoneCtrl, 
                keyboardType: TextInputType.phone, 
                prefixIcon: const Icon(Icons.phone_outlined, size: 20), 
                validator: (v) => v?.isEmpty == true ? 'Required' : null
              ),
              const SizedBox(height: 16),

              // Password Field
              GuardianTextField(
                label: 'Password', 
                controller: _passCtrl, 
                isPassword: true, // Uses our updated isPassword parameter
                prefixIcon: const Icon(Icons.lock_outline, size: 20), 
                validator: (v) => (v?.length ?? 0) < 6 ? 'Min 6 characters' : null
              ),
              const SizedBox(height: 20),

              // Terms and Conditions Checkbox
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
              
              // Registration Button
              GuardianButton(
                label: 'Create Account', 
                isLoading: _loading, 
                onPressed: _agreed ? _handleRegistration : null // Enabled only if T&C agreed
              ),
              const SizedBox(height: 16),

              // Navigate to Login link
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Already have an account? ', style: GoogleFonts.inter(color: AppColors.onSurfaceVariant, fontSize: 13)),
                GestureDetector(
                  onTap: () => context.go('/family/login'), 
                  child: Text('Sign In', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600))
                ),
              ]),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ),
    );
  }
}