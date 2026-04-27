import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_map_view.dart';

class PoliceCommandCenterScreen extends StatefulWidget {
  const PoliceCommandCenterScreen({super.key});
  @override
  State<PoliceCommandCenterScreen> createState() => _PoliceCommandCenterScreenState();
}

class _PoliceCommandCenterScreenState extends State<PoliceCommandCenterScreen> {
  Set<Marker> _markers = {};

  // 1. Function to update markers on the map
  void _updateMarkersFromDocs(List<QueryDocumentSnapshot> docs) {
    Set<Marker> newMarkers = {};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final GeoPoint? loc = data['location'];

      if (loc != null) {
        newMarkers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(loc.latitude, loc.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(
              title: 'SOS: ${data['senderName'] ?? "Unknown"}',
              snippet: 'Status: ${data['status']}',
            ),
          ),
        );
      }
    }

    // Sirf tab update karein jab markers change hon (Loop se bachne ke liye)
    if (newMarkers.length != _markers.length) {
      Future.delayed(Duration.zero, () {
        if (mounted) setState(() => _markers = newMarkers);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          _buildHeader(),
          _buildLiveMap(),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              children: [
                Text('Active Incidents', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green.withAlpha(30), borderRadius: BorderRadius.circular(8)),
                  child: Text('Live Feed', style: GoogleFonts.inter(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('alerts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                // 2. Map markers ko update karna
                if (docs.isNotEmpty) {
                  _updateMarkersFromDocs(docs);
                }

                if (docs.isEmpty) {
                  return Center(child: Text('No active incidents', style: GoogleFonts.inter(color: AppColors.outline)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final docId = docs[i].id;
                    return _buildIncidentCard(data, docId);
                  },
                );
              },
            ),
          ),
        ]),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
      ),
      child: Row(children: [
        const Icon(Icons.local_police, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Command Center', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
          Text('Real-time Dispatch', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary)),
        ]),
      ]),
    );
  }

  Widget _buildLiveMap() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: const Color(0xFF131B2E), 
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.outlineVariant.withAlpha(50)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: GuardianMapView(
            initialPosition: const LatLng(28.6139, 77.2090), 
            zoom: 11.0,
            markers: _markers, // 3. Markers yahan map par dikhenge
          ),
        ),
      ),
    );
  }

  Widget _buildIncidentCard(Map<String, dynamic> data, String id) {
    bool isUrgent = data['status'] == 'urgent';
    String senderName = data['senderName'] ?? 'Unknown User';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isUrgent ? Colors.red.withAlpha(100) : AppColors.outlineVariant, width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isUrgent ? Colors.red.withAlpha(30) : AppColors.primary.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.warning_rounded, color: isUrgent ? Colors.red : AppColors.primary, size: 24),
        ),
        title: Text(senderName, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.onSurface)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 4),
          Text('Status: ${data['status']}', style: GoogleFonts.inter(fontSize: 12, color: isUrgent ? Colors.redAccent : Colors.orange, fontWeight: FontWeight.w600)),
          Text('ID: ${id.toUpperCase()}', style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline)),
        ]),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.outline),
        onTap: () {
          // Future: Navigate to detail view
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.outline,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Dispatch'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Archive'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}