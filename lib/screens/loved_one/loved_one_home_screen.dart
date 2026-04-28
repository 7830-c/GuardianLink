import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import 'loved_one_profile_screen.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../../services/firestore_service.dart';

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
  String userName = "User";
  String _address = "Fetching location...";
  String _guardianNames = "Loading Guardians...";
  String _guardianPhone = "";
  int _selectedIndex = 0;
  Timer? _locationTimer;
  final FirestoreService _firestoreService = FirestoreService();

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
    
    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _updateCurrentLocation();
    });
    _updateCurrentLocation();
  }

  Future<void> _updateCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty && mounted) {
          Placemark place = placemarks.first;
          setState(() => _address = "${place.name}, ${place.locality}");
        }
      } catch (e) {
        if (mounted) setState(() => _address = "Location Active");
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('lovedOne')
            .doc(user.uid)
            .update({
          'location': GeoPoint(position.latitude, position.longitude),
          'lastLocationUpdate': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint("Location update failed: $e");
    }
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('lovedOne').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          userName = doc.data()?['name'] ?? "User";
        });
        
        final List<dynamic> gIds = doc.data()?['guardianIds'] ?? [];
        if (gIds.isNotEmpty) {
          List<String> names = [];
          String firstPhone = "";
          for (int i = 0; i < gIds.length; i++) {
            final gDoc = await FirebaseFirestore.instance.collection('guardian').doc(gIds[i]).get();
            if (gDoc.exists) {
              names.add(gDoc.data()?['name'] ?? "Guardian");
              if (i == 0) firstPhone = gDoc.data()?['phone'] ?? "";
            }
          }
          if (mounted) {
            setState(() {
              _guardianNames = names.join(", ");
              _guardianPhone = firstPhone;
            });
          }
        } else {
          if (mounted) setState(() => _guardianNames = "No Guardians Linked");
        }
      }
    }
  }

  Future<void> _handleSOSAction() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SENDING SOS... PLEASE STAY CALM'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        )
      );
    }
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
      if (user == null) throw 'User not authenticated';

      if (!mounted) return;
      context.go('/loved-one/sos-progress');
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void dispose() { 
    _pulseController.dispose(); 
    _holdController.dispose();
    _locationTimer?.cancel();
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeContent(),
      _buildAlertHistory(),
      const LovedOneProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.sosRed,
        unselectedItemColor: AppColors.outline,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeContent() => Column(children: [
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
  ]);

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 2),
        ),
        child: const CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.surfaceContainerHigh,
          child: Icon(Icons.person, color: AppColors.primary),
        ),
      ),
      const SizedBox(width: 14),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back,', style: GoogleFonts.inter(fontSize: 12, color: AppColors.outline)),
          Text(userName, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
        ],
      ),
      const Spacer(),
      // Live SOS status chip — streams user's own alerts from Firestore
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseAuth.instance.currentUser == null
            ? const Stream.empty()
            : FirebaseFirestore.instance
                .collection('alerts')
                .where('lovedOneId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .where('status', whereIn: ['pending', 'acknowledged'])
                .snapshots(),
        builder: (context, snap) {
          final hasSos = (snap.data?.docs ?? []).isNotEmpty;
          if (hasSos) {
            return AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Transform.scale(
                scale: _pulseAnim.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red, width: 1.5),
                    boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.35), blurRadius: 10, spreadRadius: 1)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text('SOS ACTIVE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.red, letterSpacing: 0.5)),
                    ],
                  ),
                ),
              ),
            );
          }
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text('SAFE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.green)),
              ],
            ),
          );
        },
      ),
    ]),
  );

  Widget _buildStatusBanner() => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: _PremiumStatCard(
              icon: Icons.location_on_rounded,
              title: 'Current Location',
              value: _address,
              color: AppColors.tertiary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _PremiumStatCard(
              icon: Icons.shield_rounded,
              title: 'Safety Net',
              value: _guardianNames.split(',').length.toString() + ' Guardians',
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      _buildQuickActions(),
    ],
  );

  Widget _buildQuickActions() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('QUICK HELP', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.outline, letterSpacing: 1.5)),
      const SizedBox(height: 12),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _QuickActionCard(
              icon: Icons.phone, 
              label: 'Call Guardian', 
              color: AppColors.primary,
              onTap: () {
                if (_guardianPhone.isNotEmpty) {
                  launchUrl(Uri.parse('tel:$_guardianPhone'));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No guardian phone number linked')));
                }
              },
            ),
            _QuickActionCard(
              icon: Icons.local_police, 
              label: 'Alert Police', 
              color: Colors.blue,
              onTap: () => launchUrl(Uri.parse('tel:100')),
            ),
            _QuickActionCard(
              icon: Icons.medical_services, 
              label: 'Medical', 
              color: Colors.orange,
              onTap: () => launchUrl(Uri.parse('tel:102')),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildSOSButton() => GestureDetector(
    onTapDown: (_) => _holdController.forward(),
    onTapUp: (_) {
      if (_holdController.status != AnimationStatus.completed) _holdController.reverse();
    },
    onTapCancel: () {
      if (_holdController.status != AnimationStatus.completed) _holdController.reverse();
    },
    child: Stack(alignment: Alignment.center, children: [
      AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          return Stack(alignment: Alignment.center, children: [
            ...List.generate(3, (i) => Container(
              width: 200.0 + (i * 30), height: 200.0 + (i * 30),
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.sosRed.withValues(alpha: 0.1)),
            )),
          ]);
        },
      ),
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

  Widget _buildAlertHistory() {
    final user = FirebaseAuth.instance.currentUser;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Emergency Alert History', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('alerts')
                .where('lovedOneId', isEqualTo: user?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs.toList();
              
              // Sort in-memory to avoid index requirement
              docs.sort((a, b) {
                final aTime = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                final bTime = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                if (aTime == null || bTime == null) return 0;
                return bTime.compareTo(aTime);
              });

              if (docs.isEmpty) return Center(child: Text('No alert history found', style: TextStyle(color: AppColors.outline)));
              
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final data = docs[i].data() as Map<String, dynamic>;
                  final isResolved = data['status'] == 'resolved';
                  final time = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isResolved ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(isResolved ? Icons.check_circle : Icons.warning, color: isResolved ? Colors.green : Colors.red),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(isResolved ? 'Resolved SOS' : 'Active/Pending SOS', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                              Text(DateFormat('MMM dd, hh:mm a').format(time), style: GoogleFonts.inter(fontSize: 12, color: AppColors.outline)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _confirmDeleteAlert(docs[i].id, isResolved),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDeleteAlert(String alertId, bool isResolved) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alert History?'),
        content: const Text('This will permanently remove this record from history. If the alert is active, it will be marked as resolved.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      if (!isResolved) {
        await FirebaseFirestore.instance.collection('alerts').doc(alertId).update({'status': 'resolved'});
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('lovedOne').doc(user.uid).update({'isEmergency': false});
        }
      }
      await FirebaseFirestore.instance.collection('alerts').doc(alertId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alert record deleted')));
      }
    }
  }
}

class _PremiumStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _PremiumStatCard({required this.icon, required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionCard({required this.icon, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    ),
  );
}
}