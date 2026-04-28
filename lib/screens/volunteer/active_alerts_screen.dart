import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../../services/location_service.dart';
import '../../theme/app_colors.dart';
import 'volunteer_profile_screen.dart';

class ActiveAlertsScreen extends StatefulWidget {
  const ActiveAlertsScreen({super.key});
  @override
  State<ActiveAlertsScreen> createState() => _ActiveAlertsScreenState();
}

class _ActiveAlertsScreenState extends State<ActiveAlertsScreen> {
  bool _available = true;
  int _selectedIndex = 0;
  // Local set for instant UI feedback on skip (Firestore is the source of truth)
  final Set<String> _ignoredAlertIds = {};
  String? _currentUid;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _currentUid = FirebaseAuth.instance.currentUser?.uid;
    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (_available) {
        final pos = await LocationService.getCurrentLocation();
        final user = FirebaseAuth.instance.currentUser;
        if (pos != null && user != null) {
          await FirebaseFirestore.instance.collection('volunteers').doc(user.uid).update({
            'location': GeoPoint(pos.latitude, pos.longitude),
            'lastActive': FieldValue.serverTimestamp(),
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildAlertsContent(),
      const VolunteerProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.outline,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active_outlined), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildAlertsContent() {
    return Column(children: [
      // Header
      Padding(
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Active Alerts', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            Text('Scanning for emergencies...', style: GoogleFonts.inter(fontSize: 12, color: Colors.green)),
          ]),
          const Spacer(),
          Row(children: [
            Text(_available ? 'Available' : 'Off Duty', style: GoogleFonts.inter(fontSize: 13, color: _available ? Colors.green : AppColors.outline, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Switch(value: _available, onChanged: (v) => setState(() => _available = v)),
          ]),
        ]),
      ),

      // SOS Feed
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('alerts')
              .where('status', whereIn: ['pending', 'acknowledged'])
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final uid = _currentUid;
            final docs = snapshot.data!.docs.where((doc) {
              // Hide if locally skipped (instant feedback)
              if (_ignoredAlertIds.contains(doc.id)) return false;
              // Hide if this volunteer already skipped it (persisted in Firestore)
              if (uid != null) {
                final skipped = (doc.data() as Map<String, dynamic>)['skippedBy'];
                if (skipped is List && skipped.contains(uid)) return false;
              }
              return true;
            }).toList();

            if (docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.security, size: 60, color: AppColors.outlineVariant),
                    const SizedBox(height: 16),
                    Text('No active emergencies nearby', style: GoogleFonts.inter(color: AppColors.outline)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: docs.length,
              itemBuilder: (_, i) {
                final data = docs[i].data() as Map<String, dynamic>;
                final docId = docs[i].id;
                return _buildAlertCard(data, docId);
              },
            );
          },
        ),
      ),
    ]);
  }

  Widget _buildAlertCard(Map<String, dynamic> data, String id) {
    final bool isAcknowledged = data['status'] == 'acknowledged';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => context.push('/volunteer/incident-detail/$id'),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isAcknowledged
                  ? Colors.green.withAlpha(120)
                  : AppColors.secondary.withAlpha(50),
              width: isAcknowledged ? 1.5 : 1,
            ),
          ),
          child: Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withAlpha(20),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              ),
              child: Row(children: [
                const Icon(Icons.priority_high, size: 14, color: AppColors.secondary),
                const SizedBox(width: 4),
                Text('URGENT SOS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondary, letterSpacing: 1)),
                const Spacer(),
                if (isAcknowledged)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.withAlpha(120)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.check_circle, size: 11, color: Colors.green),
                      const SizedBox(width: 4),
                      Text('EN ROUTE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.green)),
                    ]),
                  ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.secondary.withAlpha(30), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.sos, color: AppColors.secondary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Emergency Assistance', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Someone needs help nearby', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ])),
                  const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: OutlinedButton(
                    onPressed: () => _skipAlert(id),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('SKIP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70)),
                  )),
                  const SizedBox(width: 6),
                  Expanded(child: OutlinedButton(
                    onPressed: () => context.push('/volunteer/incident-detail/$id'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white38),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('DETAILS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70)),
                  )),
                  const SizedBox(width: 6),
                  Expanded(flex: 2, child: ElevatedButton(
                    onPressed: () {
                      final GeoPoint? loc = data['location'];
                      if (loc != null) {
                        final url = 'https://www.google.com/maps/dir/?api=1&destination=${loc.latitude},${loc.longitude}';
                        launchUrl(Uri.parse(url));
                      } else {
                        context.push('/volunteer/incident-detail/$id');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: EdgeInsets.zero,
                      elevation: 8,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text('RESPOND', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
                      ],
                    ),
                  )),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  /// Hides this alert for THIS volunteer only.
  /// Other volunteers are unaffected — the alert remains in their feed.
  Future<void> _skipAlert(String alertId) async {
    // Instant local feedback so the card disappears immediately
    setState(() => _ignoredAlertIds.add(alertId));

    final uid = _currentUid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance.collection('alerts').doc(alertId).update({
        // arrayUnion is idempotent — safe to call multiple times
        'skippedBy': FieldValue.arrayUnion([uid]),
      });
    } catch (_) {
      // Firestore write failed — local hide already applied, so UX is unaffected.
      // Alert will reappear on next app launch if Firestore didn't persist.
    }
  }
}