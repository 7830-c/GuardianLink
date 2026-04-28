import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_button.dart';
import '../../widgets/guardian_text_field.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/auth_service.dart';

class LovedOneRegistrationScreen extends StatefulWidget {
  final String? guardianPhone;
  const LovedOneRegistrationScreen({super.key, this.guardianPhone});

  @override
  State<LovedOneRegistrationScreen> createState() => _LovedOneRegistrationScreenState();
}

class _LovedOneRegistrationScreenState extends State<LovedOneRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Input Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  
  final _auth = AuthService(); 
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.guardianPhone != null) {
      _guardianPhoneController.text = widget.guardianPhone!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    _guardianPhoneController.dispose();
    super.dispose();
  }

  // Handle registration logic
  void _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final rawGuardianPhone = _guardianPhoneController.text.trim();
        final guardianPhone = rawGuardianPhone.replaceAll(RegExp(r'[^0-9]'), '');

        // 1. Check if Guardian exists in Firestore
        final guardianQuery = await FirebaseFirestore.instance
            .collection('guardian')
            .where('phone', isEqualTo: guardianPhone)
            .limit(1)
            .get();

        if (guardianQuery.docs.isEmpty) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          _showErrorDialog(
            "Guardian Not Found", 
            "The guardian phone number ($guardianPhone) is not registered. Please ask your guardian to create an account first."
          );
          return;
        }

        // 2. Get current location
        Position? position;
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 5),
          );
        } catch (e) {
          // Fallback if location fails
        }

        // 3. Register the Loved One
        await _auth.register(
          phone: _phoneController.text.trim(),
          password: _pinController.text.trim(),
          role: 'child',
          lat: position?.latitude,
          lng: position?.longitude,
          additionalData: {
            'name': _nameController.text.trim(),
            'status': 'safe',
            'parentPhone': guardianPhone, // Used for automatic linking in FirestoreService
          },
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created and linked to guardian!')),
        );

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

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.redAccent)),
        content: Text(message, style: GoogleFonts.inter(color: AppColors.onSurface)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/role-selection'); // Or directly to family registration if path known
            },
            child: const Text('Create Guardian Account'),
          ),
        ],
      ),
    );
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
                Text('Register and link to your guardian',
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 32),
                const _StepIndicator(currentStep: 1, totalSteps: 2),
                const SizedBox(height: 32),
                
                GuardianTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  validator: (v) => v?.isEmpty == true ? 'Enter your name' : null,
                ),
                const SizedBox(height: 16),

                GuardianTextField(
                  label: 'Phone Number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  validator: (v) => v?.isEmpty == true ? 'Enter your phone number' : null,
                ),
                const SizedBox(height: 16),

                GuardianTextField(
                  label: 'Guardian Phone Number',
                  controller: _guardianPhoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.family_restroom, size: 20, color: AppColors.tertiary),
                  validator: (v) => v?.isEmpty == true ? 'Guardian phone is required for safety' : null,
                ),
                const SizedBox(height: 16),

                GuardianTextField(
                  label: 'Create Password',
                  controller: _pinController,
                  isPassword: true,
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  validator: (v) => v?.isEmpty == true ? 'Enter a password' : null,
                ),
                const SizedBox(height: 16),

                GuardianTextField(
                  label: 'Confirm Password',
                  controller: _confirmPinController,
                  isPassword: true,
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  validator: (v) => v != _pinController.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 24),
                
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