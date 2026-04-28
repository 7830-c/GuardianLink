import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';

class LovedOneProfileScreen extends StatefulWidget {
  const LovedOneProfileScreen({super.key});

  @override
  State<LovedOneProfileScreen> createState() => _LovedOneProfileScreenState();
}

class _LovedOneProfileScreenState extends State<LovedOneProfileScreen> {
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
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('lovedOne')
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
            backgroundColor: AppColors.sosRed.withOpacity(0.1),
            child: Text(
              (_userData?['name'] ?? 'U')[0].toUpperCase(),
              style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.sosRed),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _userData?['name'] ?? 'Loved One Name',
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.onSurface),
          ),
          Text(
            _userData?['phone'] ?? 'Phone Number',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          
          _buildInfoTile(Icons.phone_android, 'Your Phone', _userData?['phone'] ?? 'N/A'),
          _buildInfoTile(Icons.security, 'Safety Status', _userData?['status']?.toUpperCase() ?? 'SAFE'),
          
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your Guardians', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              TextButton.icon(
                onPressed: _showAddGuardianDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add New'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGuardianList(),

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
          Icon(icon, color: AppColors.sosRed, size: 22),
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

  Widget _buildGuardianList() {
    final List<dynamic> guardianIds = _userData?['guardianIds'] ?? [];
    if (guardianIds.isEmpty) {
      return Text('No guardians linked yet.', style: TextStyle(color: AppColors.outline, fontSize: 13));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('guardian')
          .where(FieldPath.documentId, whereIn: guardianIds)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final docs = snapshot.data!.docs;

        return Column(
          children: docs.map((doc) {
            final gData = doc.data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh.withAlpha(150),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const CircleAvatar(radius: 14, child: Icon(Icons.person, size: 16)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(gData['name'] ?? 'Guardian', style: const TextStyle(color: Colors.white, fontSize: 14))),
                  Text(gData['phone'] ?? '', style: TextStyle(color: AppColors.outline, fontSize: 12)),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showAddGuardianDialog() {
    final phoneController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Guardian'),
        content: TextField(
          controller: phoneController,
          decoration: const InputDecoration(
            labelText: 'Guardian Phone Number',
            hintText: 'e.g. +1234567890',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => _addGuardianByPhone(phoneController.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addGuardianByPhone(String phone) async {
    if (phone.isEmpty) return;
    Navigator.pop(context); // Close dialog
    
    setState(() => _isLoading = true);
    try {
      final query = await FirebaseFirestore.instance
          .collection('guardian')
          .where('phone', isEqualTo: phone)
          .get();

      if (query.docs.isEmpty) {
        throw 'No guardian found with this phone number.';
      }

      final guardianId = query.docs.first.id;
      final currentGuardians = List<String>.from(_userData?['guardianIds'] ?? []);
      
      if (currentGuardians.contains(guardianId)) {
        throw 'This guardian is already linked.';
      }

      currentGuardians.add(guardianId);
      await FirebaseFirestore.instance.collection('lovedOne').doc(_user!.uid).update({
        'guardianIds': currentGuardians,
      });

      await _fetchUserData(); // Refresh
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardian added successfully!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
