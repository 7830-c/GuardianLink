import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';

class FamilyDashboardScreen extends StatefulWidget {
  const FamilyDashboardScreen({super.key});
  @override
  State<FamilyDashboardScreen> createState() => _FamilyDashboardScreenState();
}

class _FamilyDashboardScreenState extends State<FamilyDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('alerts')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            // Loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final alertDocs = snapshot.data?.docs ?? [];
            final activeAlerts = alertDocs.where((doc) => doc['status'] == 'urgent').toList();
            final bool hasAlert = activeAlerts.isNotEmpty;

            return Column(children: [
              // 1. Header
              _buildHeader(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. Stats Overview 
                      _buildStatOverview(activeAlerts.length),
                      
                      const SizedBox(height: 24),

                      // 3. EMERGENCY BANNER 
                      if (hasAlert)
                        _buildEmergencyBanner(activeAlerts.first['senderName'] ?? "Hello"),

                      const SizedBox(height: 24),
                      Text('Family Members', 
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                      const SizedBox(height: 12),

                      // 4. DYNAMIC MEMBER LIST
                      ...activeAlerts.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return _buildMemberCard(data['senderName'] ?? "Hello", true);
                      }),
                      
                      _buildMemberCard("Priya", false),
                      _buildMemberCard("Meera", false),

                      const SizedBox(height: 24),
                      Text('Quick Actions', 
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                      const SizedBox(height: 12),
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ]);
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- UI WIDGETS ---

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.all(20),
    child: Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Family Dashboard', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
        Text('Monitoring loved ones', style: GoogleFonts.inter(fontSize: 12, color: AppColors.tertiary)),
      ]),
      const Spacer(),
      const Icon(Icons.notifications_outlined, color: AppColors.onSurface),
    ]),
  );

  Widget _buildStatOverview(int alertCount) => Row(children: [
    Expanded(child: _StatCard(value: '3', label: 'Members', icon: Icons.people, color: AppColors.primary)),
    const SizedBox(width: 12),
    Expanded(child: _StatCard(value: 'Active', label: 'Guardian', icon: Icons.security, color: Colors.green)),
    const SizedBox(width: 12),
    Expanded(
      child: _StatCard(
        value: '$alertCount', 
        label: 'Alerts', 
        icon: Icons.warning, 
        color: alertCount > 0 ? Colors.red : AppColors.outline
      ),
    ),
  ]);

  Widget _buildEmergencyBanner(String name) => Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.red.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.red, width: 2),
    ),
    child: Row(children: [
      const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('EMERGENCY ALERT', style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
        Text('$name needs help!', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
      ])),
      ElevatedButton(
        onPressed: () => context.push('/live-tracking'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
        child: const Text('TRACK'),
      ),
    ]),
  );

  Widget _buildMemberCard(String name, bool isUrgent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUrgent ? Colors.red.withOpacity(0.1) : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isUrgent ? Colors.red : AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(children: [
        CircleAvatar(
          backgroundColor: isUrgent ? Colors.red : AppColors.primary.withOpacity(0.2),
          child: Text(name[0], 
            style: TextStyle(color: isUrgent ? Colors.white : AppColors.primary, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.onSurface)),
          Text(isUrgent ? "EMERGENCY" : "Safe", 
            style: GoogleFonts.inter(fontSize: 12, color: isUrgent ? Colors.red : Colors.green, fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal)),
        ])),
        Icon(isUrgent ? Icons.warning : Icons.check_circle, color: isUrgent ? Colors.red : Colors.green, size: 20),
      ]),
    );
  }

  Widget _buildQuickActions() => Row(children: [
    Expanded(child: _ActionBtn(icon: Icons.map, label: 'Live Map', color: AppColors.primary, onTap: () => context.push('/live-tracking'))),
    const SizedBox(width: 12),
    Expanded(child: _ActionBtn(icon: Icons.history, label: 'History', color: AppColors.tertiary, onTap: () {})),
    const SizedBox(width: 12),
    Expanded(child: _ActionBtn(icon: Icons.person_add, label: 'Invite', color: AppColors.onSurfaceVariant, onTap: () {})),
  ]);

  Widget _buildBottomNav() => BottomNavigationBar(
    currentIndex: _selectedIndex,
    type: BottomNavigationBarType.fixed,
    backgroundColor: AppColors.background,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.outline,
    onTap: (i) => setState(() => _selectedIndex = i),
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Tracking'),
      BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ],
  );
}

// --- HELPER CLASSES ---

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatCard({required this.value, required this.label, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 6),
      Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
      Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline)),
    ]),
  );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(label, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurface)),
      ]),
    ),
  );
}