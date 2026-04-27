import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 1. Firestore Import
import '../../theme/app_colors.dart';

class ActiveAlertsScreen extends StatefulWidget {
  const ActiveAlertsScreen({super.key});
  @override
  State<ActiveAlertsScreen> createState() => _ActiveAlertsScreenState();
}

class _ActiveAlertsScreenState extends State<ActiveAlertsScreen> {
  int _selectedIndex = 0;
  bool _available = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
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

          // Stats bar
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              _StatBadge(value: 'Live', label: 'Feed', color: AppColors.secondary),
              SizedBox(width: 12),
              _StatBadge(value: '1', label: 'Nearby', color: AppColors.tertiary),
              SizedBox(width: 12),
              _StatBadge(value: '47', label: 'Served', color: AppColors.primary),
            ]),
          ),
          const SizedBox(height: 16),

          // 2. Real-time SOS Feed using StreamBuilder
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('alerts')
                  .where('status', isEqualTo: 'urgent')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.security, size: 60, color: AppColors.outlineVariant),
                        const SizedBox(height: 16),
                        Text('No active emergencies nearby', style: GoogleFonts.inter(color: AppColors.outline)),
                        Text('You are making the city safe!', style: GoogleFonts.inter(fontSize: 12, color: AppColors.outline)),
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
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) context.push('/volunteer/response-history');
          if (i == 2) context.push('/volunteer/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active_outlined), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> data, String id) {
    String senderName = data['senderName'] ?? "Unknown User";
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => context.push('/volunteer/incident-detail'),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
          ),
          child: Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withOpacity(0.2),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              ),
              child: Row(children: [
                const Icon(Icons.priority_high, size: 14, color: AppColors.secondary),
                const SizedBox(width: 4),
                Text('URGENT SOS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondary, letterSpacing: 1)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.sos, color: AppColors.secondary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Emergency Assistance', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                    Text('User: $senderName', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
                  ])),
                  const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  const Icon(Icons.my_location, size: 14, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Expanded(child: Text('Location Shared: Near Your Area', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant))),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant, side: const BorderSide(color: AppColors.outlineVariant), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: Text('Skip', style: GoogleFonts.inter(fontSize: 13)),
                  )),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: ElevatedButton(
                    onPressed: () => context.push('/live-tracking'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: Text('Respond Now', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                  )),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatBadge({required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))),
    child: Column(children: [
      Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
      Text(label, style: GoogleFonts.inter(fontSize: 10, color: color.withOpacity(0.8))),
    ]),
  ));
}