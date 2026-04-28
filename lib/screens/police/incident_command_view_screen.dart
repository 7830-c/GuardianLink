import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_button.dart';
import '../../services/firestore_service.dart';

class IncidentCommandViewScreen extends StatefulWidget {
  final String alertId;
  const IncidentCommandViewScreen({super.key, required this.alertId});
  @override
  State<IncidentCommandViewScreen> createState() => _IncidentCommandViewScreenState();
}

class _IncidentCommandViewScreenState extends State<IncidentCommandViewScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  bool _isResolving = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('alerts').doc(widget.alertId).snapshots(),
      builder: (context, alertSnapshot) {
        if (!alertSnapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        
        final alertData = alertSnapshot.data!.data() as Map<String, dynamic>?;
        if (alertData == null) return const Scaffold(body: Center(child: Text("Alert not found")));

        final String childId = alertData['lovedOneId'] ?? "";
        final GeoPoint alertLoc = alertData['location'];

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('lovedOne').doc(childId).snapshots(),
          builder: (context, childSnapshot) {
            final childData = childSnapshot.data?.data() as Map<String, dynamic>?;
            final String childName = childData?['name'] ?? "Loved One";
            final GeoPoint? liveLoc = childData?['location'];

            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                title: Text('Incident GL-${widget.alertId.substring(0, 4)}'),
                leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Priority Banner
                  _buildPriorityBanner(),
                  const SizedBox(height: 16),
                  
                  // Live Map
                  _buildMap(liveLoc ?? alertLoc, childName),
                  const SizedBox(height: 16),
                  
                  // Details
                  _buildInfoBlock('Subject Details', [
                    _infoRow('Name', childName),
                    _infoRow('Phone', childData?['phone'] ?? "N/A"),
                    _infoRow('Status', alertData['status'].toString().toUpperCase()),
                  ]),
                  const SizedBox(height: 12),
                  
                  _buildInfoBlock('Response Status', [
                    _infoRow('Responders', alertData['acknowledgedBy']?.length.toString() ?? "0"),
                    _infoRow('Started At', (alertData['timestamp'] as Timestamp).toDate().toString()),
                  ]),
                  
                  const SizedBox(height: 32),
                  if (alertData['status'] == 'pending')
                    GuardianButton(
                      label: 'Acknowledge Incident', 
                      icon: Icons.local_police, 
                      isLoading: _isLoading,
                      onPressed: () => _handleAcknowledge(),
                    ),
                  const SizedBox(height: 12),
                  GuardianButton(
                    label: 'Mark as Resolved',
                    icon: Icons.check_circle_outline,
                    outlined: true,
                    isLoading: _isResolving,
                    onPressed: () => _handleResolve(),
                  ),
                ]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPriorityBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.red.withAlpha(40), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.withAlpha(120))),
      child: Row(children: [
        const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('CRITICAL PRIORITY', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.redAccent, letterSpacing: 1)),
          Text('SOS Distress Signal', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
        ])),
      ]),
    );
  }

  Widget _buildMap(GeoPoint loc, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF131B2E), 
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.outlineVariant.withAlpha(80), width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 20, offset: const Offset(0, 10))
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: LatLng(loc.latitude, loc.longitude), zoom: 15),
                markers: {
                  Marker(
                    markerId: const MarkerId('subject'),
                    position: LatLng(loc.latitude, loc.longitude),
                    infoWindow: InfoWindow(title: name),
                  ),
                },
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: FloatingActionButton.small(
                onPressed: () {
                  final url = 'https://www.google.com/maps/dir/?api=1&destination=${loc.latitude},${loc.longitude}';
                  launchUrl(Uri.parse(url));
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.directions, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBlock(String title, List<Widget> rows) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.outlineVariant.withAlpha(100))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
      const Divider(),
      ...rows,
    ]),
  );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.outline))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
    ]),
  );

  Future<void> _handleAcknowledge() async {
    setState(() => _isLoading = true);
    try {
      await _firestoreService.acknowledgeAlert(widget.alertId, FirebaseAuth.instance.currentUser!.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incident acknowledged. Units dispatched.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResolve() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2340),
        title: const Text('Mark as Resolved?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will close the incident and notify all parties. Only do this when the situation is fully under control.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirm Resolved'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _isResolving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      await FirebaseFirestore.instance.collection('alerts').doc(widget.alertId).update({
        'status': 'resolved',
        'resolvedBy': uid,
        'resolvedAt': FieldValue.serverTimestamp(),
        'resolvedByRole': 'police',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incident marked as resolved.'), backgroundColor: Colors.green),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isResolving = false);
    }
  }
}
