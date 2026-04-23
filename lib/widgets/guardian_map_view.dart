import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_colors.dart';
import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class GuardianMapView extends StatefulWidget {
  final LatLng initialPosition;
  final Set<Marker> markers;
  final double zoom;
  final bool showMyLocation;
  final bool useLiveLocation;

  const GuardianMapView({
    super.key,
    this.initialPosition = const LatLng(28.6139, 77.2090), // New Delhi
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

  // Dark mode style for Google Maps
  final String _darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#242f3e"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#242f3e"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#746855"}]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#d59563"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#d59563"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [{"color": "#263c3f"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#6b9a76"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#38414e"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#212a37"}]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#9ca5b3"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{"color": "#746855"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#1f2835"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#f3d19c"}]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [{"color": "#2f3948"}]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#d59563"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#17263c"}]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#515c6d"}]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#17263c"}]
  }
]
''';

  void _onToggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal 
          ? MapType.satellite 
          : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentPosition ?? widget.initialPosition,
            zoom: widget.zoom,
          ),
          mapType: _currentMapType,
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
            if (_currentMapType == MapType.normal) {
              _controller?.setMapStyle(_darkMapStyle);
            }
            if (_currentPosition != null) {
              _controller?.animateCamera(
                CameraUpdate.newLatLngZoom(_currentPosition!, widget.zoom),
              );
            }
          },
          markers: widget.markers,
          myLocationEnabled: widget.showMyLocation,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
        ),
        // Map Controls Overlay
        Positioned(
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
              if (widget.useLiveLocation) ...[
                const SizedBox(height: 8),
                _MapControlBtn(
                  icon: Icons.my_location,
                  onTap: _initLiveLocation,
                  tooltip: 'Recenter',
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MapControlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _MapControlBtn({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.onSurface, size: 20),
      ),
    );
  }
}
