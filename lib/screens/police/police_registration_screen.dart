import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_button.dart';
import '../../widgets/guardian_text_field.dart';
import '../../services/auth_service.dart';

class PoliceRegistrationScreen extends StatefulWidget {
  const PoliceRegistrationScreen({super.key});
  @override
  State<PoliceRegistrationScreen> createState() => _PoliceRegistrationScreenState();
}

class _PoliceRegistrationScreenState extends State<PoliceRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _badgeCtrl = TextEditingController();
  final _stationCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  
  final _auth = AuthService();
  bool _loading = false;

  @override
  void dispose() { 
    _nameCtrl.dispose(); 
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _badgeCtrl.dispose(); 
    _stationCtrl.dispose(); 
    _cityCtrl.dispose(); 
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
          role: 'police',
          lat: pos?.latitude,
          lng: pos?.longitude,
          additionalData: {
            'name': _nameCtrl.text.trim(),
            'Id_no': _badgeCtrl.text.trim(), // Renamed for consistency with request
            'station': _stationCtrl.text.trim(),
            'city': _cityCtrl.text.trim(),
            'isVerified': false,
          },
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Waiting for approval.')),
        );
        context.go('/police/login');
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
              IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.go('/police/login')),
              const SizedBox(height: 24),
              Text('Officer Registration', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              const SizedBox(height: 8),
              Text('Register for access to GuardianLink dispatch', style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 32),
              
              GuardianTextField(label: 'Full Name', controller: _nameCtrl, prefixIcon: const Icon(Icons.person_outline, size: 20), validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 16),

              GuardianTextField(label: 'Phone Number', controller: _phoneCtrl, keyboardType: TextInputType.phone, prefixIcon: const Icon(Icons.phone_outlined, size: 20), validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 16),

              GuardianTextField(label: 'Password', controller: _passwordCtrl, isPassword: true, prefixIcon: const Icon(Icons.lock_outline, size: 20), validator: (v) => (v?.length ?? 0) < 6 ? 'Min 6 characters' : null),
              const SizedBox(height: 16),

              GuardianTextField(label: 'Police ID / Badge Number', controller: _badgeCtrl, prefixIcon: const Icon(Icons.badge_outlined, size: 20), validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 16),

              GuardianTextField(label: 'Station Name', controller: _stationCtrl, prefixIcon: const Icon(Icons.local_police_outlined, size: 20), validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 16),

              GuardianTextField(label: 'City', controller: _cityCtrl, prefixIcon: const Icon(Icons.location_city_outlined, size: 20), validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 32),
              
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