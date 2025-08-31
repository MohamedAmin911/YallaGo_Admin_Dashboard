import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class WebMapWidget extends StatefulWidget {
  final Set<Marker> markers;
  final LatLng initialCameraPosition;
  final double initialZoom;

  const WebMapWidget({
    super.key,
    required this.markers,
    this.initialCameraPosition = const LatLng(30.0444, 31.2357),
    this.initialZoom = 12,
  });

  @override
  State<WebMapWidget> createState() => _WebMapWidgetState();
}

class _WebMapWidgetState extends State<WebMapWidget> {
  GoogleMapController? _controller;
  bool _mapInitialized = false;

  @override
  void initState() {
    super.initState();
    // Delay map initialization to avoid IntersectionObserver errors
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _mapInitialized = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_mapInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.initialCameraPosition,
        zoom: widget.initialZoom,
      ),
      markers: widget.markers,
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;
      },
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      buildingsEnabled: false,
      compassEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
