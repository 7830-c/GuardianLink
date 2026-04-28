import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';
import 'family_profile_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/notification_service.dart';

class FamilyDashboardScreen extends StatefulWidget {
  const FamilyDashboardScreen({super.key});
  @override
  State<FamilyDashboardScreen> createState() => _FamilyDashboardScreenState();
}

class _FamilyDashboardScreenState extends State<FamilyDashboardScreen> {
  int _selectedIndex = 0;
  LatLng? _focusLocation;
  GoogleMapController? _mapController;
  String? _lastNotifiedAlertId;
  final Map<String, BitmapDescriptor> _customMarkers = {};
  // Locally dismissed banner IDs — does NOT affect Firestore.
  // Alerts stay active until the loved one resolves them.
  final Set<String> _dismissedBannerAlertIds = {};

  void _triggerLocalAlert(List<QueryDocumentSnapshot> activeAlerts) {
    if (activeAlerts.isNotEmpty) {
      final latestAlertId = activeAlerts.first.id;
      if (_lastNotifiedAlertId != latestAlertId) {
        _lastNotifiedAlertId = latestAlertId;
        NotificationService.showLocalAlert(
          title: "EMERGENCY: SOS DETECTED!",
          body: "One of your loved ones is in danger. Tap to track.",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fetch UID in build to ensure it's always current
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('lovedOne')
              .where('guardianIds', arrayContains: currentUid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final childrenDocs = snapshot.data?.docs ?? [];
            
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('alerts')
                  .where('status', whereIn: ['pending', 'acknowledged'])
                  .snapshots(),
              builder: (context, alertSnapshot) {
                final alertDocs = alertSnapshot.data?.docs ?? [];
                
                // Alert filtering logic
                final activeAlerts = alertDocs.where((alert) => 
                  childrenDocs.any((child) => child.id == alert['lovedOneId'])
                ).toList();

                // Trigger local notification if a new alert is detected
                _triggerLocalAlert(activeAlerts);

                final List<Widget> pages = [
                  _buildHomeContent(childrenDocs, activeAlerts),
                  _buildMapContent(childrenDocs, activeAlerts),
                  const FamilyProfileScreen(),
                ];

                return Column(children: [
                  if (_selectedIndex == 0) _buildHeader(),
                  Expanded(child: pages[_selectedIndex]),
                ]);
              },
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeContent(List<QueryDocumentSnapshot> children, List<QueryDocumentSnapshot> activeAlerts) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatOverview(children.length, activeAlerts.length),
          const SizedBox(height: 24),

          // Only show banner for alerts the guardian hasn't locally dismissed.
          // Member cards still show SOS from Firestore regardless.
          Builder(builder: (_) {
            final undismissed = activeAlerts
                .where((a) => !_dismissedBannerAlertIds.contains(a.id))
                .toList();
            if (undismissed.isEmpty) return const SizedBox.shrink();
            return _buildEmergencyBanner(undismissed.first, children, activeAlerts);
          }),

          const SizedBox(height: 24),
          Text('Linked Loved Ones', 
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
          const SizedBox(height: 12),

          if (children.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.people_outline, size: 48, color: AppColors.outlineVariant),
                    const SizedBox(height: 12),
                    Text('No linked children found.\nEnsure children use your phone number during registration.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: AppColors.outline, fontSize: 13)),
                  ],
                ),
              ),
            ),

          ...children.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final bool hasAlert = activeAlerts.any((a) => a['lovedOneId'] == doc.id);
            return _buildMemberCard(data, hasAlert);
          }),

          const SizedBox(height: 24),
          Text('Quick Actions', 
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
          const SizedBox(height: 12),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildMapContent(List<QueryDocumentSnapshot> children, List<QueryDocumentSnapshot> activeAlerts) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    Set<Marker> markers = children.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final GeoPoint? loc = data['location'];
      final name = data['name'] ?? "Loved One";
      final bool hasAlert = activeAlerts.any((a) => a['lovedOneId'] == doc.id);
      final Color markerColor = hasAlert ? Colors.red : Colors.green;
      final String markerKey = "${name}_${hasAlert ? 'red' : 'green'}";

      if (!_customMarkers.containsKey(markerKey)) {
        _generateMarkerIcon(name, markerColor, markerKey);
      }

      return Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(loc?.latitude ?? 0, loc?.longitude ?? 0),
        icon: _customMarkers[markerKey] ?? BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: name, snippet: hasAlert ? '🔴 SOS Active' : '🟢 Safe'),
        // Tap a marker → focus that person and show Get Direction button
        onTap: () {
          if (loc != null) {
            final target = LatLng(loc.latitude, loc.longitude);
            setState(() => _focusLocation = target);
            Future.delayed(const Duration(milliseconds: 300), () {
              _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, 18));
            });
          }
        },
      );
    }).toSet();

    LatLng initialPos = _focusLocation ?? const LatLng(20.5937, 78.9629);
    if (_focusLocation == null && children.isNotEmpty) {
      final firstLoc = children.first['location'] as GeoPoint?;
      if (firstLoc != null) {
        initialPos = LatLng(firstLoc.latitude, firstLoc.longitude);
      }
    }

    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center, // Vertically center the content
          children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: screenHeight * 0.6, 
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: AppColors.outlineVariant.withAlpha(100), width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 30, offset: const Offset(0, 15))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: initialPos, 
                      zoom: _focusLocation != null ? 18 : 17
                    ),
                    markers: markers,
                    myLocationEnabled: true,
                    mapType: MapType.normal,
                    onMapCreated: (controller) => _mapController = controller,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.tertiary.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.radar, size: 14, color: AppColors.tertiary),
                  const SizedBox(width: 8),
                  Text('Centered Surveillance Active', 
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.tertiary, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ],
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
        if (_focusLocation != null)
          Positioned(
            bottom: 24,
            right: 24,
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
        if (_focusLocation != null)
          Positioned(
            bottom: 84,
            right: 24,
            child: FloatingActionButton.small(
              onPressed: () => setState(() => _focusLocation = null),
              backgroundColor: Colors.white24,
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.all(20),
    child: Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Family Dashboard', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
        Text('Real-time safety monitoring', style: GoogleFonts.inter(fontSize: 12, color: AppColors.tertiary)),
      ]),
      const Spacer(),
      IconButton(
        icon: const Icon(Icons.refresh, color: AppColors.onSurface),
        onPressed: () => setState(() {}),
      ),
    ]),
  );

  Widget _buildStatOverview(int memberCount, int alertCount) => Row(children: [
    Expanded(child: _StatCard(value: '$memberCount', label: 'Members', icon: Icons.people, color: AppColors.primary)),
    const SizedBox(width: 12),
    Expanded(child: _StatCard(value: 'Active', label: 'Safety Net', icon: Icons.security, color: Colors.green)),
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

  Widget _buildEmergencyBanner(QueryDocumentSnapshot alert, List<QueryDocumentSnapshot> children, List<QueryDocumentSnapshot> activeAlerts) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    margin: const EdgeInsets.only(bottom: 24),
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.red.withAlpha(45),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.red, width: 2),
      boxShadow: [
        BoxShadow(color: Colors.red.withAlpha(25), blurRadius: 20, spreadRadius: 2)
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 36),
            const SizedBox(width: 16),
            Text('EMERGENCY ALERT', style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                'A loved one needs help!', 
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2)
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              tooltip: 'Hide banner (alert stays active)',
              onPressed: () {
                setState(() => _dismissedBannerAlertIds.add(alert.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Banner hidden. The alert stays active until your loved one resolves it.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (activeAlerts.isEmpty) return;
              
              // Sort to get the most recent alert
              final recentAlert = activeAlerts.toList();
              recentAlert.sort((a, b) {
                final aTime = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                final bTime = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                return (bTime ?? Timestamp.now()).compareTo(aTime ?? Timestamp.now());
              });

              final String lovedOneId = recentAlert.first['lovedOneId'];
              final childDoc = children.firstWhere(
                (c) => c.id == lovedOneId, 
                orElse: () => children.first
              );
              
              final GeoPoint? loc = childDoc.get('location');
              if (loc != null) {
                final target = LatLng(loc.latitude, loc.longitude);
                setState(() {
                  _focusLocation = target;
                  _selectedIndex = 1;
                });
                Future.delayed(const Duration(milliseconds: 500), () {
                  _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, 19));
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 8,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_searching, size: 20),
                SizedBox(width: 10),
                Text('TRACK LOCATION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildGuardianAlertHistory(List<QueryDocumentSnapshot> children) {
    if (children.isEmpty) return const Center(child: Text('No linked family members found', style: TextStyle(color: Colors.white)));
    
    final childIds = children.map((c) => c.id).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Family Emergency History', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('alerts')
                .where('lovedOneId', whereIn: childIds)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              
              final docs = snapshot.data!.docs.toList();
              // Sort in-memory to avoid composite index requirement
              docs.sort((a, b) {
                final aTime = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                final bTime = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                if (aTime == null || bTime == null) return 0;
                return bTime.compareTo(aTime);
              });

              if (docs.isEmpty) return Center(child: Text('No emergency records found', style: TextStyle(color: AppColors.outline)));

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final data = docs[i].data() as Map<String, dynamic>;
                  final childId = data['lovedOneId'];
                  final childName = children.firstWhere((c) => c.id == childId, orElse: () => children.first)['name'] ?? "Unknown";
                  final isResolved = data['status'] == 'resolved';
                  final time = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isResolved ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isResolved ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(isResolved ? Icons.check_circle_outline : Icons.warning_amber_rounded, 
                        color: isResolved ? Colors.green : Colors.red, size: 32),
                      title: Text(childName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                      subtitle: Text(
                        "${isResolved ? 'Resolved' : 'Active SOS'} • ${DateFormat('MMM dd, hh:mm a').format(time)}",
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.outline),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.outline),
                        onPressed: () => FirebaseFirestore.instance.collection('alerts').doc(docs[i].id).delete(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> data, bool hasAlert) {
    final String displayName = data['name'] ?? "Loved One";
    final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "L";

    final timestamp = data['lastLocationUpdate'] as Timestamp?;
    final timeStr = timestamp != null 
        ? DateFormat('hh:mm a').format(timestamp.toDate()) 
        : "N/A";

    final Color cardColor = hasAlert ? Colors.red : Colors.green;

    return Container(
      key: ValueKey(data['uid'] ?? displayName),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withAlpha(hasAlert ? 30 : 15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardColor.withAlpha(hasAlert ? 100 : 50), width: hasAlert ? 2 : 1),
      ),
      child: Row(children: [
        CircleAvatar(
          backgroundColor: cardColor.withAlpha(60),
          child: Text(initial, 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: GestureDetector(
            onTap: () {
              final GeoPoint? loc = data['location'];
              if (loc != null) {
                final target = LatLng(loc.latitude, loc.longitude);
                setState(() {
                  _focusLocation = target;
                  _selectedIndex = 1;
                });
                // Delay to ensure map tab is ready
                Future.delayed(const Duration(milliseconds: 400), () {
                  _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, 18));
                });
              }
            },
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(displayName, 
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: cardColor == Colors.red ? Colors.redAccent : Colors.greenAccent)),
              Text(data['phone'] ?? "", style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
            ]),
          ),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(timeStr, style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline)),
          Text(hasAlert ? "SOS" : "Safe", 
            style: GoogleFonts.inter(fontSize: 12, color: hasAlert ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
        ]),
      ]),
    );
  }

  Widget _buildQuickActions() => Row(children: [
    Expanded(child: _ActionBtn(icon: Icons.map, label: 'Map View', color: AppColors.primary, onTap: () => setState(() => _selectedIndex = 1))),
    const SizedBox(width: 12),
    Expanded(child: _ActionBtn(icon: Icons.history, label: 'History', color: AppColors.tertiary, onTap: () => setState(() => _selectedIndex = 2))),
    const SizedBox(width: 12),
    Expanded(child: _ActionBtn(
      icon: Icons.person_add, 
      label: 'Add Member', 
      color: AppColors.onSurfaceVariant, 
      onTap: () async {
        final user = FirebaseAuth.instance.currentUser;
        String? phone;
        if (user != null) {
          final doc = await FirebaseFirestore.instance.collection('guardian').doc(user.uid).get();
          phone = doc.data()?['phone'];
        }
        if (context.mounted) {
          context.push('/loved-one/register', extra: phone);
        }
      }
    )),
  ]);

  Widget _buildBottomNav() => BottomNavigationBar(
    currentIndex: _selectedIndex,
    type: BottomNavigationBarType.fixed,
    backgroundColor: AppColors.background,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.outline,
    onTap: (i) => setState(() => _selectedIndex = i),
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Tracking'),
      BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
    ],
  );


  Future<void> _generateMarkerIcon(String name, Color color, String key) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double width = 100.0;
    const double height = 35.0;
    
    // Draw background label
    final Paint paint = Paint()..color = color;
    final RRect rRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, width, height - 10),
      const Radius.circular(10),
    );
    canvas.drawRRect(rRect, paint);
    
    // Draw triangle pointer
    final Path path = Path();
    path.moveTo(width / 2 - 6, height - 10);
    path.lineTo(width / 2 + 6, height - 10);
    path.lineTo(width / 2, height);
    path.close();
    canvas.drawPath(path, paint);

    // Draw Text
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

  final String? _mapStyle = null; 
}

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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(label, 
              textAlign: TextAlign.center, 
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 9, color: AppColors.onSurface, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    ),
  );
}