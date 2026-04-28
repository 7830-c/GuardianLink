import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_colors.dart';
import '../services/location_service.dart';

class GuardianMapView extends StatefulWidget {
  final LatLng initialPosition;
  final Set<Marker> markers;
  final double zoom;
  final bool showMyLocation;
  final bool useLiveLocation;

  const GuardianMapView({
    super.key,
    this.initialPosition = const LatLng(28.6139, 77.2090),
    this.markers = const {},
    this.zoom = 14.0,
    this.showMyLocation = true,
    this.useLiveLocation = false,
  });

  @override
  State<GuardianMapView> createState() => _GuardianMapViewState();
}

class _GuardianMapViewState extends State<GuardianMapView> {
  GoogleMapController? _controller;
  MapType _currentMapType = MapType.normal;
  LatLng? _currentPosition;

  // 1. Logic to focus on markers when they change
  @override
  void didUpdateWidget(covariant GuardianMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Agar naye markers aaye hain, toh map ko pehle marker par le jao
    if (widget.markers.isNotEmpty && widget.markers != oldWidget.markers) {
      _focusOnSOS();
    }
  }

  void _focusOnSOS() {
    if (_controller != null && widget.markers.isNotEmpty) {
      final firstMarker = widget.markers.first.position;
      _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(firstMarker, 12.0), // Zoom out thoda taaki area dikhe
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.useLiveLocation) {
      _initLiveLocation();
    }
  }

  Future<void> _initLiveLocation() async {
    final position = await LocationService.getCurrentLocation();
    if (position != null && mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, widget.zoom),
      );
    }
  }

  // Dark Style string wahi rakho (Maine yahan space bachane ke liye chhota kiya hai)
  final String _darkMapStyle = '''[...]'''; // Apni purani style string yahan rehne dena

  void _onToggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.initialPosition,
            zoom: widget.zoom,
          ),
          style: _darkMapStyle,
          mapType: _currentMapType,
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
            // Agar markers pehle se hain, toh focus karo
            if (widget.markers.isNotEmpty) _focusOnSOS();
          },
          markers: widget.markers,
          myLocationEnabled: widget.showMyLocation,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
        ),
        // Controls Overlay... (Same as before)
        _buildControls(),
      ],
    );
  }

  Widget _buildControls() {
    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        children: [
          _MapControlBtn(
            icon: _currentMapType == MapType.normal ? Icons.layers_outlined : Icons.map_outlined,
            onTap: _onToggleMapType,
            tooltip: 'Toggle Satellite',
          ),
          const SizedBox(height: 8),
          _MapControlBtn(
            icon: Icons.add,
            onTap: () => _controller?.animateCamera(CameraUpdate.zoomIn()),
            tooltip: 'Zoom In',
          ),
          const SizedBox(height: 8),
          _MapControlBtn(
            icon: Icons.remove,
            onTap: () => _controller?.animateCamera(CameraUpdate.zoomOut()),
            tooltip: 'Zoom Out',
          ),
        ],
      ),
    );
  }
}

class _MapControlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  const _MapControlBtn({required this.icon, required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.onSurface, size: 18),
      ),
    );
  }
}