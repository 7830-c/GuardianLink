import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui' as ui;
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import 'officer_profile_screen.dart';

class PoliceCommandCenterScreen extends StatefulWidget {
  const PoliceCommandCenterScreen({super.key});
  @override
  State<PoliceCommandCenterScreen> createState() => _PoliceCommandCenterScreenState();
}

class _PoliceCommandCenterScreenState extends State<PoliceCommandCenterScreen> {
  int _selectedIndex = 0;
  GoogleMapController? _mapController;
  LatLng? _focusLocation;
  final Map<String, BitmapDescriptor> _customMarkers = {};
  final Set<Marker> _markers = {};
  final Set<String> _ignoredAlertIds = {};
  
  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _updateMarkersFromDocs(List<QueryDocumentSnapshot> docs) async {
    Set<Marker> newMarkers = {};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final GeoPoint? loc = data['location'];
      if (loc != null) {
        final String name = data['name'] ?? 'SOS';
        final String markerKey = "${name}_red";
        
        if (!_customMarkers.containsKey(markerKey)) {
          _generateMarkerIcon(name, Colors.red, markerKey);
        }

        newMarkers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(loc.latitude, loc.longitude),
            icon: _customMarkers[markerKey] ?? BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(title: name),
            onTap: () {
              final target = LatLng(loc.latitude, loc.longitude);
              if (mounted) setState(() => _focusLocation = target);
              _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, 18));
            },
          ),
        );
      }
    }
    if (mounted) {
      setState(() {
        _markers.clear();
        _markers.addAll(newMarkers);
      });
    }
  }

  Future<void> _generateMarkerIcon(String name, Color color, String key) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double width = 100.0;
    const double height = 35.0;
    
    final Paint paint = Paint()..color = color;
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
        _customMarkers[key] = BitmapDescriptor.bytes(data.buffer.asUint8List());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildDispatchContent(),
      OfficerProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.outline,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Dispatch'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildDispatchContent() {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Column(children: [
      _buildHeader(),
      
      // Increased Map height for a more commanding view
      Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          height: screenHeight * 0.4, 
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF131B2E), 
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.outlineVariant.withAlpha(80), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(120),
                blurRadius: 25,
                offset: const Offset(0, 12),
              )
            ],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(target: LatLng(28.6139, 77.2090), zoom: 16),
                  markers: _markers,
                  myLocationEnabled: true,
                  style: _mapStyle,
                  onMapCreated: (controller) => _mapController = controller,
                ),
              ),
              if (_focusLocation != null)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      final url = 'https://www.google.com/maps/dir/?api=1&destination=${_focusLocation!.latitude},${_focusLocation!.longitude}';
                      launchUrl(Uri.parse(url));
                    },
                    backgroundColor: AppColors.primary,
                    icon: const Icon(Icons.directions, color: Colors.white),
                    label: const Text('Get Direction', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
      ),
      
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            Text('Active Incidents', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.red.withAlpha(30), borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                const Icon(Icons.circle, color: Colors.red, size: 8),
                const SizedBox(width: 6),
                Text('LIVE FEED', style: GoogleFonts.inter(fontSize: 10, color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ]),
            ),
          ],
        ),
      ),
      
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('alerts')
              .where('status', whereIn: ['pending', 'acknowledged'])
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs.where((doc) => !_ignoredAlertIds.contains(doc.id)).toList();

            if (docs.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _updateMarkersFromDocs(docs);
              });
            }

            if (docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 48, color: AppColors.outlineVariant),
                    const SizedBox(height: 12),
                    Text('No active incidents', style: GoogleFonts.inter(color: AppColors.outline)),
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
                return _buildIncidentCard(data, docId);
              },
            );
          },
        ),
      ),
    ]);
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.all(20),
    child: Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('POLICE COMMAND', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 2)),
        Text('Dispatch Center', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
      ]),
      const Spacer(),
      CircleAvatar(
        backgroundColor: AppColors.primary.withAlpha(40),
        child: const Icon(Icons.security, color: AppColors.primary),
      ),
    ]),
  );

  Widget _buildIncidentCard(Map<String, dynamic> data, String id) {
    final bool isAcknowledged = data['status'] == 'acknowledged';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAcknowledged
              ? Colors.green.withAlpha(120)
              : AppColors.outlineVariant.withAlpha(50),
          width: isAcknowledged ? 1.5 : 1,
        ),
      ),
      child: Column(children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isAcknowledged ? Colors.green.withAlpha(30) : Colors.red.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.sos, color: isAcknowledged ? Colors.green : Colors.red, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SOS Alert', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
            Text('ID: ${id.substring(0,8).toUpperCase()}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.outline)),
          ])),
          // Acknowledged badge
          if (isAcknowledged)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withAlpha(120)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.check_circle, size: 12, color: Colors.green),
                const SizedBox(width: 4),
                Text('EN ROUTE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.green)),
              ]),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withAlpha(80)),
              ),
              child: Text('PENDING', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.red)),
            ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.location_searching, color: AppColors.primary),
            onPressed: () {
              final GeoPoint? loc = data['location'];
              if (loc != null) {
                final target = LatLng(loc.latitude, loc.longitude);
                setState(() => _focusLocation = target);
                _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, 18));
              }
            },
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: () => setState(() => _ignoredAlertIds.add(id)),
            child: const Text('Ignore'),
          )),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(
            onPressed: () => context.push('/police/incident-command-view/$id'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(isAcknowledged ? 'View / Resolve' : 'Dispatch'),
          )),
        ]),
      ]),
    );
  }

  // Archive content removed to show only active alerts

  final String? _mapStyle = null; 
}