import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_button.dart';
import '../../widgets/guardian_map_view.dart';

class IncidentResponseDetailScreen extends StatefulWidget {
  const IncidentResponseDetailScreen({super.key});
  @override
  State<IncidentResponseDetailScreen> createState() => _IncidentResponseDetailScreenState();
}

class _IncidentResponseDetailScreenState extends State<IncidentResponseDetailScreen> {
  final bool _responding = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Incident Detail'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Alert type badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF7F1D1D), Color(0xFF991B1B)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.sos, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('SOS ALERT — GL-001', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('Reported: Today at 3:42 PM', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                child: Text('ACTIVE', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          // Real Google Map
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh, 
                borderRadius: BorderRadius.circular(24), 
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(children: [
                  GuardianMapView(
                    initialPosition: const LatLng(28.6304, 77.2177),
                    zoom: 15.0,
                    markers: {
                      Marker(markerId: const MarkerId('incident'), position: const LatLng(28.6304, 77.2177), infoWindow: const InfoWindow(title: 'Incident Location')),
                    },
                  ),
                  // Location overlay (Optional)
                IgnorePointer(
                  child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.5), blurRadius: 12)]),
                      child: const Icon(Icons.person_pin, color: Colors.white, size: 28),
                    ),
                  ])),
                ),
                Positioned(top: 10, right: 10, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.surfaceContainer.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.directions_walk, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('0.8 km • ~10 min', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurface)),
                  ]),
                )),
              ]),
            ),
          ),
          ),
          const SizedBox(height: 16),
          // Person info
          const _InfoCard(title: 'Person in Need', children: [
            _Row('Name', 'Arjun Sharma'),
            _Row('Age', '14 years'),
            _Row('Contact', '+91 98765 43210'),
            _Row('Medical Info', 'No known allergies'),
            _Row('Guardian', 'Raj Sharma (Father)'),
          ]),
          const SizedBox(height: 12),
          const _InfoCard(title: 'Situation Details', children: [
            _Row('Alert Type', 'Manual SOS Trigger'),
            _Row('Battery', '67% at alert time'),
            _Row('Network', '4G LTE'),
            _Row('Nearby Responders', '3 notified'),
          ]),
          const SizedBox(height: 24),
          // Action buttons
          if (!_responding) ...[
            GuardianButton(
              label: 'Accept & Respond',
              icon: Icons.directions_run,
              backgroundColor: AppColors.secondaryContainer,
              foregroundColor: Colors.white,
              onPressed: () => context.go('/volunteer/incident-acknowledged'),
            ),
            const SizedBox(height: 12),
            GuardianButton(label: 'Cannot Respond', outlined: true, onPressed: () => context.pop()),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.secondaryContainer.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4))),
              child: Row(children: [
                const Icon(Icons.directions_run, color: AppColors.secondary),
                const SizedBox(width: 10),
                Expanded(child: Text('You are responding to this alert', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.secondary))),
              ]),
            ),
            const SizedBox(height: 12),
            GuardianButton(
              label: 'Mark Incident as Resolved',
              icon: Icons.check_circle_outline,
              onPressed: () => context.go('/volunteer/response-confirmed'),
            ),
            const SizedBox(height: 12),
            GuardianButton(label: 'Call Police (100)', outlined: true, icon: Icons.local_police, foregroundColor: AppColors.secondary, onPressed: () {}),
          ],
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoCard({required this.title, required this.children});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
      const SizedBox(height: 12),
      ...children,
    ]),
  );
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      SizedBox(width: 120, child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant))),
      Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurface))),
    ]),
  );
}

