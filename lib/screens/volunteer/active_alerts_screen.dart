import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class ActiveAlertsScreen extends StatefulWidget {
  const ActiveAlertsScreen({super.key});
  @override
  State<ActiveAlertsScreen> createState() => _ActiveAlertsScreenState();
}

class _ActiveAlertsScreenState extends State<ActiveAlertsScreen> {
  int _selectedIndex = 0;
  bool _available = true;

  static const _alerts = [
    {'id': 'GL-001', 'name': 'Arjun Sharma', 'type': 'SOS Alert', 'location': 'Connaught Place, Delhi', 'distance': '0.8 km', 'time': '2 min ago', 'urgent': true},
    {'id': 'GL-002', 'name': 'Unknown', 'type': 'Distress Signal', 'location': 'Rajiv Chowk Metro', 'distance': '1.4 km', 'time': '5 min ago', 'urgent': true},
    {'id': 'GL-003', 'name': 'Meera Patel', 'type': 'Assistance Needed', 'location': 'City Mall, Rohini', 'distance': '3.2 km', 'time': '12 min ago', 'urgent': false},
  ];

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
                Text('${_alerts.length} alerts in your area', style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondary)),
              ]),
              const Spacer(),
              // Availability toggle
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
              _StatBadge(value: '3', label: 'Active', color: AppColors.secondary),
              SizedBox(width: 12),
              _StatBadge(value: '1', label: 'Responding', color: AppColors.tertiary),
              SizedBox(width: 12),
              _StatBadge(value: '47', label: 'Total Served', color: AppColors.primary),
            ]),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _alerts.length,
              itemBuilder: (_, i) {
                final a = _alerts[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => context.push('/volunteer/incident-detail'),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: (a['urgent'] == true ? AppColors.secondary : AppColors.outlineVariant).withValues(alpha: 0.5)),
                      ),
                      child: Column(children: [
                        if (a['urgent'] == true)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer.withValues(alpha: 0.5),
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                            ),
                            child: Row(children: [
                              const Icon(Icons.priority_high, size: 14, color: AppColors.secondary),
                              const SizedBox(width: 4),
                              Text('URGENT', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondary, letterSpacing: 1)),
                            ]),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(children: [
                            Row(children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.sos, color: AppColors.secondary, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(a['type'] as String, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                                Text(a['name'] as String, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                              ])),
                              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                Text(a['distance'] as String, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                Text(a['time'] as String, style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline)),
                              ]),
                            ]),
                            const SizedBox(height: 12),
                            Row(children: [
                              const Icon(Icons.location_on, size: 14, color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Expanded(child: Text(a['location'] as String, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant), overflow: TextOverflow.ellipsis)),
                            ]),
                            const SizedBox(height: 12),
                            Row(children: [
                              Expanded(child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant, side: const BorderSide(color: AppColors.outlineVariant), padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                child: Text('Skip', style: GoogleFonts.inter(fontSize: 13)),
                              )),
                              const SizedBox(width: 12),
                              Expanded(flex: 2, child: ElevatedButton(
                                onPressed: () => context.push('/volunteer/incident-detail'),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryContainer, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                                child: Text('Respond Now', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                              )),
                            ]),
                          ]),
                        ),
                      ]),
                    ),
                  ),
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
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active_outlined), activeIcon: Icon(Icons.notifications_active), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.history), activeIcon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
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
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha: 0.3))),
    child: Column(children: [
      Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
      Text(label, style: GoogleFonts.inter(fontSize: 10, color: color.withValues(alpha: 0.8))),
    ]),
  ));
}
