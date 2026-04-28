import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';
import '../../services/alert_service.dart';
import '../../services/location_service.dart';
import 'package:geocoding/geocoding.dart';

class SosAlertProgressScreen extends StatefulWidget {
  const SosAlertProgressScreen({super.key});
  @override
  State<SosAlertProgressScreen> createState() => _SosAlertProgressScreenState();
}

class _SosAlertProgressScreenState extends State<SosAlertProgressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;
  int _step = 0;
  String? _alertId;
  String _address = "Capturing address...";
  StreamSubscription<Position>? _locationSubscription;
  final _alertService = AlertService();
  final Map<String, String> _responderNames = {};
  final List<String> _steps = [
    'Capturing location...',
    'Contacting guardians...',
    'Alerting nearby volunteers...',
    'Alert dispatched successfully!',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.9, end: 1.1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _runSteps();
  }

  void _runSteps() async {
    try {
      // 1. Capture Location
      if (mounted) setState(() => _step = 0);
      final pos = await LocationService.getCurrentLocation();
      if (pos == null) throw Exception("Could not determine location.");

      // 2. Contact Guardians & Nearby
      if (mounted) setState(() => _step = 1);
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in.");

      final alertId = await _alertService.triggerSosAlert(
        lovedOneId: user.uid,
        lat: pos.latitude,
        lng: pos.longitude,
      );
      
      if (mounted) {
        setState(() {
          _alertId = alertId;
          _step = 2;
        });
      }

      // Start continuous location streaming during SOS
      _locationSubscription = LocationService.getLocationStream().listen((Position position) {
        if (_alertId != null) {
          FirebaseFirestore.instance.collection('lovedOne').doc(user.uid).update({
            'location': GeoPoint(position.latitude, position.longitude),
            'lastLocationUpdate': FieldValue.serverTimestamp(),
          });
          // Also update the alert location
          FirebaseFirestore.instance.collection('alerts').doc(_alertId).update({
            'location': GeoPoint(position.latitude, position.longitude),
          });
        }
      });

      // 3. Get Address Name (Reverse Geocoding)
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty && mounted) {
          Placemark place = placemarks.first;
          setState(() => _address = "${place.name}, ${place.locality}");
        }
      } catch (e) {
        if (mounted) setState(() => _address = "Location shared");
      }

      // 4. Success
      if (mounted) setState(() => _step = 3);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SOS Failed: $e'), backgroundColor: Colors.red),
      );
      context.go('/loved-one/home');
    }
  }

  Future<void> _clearEmergencyAlert() async {
    final user = FirebaseAuth.instance.currentUser;
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
      );

      var collection = FirebaseFirestore.instance.collection('alerts');
      var snapshot = await collection
          .where('lovedOneId', isEqualTo: user?.uid)
          .where('status', whereIn: ['pending', 'acknowledged'])
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      if (user != null) {
        await FirebaseFirestore.instance.collection('lovedOne').doc(user.uid).update({
          'isEmergency': false,
        });
      }

      if (!mounted) return;
      Navigator.pop(context); 
      
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All emergency alerts cleared!'), backgroundColor: Colors.green),
      );
      context.go('/loved-one/home');
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() { 
    _ctrl.dispose(); 
    _locationSubscription?.cancel();
    super.dispose(); 
  }

  Future<void> _fetchResponderName(String uid) async {
    final collections = ['volunteers', 'police', 'guardian'];
    for (var col in collections) {
      final doc = await FirebaseFirestore.instance.collection(col).doc(uid).get();
      if (doc.exists) {
        if (mounted) {
          setState(() => _responderNames[uid] = doc.data()?['name'] ?? "Responder");
        }
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final done = _step >= _steps.length - 1;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // FIXED AnimatedBuilder HERE
              AnimatedBuilder(
                animation: _pulse,
                builder: (BuildContext context, Widget? child) {
                  return Transform.scale(
                    scale: done ? 1.0 : _pulse.value,
                    child: Container(
                      width: 160, height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: done
                            ? [const Color(0xFF16A34A), const Color(0xFF15803D)]
                            : [AppColors.sosRed, const Color(0xFF9B1C1C)]),
                        boxShadow: [BoxShadow(
                          color: (done ? Colors.green : AppColors.sosRed).withValues(alpha: 0.5),
                          blurRadius: 30, spreadRadius: 8,
                        )],
                      ),
                      child: Icon(done ? Icons.check_circle : Icons.sos,
                          color: Colors.white, size: 72),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              Text(
                done ? 'Help is on the way!' : 'Sending SOS Alert',
                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.onSurface),
              ),
              const SizedBox(height: 32),
              ...List.generate(_steps.length, (i) => _StepRow(
                label: _steps[i],
                status: i < _step ? 'done' : i == _step ? 'active' : 'pending',
              )),
              const SizedBox(height: 40),
              if (done) ...[
                StreamBuilder<DocumentSnapshot>(
                  stream: _alertId != null 
                    ? FirebaseFirestore.instance.collection('alerts').doc(_alertId).snapshots()
                    : const Stream.empty(),
                  builder: (context, snapshot) {
                    final data = snapshot.data?.data() as Map<String, dynamic>?;
                    final List<dynamic> responderIds = data?['acknowledgedBy'] ?? [];
                    
                    // Fetch names for new responders
                    for (var uid in responderIds) {
                      if (uid is String && !_responderNames.containsKey(uid)) {
                        _responderNames[uid] = "Loading...";
                        _fetchResponderName(uid);
                      }
                    }

                    final String responderText = _responderNames.values
                        .where((n) => n != "Loading...")
                        .join(", ");
                    
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Column(children: [
                        _InfoRow(
                          icon: Icons.people, 
                          label: responderIds.isEmpty 
                            ? 'Waiting for responders...' 
                            : 'Responders: ${responderText.isEmpty ? "Identifying..." : responderText}'
                        ),
                        const SizedBox(height: 8),
                        const _InfoRow(icon: Icons.family_restroom, label: 'Guardians Notified'),
                        const SizedBox(height: 8),
                        _InfoRow(icon: Icons.location_on, label: 'Location: $_address'),
                      ]),
                    );
                  }
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/loved-one/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.onPrimaryContainer,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Go to Home', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _clearEmergencyAlert,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: done ? Colors.green : AppColors.secondary),
                    foregroundColor: done ? Colors.green : AppColors.secondary,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(done ? 'Clear Alert' : 'Cancel Alert', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String label;
  final String status;
  const _StepRow({required this.label, required this.status});
  @override
  Widget build(BuildContext context) {
    Color c = status == 'done' ? Colors.green : status == 'active' ? AppColors.primary : AppColors.outline;
    IconData ic = status == 'done' ? Icons.check_circle : status == 'active' ? Icons.radio_button_checked : Icons.radio_button_unchecked;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(ic, color: c, size: 20),
        const SizedBox(width: 12),
        Text(label, style: GoogleFonts.inter(fontSize: 14, color: c)),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
    const SizedBox(width: 8),
    Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface)),
  ]);
}