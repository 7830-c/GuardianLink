import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_button.dart';
import '../../widgets/guardian_text_field.dart';
import '../../services/auth_service.dart'; // 1. AuthService import kiya

class VolunteerRegistrationScreen extends StatefulWidget {
  const VolunteerRegistrationScreen({super.key});
  @override
  State<VolunteerRegistrationScreen> createState() => _VolunteerRegistrationScreenState();
}

class _VolunteerRegistrationScreenState extends State<VolunteerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController(); // 2. Password controller add kiya
  
  final _auth = AuthService(); // 3. AuthService ka instance
  
  bool _loading = false;
  String _selectedSkill = 'First Aid';
  final _skills = ['First Aid', 'Security', 'Medical', 'Counseling', 'Search & Rescue'];

  @override
  void dispose() { 
    _nameCtrl.dispose(); 
    _emailCtrl.dispose(); 
    _phoneCtrl.dispose(); 
    _areaCtrl.dispose(); 
    _idCtrl.dispose(); 
    _passwordCtrl.dispose();
    super.dispose(); 
  }

  // 4. Registration Function banaya
  Future<void> _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      
      try {
        await _auth.register(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
          role: 'volunteer',
          additionalData: {
            'name': _nameCtrl.text.trim(),
            'phone': _phoneCtrl.text.trim(),
            'area': _areaCtrl.text.trim(),
            'govtId': _idCtrl.text.trim(),
            'skill': _selectedSkill,
            'isVerified': false, // Admin review ke liye
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
              
              GuardianTextField(label: 'Email Address', controller: _emailCtrl, keyboardType: TextInputType.emailAddress, prefixIcon: const Icon(Icons.email_outlined, size: 20), validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 16),

              // 5. Password Field add ki
              GuardianTextField(label: 'Password', controller: _passwordCtrl, isPassword: true, prefixIcon: const Icon(Icons.lock_outline, size: 20), validator: (v) => (v?.length ?? 0) < 6 ? 'Min 6 characters required' : null),
              const SizedBox(height: 16),
              
              GuardianTextField(label: 'Phone Number', controller: _phoneCtrl, keyboardType: TextInputType.phone, prefixIcon: const Icon(Icons.phone_outlined, size: 20), validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 16),
              
              GuardianTextField(label: 'Service Area / Locality', controller: _areaCtrl, prefixIcon: const Icon(Icons.location_city_outlined, size: 20), validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 16),
              
              GuardianTextField(label: 'Government ID Number', controller: _idCtrl, prefixIcon: const Icon(Icons.badge_outlined, size: 20), validator: (v) => v?.isEmpty == true ? 'Required for verification' : null),
              
              const SizedBox(height: 20),
              Text('Primary Skill', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _skills.map((s) => GestureDetector(
                  onTap: () => setState(() => _selectedSkill = s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: s == _selectedSkill ? AppColors.secondaryContainer.withAlpha(100) : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: s == _selectedSkill ? AppColors.secondary : AppColors.outlineVariant.withAlpha(120)),
                    ),
                    child: Text(s, style: GoogleFonts.inter(fontSize: 13, color: s == _selectedSkill ? AppColors.secondary : AppColors.onSurfaceVariant, fontWeight: s == _selectedSkill ? FontWeight.w600 : FontWeight.w400)),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 24),
              
              // Info box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.outlineVariant.withAlpha(120))),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Your application will be reviewed within 24–48 hours. Background verification is required before approval.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.5))),
                ]),
              ),
              const SizedBox(height: 24),
              
              GuardianButton(
                label: 'Submit Application',
                isLoading: _loading,
                backgroundColor: AppColors.secondaryContainer,
                foregroundColor: AppColors.onSecondaryContainer,
                onPressed: _handleRegistration, // 6. Function connect kiya
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ),
    );
  }
}