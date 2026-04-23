import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_card.dart';

class ResponseHistoryScreen extends StatelessWidget {
  const ResponseHistoryScreen({super.key});

  static const _history = [
    {'id': 'GL-001', 'type': 'SOS Alert', 'person': 'Arjun Sharma', 'location': 'Connaught Place', 'date': 'Today, 3:42 PM', 'duration': '8m 34s', 'status': 'Resolved', 'points': 50},
    {'id': 'GL-098', 'type': 'Distress Signal', 'person': 'Unknown', 'location': 'Rajiv Chowk', 'date': 'Yesterday, 7:12 PM', 'duration': '12m 05s', 'status': 'Resolved', 'points': 50},
    {'id': 'GL-087', 'type': 'Geofence Breach', 'person': 'Priya Patel', 'location': 'City Mall', 'date': 'Apr 20, 2:30 PM', 'duration': '5m 22s', 'status': 'Assisted', 'points': 30},
    {'id': 'GL-072', 'type': 'SOS Alert', 'person': 'Ritu Kumar', 'location': 'Metro Station', 'date': 'Apr 18, 6:55 PM', 'duration': '15m 10s', 'status': 'Resolved', 'points': 50},
    {'id': 'GL-060', 'type': 'Medical Assist', 'person': 'Suresh Babu', 'location': 'Park, Sector 9', 'date': 'Apr 15, 11:20 AM', 'duration': '22m 30s', 'status': 'Escalated', 'points': 70},
  ];

  @override
  Widget build(BuildContext context) {
    final totalPoints = _history.fold<int>(0, (sum, h) => sum + (h['points'] as int));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Response History'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: Column(children: [
        // Summary card
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1E40AF), Color(0xFF3755C3)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Total Responses', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                Text('${_history.length}', style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Text('Community Hero 🏅', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('Impact Points', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                Text('$totalPoints', style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.amber)),
                Row(children: List.generate(5, (i) => const Icon(Icons.star, size: 14, color: Colors.amber))),
              ]),
            ]),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _history.length,
            itemBuilder: (_, i) {
              final h = _history[i];
              final statusColor = h['status'] == 'Resolved' ? Colors.green : h['status'] == 'Escalated' ? AppColors.tertiary : AppColors.primary;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(h['type'] as String, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface))),
                      StatusChip(label: h['status'] as String, color: statusColor),
                    ]),
                    const SizedBox(height: 4),
                    Text('${h['person']} • ${h['location']}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Row(children: [
                      _Tag(Icons.tag, h['id'] as String),
                      const SizedBox(width: 10),
                      _Tag(Icons.calendar_today, h['date'] as String),
                      const SizedBox(width: 10),
                      _Tag(Icons.timer_outlined, h['duration'] as String),
                      const Spacer(),
                      Row(children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text('+${h['points']} pts', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.amber)),
                      ]),
                    ]),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) context.pushReplacement('/volunteer/active-alerts');
          if (i == 2) context.pushReplacement('/volunteer/profile');
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

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Tag(this.icon, this.label);
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 11, color: AppColors.outline),
    const SizedBox(width: 3),
    Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline)),
  ]);
}
