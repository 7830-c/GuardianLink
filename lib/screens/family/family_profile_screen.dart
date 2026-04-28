import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';

class FamilyProfileScreen extends StatefulWidget {
  const FamilyProfileScreen({super.key});

  @override
  State<FamilyProfileScreen> createState() => _FamilyProfileScreenState();
}

class _FamilyProfileScreenState extends State<FamilyProfileScreen> {
  final _auth = AuthService();
  final _user = FirebaseAuth.instance.currentUser;
  
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (_user == null) return;
    try {
      // Find the guardian document by phone or UID
      // Since we store by UID now (after my recent update)
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('guardian')
          .doc(_user!.uid)
          .get();
      
      if (mounted) {
        setState(() {
          _userData = doc.data() as Map<String, dynamic>?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primaryContainer,
            child: Text(
              (_userData?['name'] ?? 'U')[0].toUpperCase(),
              style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.onPrimaryContainer),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _userData?['name'] ?? 'Guardian Name',
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.onSurface),
          ),
          Text(
            _userData?['phone'] ?? 'Phone Number',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          
          _buildInfoTile(Icons.person_outline, 'Relationship', _userData?['relationship'] ?? 'Family Head'),
          _buildInfoTile(Icons.child_care, 'Linked Loved Ones', '${(_userData?['lovedOnesIds'] as List?)?.length ?? 0} Members'),
          _buildInfoTile(Icons.verified_user_outlined, 'Role', 'Guardian / Family'),
          
          const SizedBox(height: 40),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await _auth.signOut();
                if (context.mounted) context.go('/role-selection');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
              Text(value, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
            ],
          ),
        ],
      ),
    );
  }
}
