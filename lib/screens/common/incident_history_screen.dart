import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_card.dart';

class IncidentHistoryScreen extends StatelessWidget {
  const IncidentHistoryScreen({super.key});

  static const _incidents = [
    {'id': 'GL-001', 'type': 'SOS Alert', 'person': 'Arjun Sharma', 'location': 'Connaught Place', 'date': 'Today, 3:42 PM', 'responders': 3, 'status': 'Resolved'},
    {'id': 'GL-098', 'type': 'Distress Signal', 'person': 'Unknown', 'location': 'Rajiv Chowk', 'date': 'Yesterday, 7:12 PM', 'responders': 1, 'status': 'Resolved'},
    {'id': 'GL-087', 'type': 'Geofence Breach', 'person': 'Priya Patel', 'location': 'City Mall', 'date': 'Apr 20, 2:30 PM', 'responders': 2, 'status': 'Dismissed'},
    {'id': 'GL-072', 'type': 'SOS Alert', 'person': 'Ritu Kumar', 'location': 'Metro Station', 'date': 'Apr 18, 6:55 PM', 'responders': 2, 'status': 'Resolved'},
    {'id': 'GL-060', 'type': 'Medical Assist', 'person': 'Suresh Babu', 'location': 'Park, Sector 9', 'date': 'Apr 15, 11:20 AM', 'responders': 4, 'status': 'Escalated'},
    {'id': 'GL-045', 'type': 'SOS Alert', 'person': 'Meena Devi', 'location': 'Bus Stop, Rohini', 'date': 'Apr 12, 8:05 PM', 'responders': 1, 'status': 'Resolved'},
  ];

  Color _statusColor(String s) => s == 'Resolved' ? Colors.green : s == 'Escalated' ? AppColors.tertiary : AppColors.outline;
  IconData _typeIcon(String t) => t == 'SOS Alert' ? Icons.sos : t == 'Medical Assist' ? Icons.medical_services_outlined : t == 'Geofence Breach' ? Icons.location_off : Icons.warning_amber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Incident History'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [IconButton(icon: const Icon(Icons.download_outlined), onPressed: () {})],
      ),
      body: Column(children: [
        // Summary banner
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            _SumCard('6', 'Total', AppColors.primary),
            SizedBox(width: 8),
            _SumCard('4', 'Resolved', Colors.green),
            SizedBox(width: 8),
            _SumCard('1', 'Escalated', AppColors.tertiary),
            SizedBox(width: 8),
            _SumCard('1', 'Dismissed', AppColors.outline),
          ]),
        ),
        // Filter row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(children: ['All', 'SOS', 'Medical', 'Geofence'].map((f) {
            final active = f == 'All';
            return Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: active ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(f, style: GoogleFonts.inter(fontSize: 13, color: active ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant, fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
            );
          }).toList()),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _incidents.length,
            itemBuilder: (_, i) {
              final inc = _incidents[i];
              final sc = _statusColor(inc['status'] as String);
              final ic = _typeIcon(inc['type'] as String);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                        child: Icon(ic, size: 18, color: AppColors.secondary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(inc['type'] as String, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                        Text(inc['person'] as String, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                      ])),
                      StatusChip(label: inc['status'] as String, color: sc),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.location_on, size: 12, color: AppColors.outline),
                      const SizedBox(width: 4),
                      Text(inc['location'] as String, style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline)),
                      const Spacer(),
                      const Icon(Icons.people, size: 12, color: AppColors.outline),
                      const SizedBox(width: 4),
                      Text('${inc['responders']} responded', style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline)),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      Text(inc['id'] as String, style: GoogleFonts.inter(fontSize: 11, color: AppColors.primaryContainer, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text(inc['date'] as String, style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline)),
                    ]),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _SumCard extends StatelessWidget {
  final String value, label;
  final Color color;
  const _SumCard(this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha: 0.3))),
    child: Column(children: [
      Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
      Text(label, style: GoogleFonts.inter(fontSize: 9, color: color.withValues(alpha: 0.8))),
    ]),
  ));
}
