import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../theme/app_colors.dart';
import '../../widgets/guardian_map_view.dart';

import 'package:geocoding/geocoding.dart';
import '../../services/location_service.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  String _currentAddress = 'Fetching location...';
  LatLng _currentPos = const LatLng(28.6304, 77.2177);

  @override
  void initState() {
    super.initState();
    _updateLocation();
  }

  Future<void> _updateLocation() async {
    try {
      final pos = await LocationService.getCurrentLocation();
      if (pos == null) return;
      
      final List<Placemark> placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      
      if (mounted) {
        setState(() {
          _currentPos = LatLng(pos.latitude, pos.longitude);
          if (placemarks.isNotEmpty) {
            final pm = placemarks.first;
            _currentAddress = '${pm.name}, ${pm.subLocality}, ${pm.locality}';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _currentAddress = 'Location services unavailable');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Live Tracking'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: Column(children: [
        // Top info card (Status)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Row(children: [
              Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Location Sharing Active', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                Text(_currentAddress, style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
              ])),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.primary, size: 20),
                onPressed: _updateLocation,
              ),
            ]),
          ),
        ),

        // Real Google Map
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(children: [
                  GuardianMapView(
                    initialPosition: _currentPos,
                    zoom: 15.0,
                    useLiveLocation: true,
                  ),
                  // Floating recenter button
                  Positioned(bottom: 16, right: 16, child: FloatingActionButton.small(
                    onPressed: _updateLocation,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.my_location),
                  )),
                ]),
              ),
            ),
          ),
        ),

        // Bottom panel
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20)],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _MapStat('${_currentPos.latitude.toStringAsFixed(4)}° N', 'Latitude'),
              Container(width: 1, height: 32, color: AppColors.outlineVariant),
              _MapStat('${_currentPos.longitude.toStringAsFixed(4)}° E', 'Longitude'),
              Container(width: 1, height: 32, color: AppColors.outlineVariant),
              const _MapStat('±5m', 'Accuracy'),
            ]),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                icon: const Icon(Icons.stop_circle_outlined, size: 18),
                label: Text('Stop Sharing', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondary, 
                  side: const BorderSide(color: AppColors.secondary), 
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(
                icon: const Icon(Icons.share_outlined, size: 18),
                label: Text('Share Link', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, 
                  foregroundColor: Colors.white, 
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
                  elevation: 0,
                ),
              )),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _MapStat extends StatelessWidget {
  final String value, label;
  const _MapStat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
    Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline)),
  ]);
}

