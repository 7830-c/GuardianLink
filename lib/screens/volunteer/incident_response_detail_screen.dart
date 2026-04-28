import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;
import '../../theme/app_colors.dart';
import '../../widgets/guardian_button.dart';
import '../../services/firestore_service.dart';

class IncidentResponseDetailScreen extends StatefulWidget {
  final String alertId;
  const IncidentResponseDetailScreen({super.key, required this.alertId});
  @override
  State<IncidentResponseDetailScreen> createState() => _IncidentResponseDetailScreenState();
}

class _IncidentResponseDetailScreenState extends State<IncidentResponseDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  BitmapDescriptor? _childMarker;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _generateMarkerIcon(String name) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double width = 100.0;
    const double height = 35.0;
    
    final Paint paint = Paint()..color = Colors.red;
    final RRect rRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, width, height - 10),
      const Radius.circular(10),
    );
    canvas.drawRRect(rRect, paint);
    
    final Path path = Path();
    path.moveTo(width / 2 - 6, height - 10);
    path.lineTo(width / 2 + 6, height - 10);
    path.lineTo(width / 2, height);
    path.close();
    canvas.drawPath(path, paint);

    final TextPainter textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    textPainter.text = TextSpan(
      text: name,
      style: const TextStyle(fontSize: 11.0, color: Colors.white, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset((width - textPainter.width) / 2, (height - 10 - textPainter.height) / 2));

    final ui.Image image = await pictureRecorder.endRecording().toImage(width.toInt(), height.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data != null && mounted) {
      setState(() {
        _childMarker = BitmapDescriptor.bytes(data.buffer.asUint8List());
      });
    }
  }

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

            if (_childMarker == null) {
              _generateMarkerIcon(childName);
            }

            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                title: Text('Emergency: $childName'),
                leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Status Banner
                  _buildStatusBanner(alertData['status']),
                  const SizedBox(height: 16),
                  
                  // Real-time Map
                  _buildMap(liveLoc ?? alertLoc, childName),
                  const SizedBox(height: 16),
                  
                  // Info Card
                  _buildInfoCard(childName, childData, alertData),
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  if (alertData['status'] == 'pending') ...[
                    GuardianButton(
                      label: 'Acknowledge & Respond',
                      icon: Icons.check,
                      isLoading: _isLoading,
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      onPressed: () => _handleAcknowledge(),
                    ),
                    const SizedBox(height: 12),
                    GuardianButton(
                      label: 'Pass Alert',
                      outlined: true,
                      onPressed: () => context.pop(),
                    ),
                  ] else if (alertData['acknowledgedBy']?.contains(FirebaseAuth.instance.currentUser?.uid)) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.green.withAlpha(30), borderRadius: BorderRadius.circular(12)),
                      child: const Row(children: [
                        Icon(Icons.directions_run, color: Colors.green),
                        SizedBox(width: 12),
                        Text('You are responding to this alert', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 24),
                ]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusBanner(String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: status == 'pending' ? [const Color(0xFF7F1D1D), const Color(0xFF991B1B)] : [Colors.green, Colors.green.shade800]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        const Icon(Icons.sos, color: Colors.white, size: 28),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('SOS ALERT', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(status == 'pending' ? 'Waiting for response' : 'Assistance en route', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
        ])),
      ]),
    );
  }

  Widget _buildMap(GeoPoint loc, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.outlineVariant.withAlpha(100), width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(50), blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: LatLng(loc.latitude, loc.longitude), zoom: 18),
                markers: {
                  Marker(
                    markerId: const MarkerId('child'),
                    position: LatLng(loc.latitude, loc.longitude),
                    icon: _childMarker ?? BitmapDescriptor.defaultMarker,
                  ),
                },
                myLocationEnabled: true,
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: FloatingActionButton.small(
                onPressed: () {
                  final url = 'https://www.google.com/maps/dir/?api=1&destination=${loc.latitude},${loc.longitude}';
                  launchUrl(Uri.parse(url));
                },
                backgroundColor: AppColors.secondary,
                child: const Icon(Icons.directions, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String name, Map<String, dynamic>? child, Map<String, dynamic> alert) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Details', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primary)),
        const Divider(),
        _infoRow('Subject', name),
        _infoRow('Phone', child?['phone'] ?? "N/A"),
        _infoRow('Alert Time', (alert['timestamp'] as Timestamp).toDate().toString()),
      ]),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.outline))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
    ]),
  );

  Future<void> _handleAcknowledge() async {
    setState(() => _isLoading = true);
    try {
      await _firestoreService.acknowledgeAlert(widget.alertId, FirebaseAuth.instance.currentUser!.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Acknowledge successful! Go help them.")));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
