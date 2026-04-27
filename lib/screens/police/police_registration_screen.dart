import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_button.dart';
import '../../widgets/guardian_text_field.dart';
import '../../services/auth_service.dart'; // Import AuthService

class PoliceRegistrationScreen extends StatefulWidget {
  const PoliceRegistrationScreen({super.key});
  @override
  State<PoliceRegistrationScreen> createState() => _PoliceRegistrationScreenState();
}

class _PoliceRegistrationScreenState extends State<PoliceRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for input fields
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController(); // Added email controller
  final _passwordCtrl = TextEditingController(); // Added password controller
  final _badgeCtrl = TextEditingController();
  final _stationCtrl = TextEditingController();
  
  final _auth = AuthService(); // Initialize AuthService instance
  bool _loading = false;

  @override
  void dispose() { 
    _nameCtrl.dispose(); 
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _badgeCtrl.dispose(); 
    _stationCtrl.dispose(); 
    super.dispose(); 
  }

  // Handle police officer registration
  Future<void> _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      
      try {
        // Calling register from AuthService
        await _auth.register(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
          role: 'police',
          additionalData: {
            'name': _nameCtrl.text.trim(),
            'badgeNumber': _badgeCtrl.text.trim(),
            'station': _stationCtrl.text.trim(),
            'isVerified': false, // Police requires manual verification
          },
        );

        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Waiting for approval.')),
        );
        
        // Redirect to login after successful registration
        context.go('/police/login');
        
      } catch (e) {
        if (!mounted) return;
        // Show error message if registration fails
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
                onPressed: () => context.go('/police/login'),
              ),
              const SizedBox(height: 24),
              Text('Officer Registration', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              const SizedBox(height: 8),
              Text('Register for access to GuardianLink dispatch', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 32),
              
              // Full Name Field
              GuardianTextField(
                label: 'Full Name', 
                controller: _nameCtrl, 
                prefixIcon: const Icon(Icons.person_outline, size: 20), 
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Email Address Field
              GuardianTextField(
                label: 'Email Address', 
                controller: _emailCtrl, 
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, size: 20), 
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Password Field (Added for Firebase Auth)
              GuardianTextField(
                label: 'Password', 
                controller: _passwordCtrl, 
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline, size: 20), 
                validator: (v) => (v?.length ?? 0) < 6 ? 'Password must be at least 6 characters' : null,
              ),
              const SizedBox(height: 16),

              // Badge Number Field
              GuardianTextField(
                label: 'Badge Number', 
                controller: _badgeCtrl, 
                prefixIcon: const Icon(Icons.badge_outlined, size: 20), 
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Station Name Field
              GuardianTextField(
                label: 'Precinct / Station Name', 
                controller: _stationCtrl, 
                prefixIcon: const Icon(Icons.local_police_outlined, size: 20), 
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              
              const SizedBox(height: 24),
              
              // Information Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh, 
                  borderRadius: BorderRadius.circular(12), 
                  border: Border.all(color: AppColors.outlineVariant.withAlpha(120)),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Your application will undergo department verification before access is granted.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.5))),
                ]),
              ),
              const SizedBox(height: 24),
              
              // Submit Button
              GuardianButton(
                label: 'Submit Verification',
                isLoading: _loading,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                onPressed: _handleRegistration,
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ),
    );
  }
}