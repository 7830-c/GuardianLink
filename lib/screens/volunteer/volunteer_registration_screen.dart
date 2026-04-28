import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_button.dart';
import '../../widgets/guardian_text_field.dart';
import '../../services/auth_service.dart';

class VolunteerRegistrationScreen extends StatefulWidget {
  const VolunteerRegistrationScreen({super.key});
  @override
  State<VolunteerRegistrationScreen> createState() => _VolunteerRegistrationScreenState();
}

class _VolunteerRegistrationScreenState extends State<VolunteerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  
  final _auth = AuthService();
  bool _loading = false;
  
  String _selectedRoleType = 'teacher';
  final _roleTypes = ['teacher', 'shopkeeper', 'driver'];

  @override
  void dispose() { 
    _nameCtrl.dispose(); 
    _phoneCtrl.dispose(); 
    _passwordCtrl.dispose();
    _idCtrl.dispose();
    super.dispose(); 
  }

  Future<void> _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      
      try {
        Position? pos;
        try {
          pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 5),
          );
        } catch (e) {
          // Fallback
        }

        await _auth.register(
          phone: _phoneCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
          role: 'volunteer',
          lat: pos?.latitude,
          lng: pos?.longitude,
          additionalData: {
            'name': _nameCtrl.text.trim(),
            'phone': _phoneCtrl.text.trim(),
            'roleType': _selectedRoleType,
            'Id_no': _idCtrl.text.trim(),
            'isVerified': false,
            'isAvailable': true,
          },
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application Submitted Successfully!')),
        );
        context.go('/volunteer/login');
      } catch (e) {
        if (!mounted) return;
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
              IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.go('/volunteer/login')),
              const SizedBox(height: 24),
              Text('Volunteer Application', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              const SizedBox(height: 8),
              Text('Join our trusted community responder network', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 32),
              
              GuardianTextField(label: 'Full Name', controller: _nameCtrl, prefixIcon: const Icon(Icons.person_outline, size: 20), validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 16),
              
              GuardianTextField(label: 'Phone Number', controller: _phoneCtrl, keyboardType: TextInputType.phone, prefixIcon: const Icon(Icons.phone_outlined, size: 20), validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 16),

              GuardianTextField(label: 'Password', controller: _passwordCtrl, isPassword: true, prefixIcon: const Icon(Icons.lock_outline, size: 20), validator: (v) => (v?.length ?? 0) < 6 ? 'Min 6 characters' : null),
              const SizedBox(height: 16),
              
              GuardianTextField(label: 'Government ID Number', controller: _idCtrl, prefixIcon: const Icon(Icons.badge_outlined, size: 20), validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 24),
              
              Text('Professional Role', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _roleTypes.map((r) => GestureDetector(
                  onTap: () => setState(() => _selectedRoleType = r),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: r == _selectedRoleType ? AppColors.primaryContainer.withAlpha(100) : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: r == _selectedRoleType ? AppColors.primary : AppColors.outlineVariant.withAlpha(120)),
                    ),
                    child: Text(r.toUpperCase(), style: GoogleFonts.inter(fontSize: 12, color: r == _selectedRoleType ? AppColors.primary : AppColors.onSurfaceVariant, fontWeight: r == _selectedRoleType ? FontWeight.w600 : FontWeight.w400)),
                  ),
                )).toList(),
              ),
              
              const SizedBox(height: 40),
              
              GuardianButton(
                label: 'Submit Application',
                isLoading: _loading,
                backgroundColor: AppColors.secondaryContainer,
                foregroundColor: AppColors.onSecondaryContainer,
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