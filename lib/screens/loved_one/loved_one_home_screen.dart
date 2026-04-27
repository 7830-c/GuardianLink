import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';

class LovedOneHomeScreen extends StatefulWidget {
  const LovedOneHomeScreen({super.key});
  @override
  State<LovedOneHomeScreen> createState() => _LovedOneHomeScreenState();
}

class _LovedOneHomeScreenState extends State<LovedOneHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  late AnimationController _holdController;
  int _selectedIndex = 0;
  String userName = "User";

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    
    _holdController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _holdController.reset();
        _handleSOSAction();
      }
    });
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() => userName = doc.data()?['name'] ?? "User");
      }
    }
  }

  Future<void> _handleSOSAction() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Please turn on GPS.';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'Permission denied.';
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('alerts').add({
        'senderId': user?.uid,
        'senderName': userName,
        'location': GeoPoint(position.latitude, position.longitude),
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'urgent',
      });

      if (!mounted) return;
      context.go('/loved-one/sos-progress');
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void dispose() { 
    _pulseController.dispose(); 
    _holdController.dispose();
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: [
                _buildStatusBanner(),
                const SizedBox(height: 50),
                _buildSOSButton(),
                const SizedBox(height: 12),
                Text('Hold for 3 seconds to send emergency alert', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.all(20),
    child: Row(children: [
      const CircleAvatar(child: Icon(Icons.person)),
      const SizedBox(width: 12),
      Text('Hello, $userName 👋', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
    ]),
  );

  Widget _buildStatusBanner() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(16)),
    child: Row(children: [
      const Icon(Icons.location_on, color: AppColors.tertiary, size: 16),
      const SizedBox(width: 10),
      Text('Location Sharing: Active', style: GoogleFonts.inter(color: AppColors.tertiary)),
    ]),
  );

  Widget _buildSOSButton() => GestureDetector(
    onLongPressStart: (_) => _holdController.forward(),
    onLongPressEnd: (_) {
      if (_holdController.status != AnimationStatus.completed) _holdController.reverse();
    },
    child: Stack(alignment: Alignment.center, children: [
      // Outer Pulse Rings
      AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          return Stack(alignment: Alignment.center, children: [
            ...List.generate(3, (i) => Container(
              width: 200.0 + (i * 30), height: 200.0 + (i * 30),
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.sosRed.withOpacity(0.1)),
            )),
          ]);
        },
      ),
      // Progress Indicator (The fix is here)
      AnimatedBuilder(
        animation: _holdController,
        builder: (context, child) {
          return SizedBox(
            width: 210, height: 210,
            child: CircularProgressIndicator(
              value: _holdController.value,
              strokeWidth: 8,
              color: Colors.white,
              backgroundColor: Colors.transparent,
            ),
          );
        },
      ),
      // Inner SOS Button
      AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnim.value,
            child: Container(
              width: 180, height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [Color(0xFFDC2626), Color(0xFF9B1C1C)]),
              ),
              child: Center(
                child: Text('SOS', style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ),
          );
        },
      ),
    ]),
  );
}