import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_button.dart';
import '../../widgets/guardian_text_field.dart';
import '../../services/auth_service.dart'; // Import AuthService

class LovedOneRegistrationScreen extends StatefulWidget {
  const LovedOneRegistrationScreen({super.key});

  @override
  State<LovedOneRegistrationScreen> createState() => _LovedOneRegistrationScreenState();
}

class _LovedOneRegistrationScreenState extends State<LovedOneRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Input Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(); // Added email for Firebase Auth
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _guardianCodeController = TextEditingController();
  
  final _auth = AuthService(); // Initialize AuthService
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    _guardianCodeController.dispose();
    super.dispose();
  }

  // Handle registration logic
  void _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        // Registering the Loved One in Firebase
        // Note: Using the 6-digit PIN as the password
        await _auth.register(
          email: _emailController.text.trim(),
          password: _pinController.text.trim(),
          role: 'loved_one',
          additionalData: {
            'name': _nameController.text.trim(),
            'age': int.tryParse(_ageController.text.trim()) ?? 0,
            'phone': _phoneController.text.trim(),
            'guardianInviteCode': _guardianCodeController.text.trim(),
            'status': 'safe', // Default safety status
          },
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Welcome to the network.')),
        );

        // Redirect to loved one home screen
        context.go('/loved-one/home');

      } catch (e) {
        if (!mounted) return;
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
                  onPressed: () => context.go('/loved-one/login'),
                ),
                const SizedBox(height: 24),
                Text('Create Account',
                    style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                const SizedBox(height: 8),
                Text('Register for your personal safety network',
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 32),
                
                const _StepIndicator(currentStep: 1, totalSteps: 2),
                const SizedBox(height: 32),
                
                // Name Field
                GuardianTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  validator: (v) => v?.isEmpty == true ? 'Enter your name' : null,
                ),
                const SizedBox(height: 16),

                // Email Field (Required for Firebase)
                GuardianTextField(
                  label: 'Email Address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  validator: (v) => v?.isEmpty == true ? 'Email is required' : null,
                ),
                const SizedBox(height: 16),

                // Age Field
                GuardianTextField(
                  label: 'Age',
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.cake_outlined, size: 20),
                  validator: (v) => v?.isEmpty == true ? 'Enter your age' : null,
                ),
                const SizedBox(height: 16),

                // Phone Field
                GuardianTextField(
                  label: 'Phone Number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  validator: (v) => v?.isEmpty == true ? 'Enter your phone number' : null,
                ),
                const SizedBox(height: 16),

                // 6-Digit PIN as Password
                GuardianTextField(
                  label: 'Create PIN (6-digit)',
                  controller: _pinController,
                  isPassword: true,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  validator: (v) => v?.length != 6 ? 'PIN must be 6 digits' : null,
                ),
                const SizedBox(height: 16),

                // Confirm PIN
                GuardianTextField(
                  label: 'Confirm PIN',
                  controller: _confirmPinController,
                  isPassword: true,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  validator: (v) => v != _pinController.text ? 'PINs do not match' : null,
                ),
                const SizedBox(height: 24),
                
                // Link to Guardian Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryContainer.withAlpha(100)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.link, color: AppColors.primary, size: 18),
                          const SizedBox(width: 8),
                          Text('Link to Guardian',
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Ask your guardian to share their invite code',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 12),
                      GuardianTextField(
                        label: 'Guardian Invite Code',
                        controller: _guardianCodeController,
                        prefixIcon: const Icon(Icons.qr_code, size: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Register Button
                GuardianButton(
                  label: 'Create Account',
                  isLoading: _isLoading,
                  onPressed: _handleRegistration,
                  backgroundColor: AppColors.tertiaryContainer,
                  foregroundColor: AppColors.onTertiaryContainer,
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ',
                        style: GoogleFonts.inter(color: AppColors.onSurfaceVariant, fontSize: 13)),
                    GestureDetector(
                      onTap: () => context.go('/loved-one/login'),
                      child: Text('Sign In',
                          style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  const _StepIndicator({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final isActive = i < currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < totalSteps - 1 ? 8 : 0),
            decoration: BoxDecoration(
              color: isActive ? AppColors.tertiary : AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}