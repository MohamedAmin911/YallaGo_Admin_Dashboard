import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yallago_admin_dashboard/cubit/driver%20tracking/driver_tracking_cubit.dart';
import 'package:yallago_admin_dashboard/cubit/driver%20tracking/driver_tracking_state.dart';
import 'package:yallago_admin_dashboard/models/driver.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';

class DriversTrackingTab extends StatefulWidget {
  const DriversTrackingTab({super.key});

  @override
  State<DriversTrackingTab> createState() => _DriversTrackingTabState();
}

class _DriversTrackingTabState extends State<DriversTrackingTab> {
  final _searchCtrl = TextEditingController();
  final _debouncer = _Debouncer(const Duration(milliseconds: 250));
  GoogleMapController? _mapCtrl;

  // Default center (Port Said, Egypt). Will auto-fit to markers.
  static const LatLng _defaultCenter = LatLng(31.2653, 32.3019);
  static const CameraPosition _initialCamera = CameraPosition(
    target: _defaultCenter,
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    context.read<DriversTrackingCubit>().start();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriversTrackingCubit, DriversTrackingState>(
      listenWhen: (prev, next) => prev.visible != next.visible,
      listener: (context, state) async {
        await _autoAdjustCamera(state.visible);
      },
      builder: (context, state) {
        final markers = _buildMarkers(state.visible);
        return Stack(
          children: [
            Positioned.fill(
              top: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _initialCamera,
                  onMapCreated: (c) => _mapCtrl = c,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  compassEnabled: true,
                  zoomControlsEnabled: true,
                  markers: markers,
                ),
              ),
            ),

            // Top search bar
            Positioned(
              top: 26,
              left: 0,
              right: 0,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: _SearchBar(
                    controller: _searchCtrl,
                    placeholder: 'Search driver by name or ID...',
                    onChanged:
                        (v) => _debouncer.run(() {
                          context.read<DriversTrackingCubit>();
                        }),
                    onClear: () {
                      _searchCtrl.clear();
                      context.read<DriversTrackingCubit>();
                    },
                  ),
                ),
              ),
            ),

            // Bottom-left info chip: counts and loading/error
            Positioned(
              left: 16,
              bottom: 16,
              child: _InfoPanel(
                total: state.all.length,
                visible: state.visible.length,
                loading: state.loading,
                error: state.error,
              ),
            ),
          ],
        );
      },
    );
  }

  final Map<String, Marker> _markerCache = {};

  Set<Marker> _buildMarkers(List<Driver> drivers) {
    final seen = <String>{};
    for (final d in drivers) {
      final gp = d.currentLocation;
      if (gp == null) continue;
      seen.add(d.id);
      final pos = LatLng(gp.latitude, gp.longitude);

      final existing = _markerCache[d.id];
      if (existing == null || existing.position != pos) {
        _markerCache[d.id] = Marker(
          markerId: MarkerId(d.id),
          position: pos,
          infoWindow: InfoWindow(
            title: d.fullName.isEmpty ? 'Unnamed driver' : d.fullName,
            snippet:
                'ID: ${d.id}${d.licensePlate != null ? ' | Plate: ${d.licensePlate}' : ''}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        );
      }
    }
    // Remove markers for drivers no longer in the stream/filter
    _markerCache.removeWhere((id, _) => !seen.contains(id));
    return _markerCache.values.toSet();
  }

  Future<void> _autoAdjustCamera(List<Driver> visible) async {
    if (_mapCtrl == null) return;
    final locs =
        visible.map((d) => d.currentLocation).whereType<GeoPoint>().toList();
    if (locs.isEmpty) {
      await _mapCtrl!.animateCamera(
        CameraUpdate.newCameraPosition(_initialCamera),
      );
      return;
    }

    // If searching and only 1 driver is visible, zoom into them.
    if (visible.length == 1) {
      final gp = locs.first;
      await _mapCtrl!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(gp.latitude, gp.longitude), zoom: 16),
        ),
      );
      return;
    }

    // Fit all visible markers
    final bounds = _boundsFromGeoPoints(locs);
    // Add padding for a nicer look
    await _mapCtrl!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  LatLngBounds _boundsFromGeoPoints(List<GeoPoint> points) {
    double? x0, x1, y0, y1;
    for (final p in points) {
      final lat = p.latitude;
      final lng = p.longitude;
      if (x0 == null) {
        x0 = x1 = lat;
        y0 = y1 = lng;
      } else {
        if (lat > x1!) x1 = lat;
        if (lat < x0) x0 = lat;
        if (lng > y1!) y1 = lng;
        if (lng < y0!) y0 = lng;
      }
    }
    return LatLngBounds(
      southwest: LatLng(x0!, y0!),
      northeast: LatLng(x1!, y1!),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.placeholder,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AdminColors.lightGray.withOpacity(0.6)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(Icons.search, color: AdminColors.secondaryText),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: placeholder,
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.clear, color: AdminColors.secondaryText),
              tooltip: 'Clear',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final int total;
  final int visible;
  final bool loading;
  final String? error;

  const _InfoPanel({
    required this.total,
    required this.visible,
    required this.loading,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    final bg = Colors.white.withOpacity(0.9);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.lightGray.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.drive_eta,
            size: 18,
            color: AdminColors.secondaryText,
          ),
          const SizedBox(width: 8),
          Text(
            'Visible: $visible / $total',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          if (loading) ...[
            const SizedBox(width: 10),
            const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
          if ((error ?? '').isNotEmpty) ...[
            const SizedBox(width: 10),
            Icon(Icons.error_outline, size: 18, color: Colors.red.shade400),
          ],
        ],
      ),
    );
  }
}

class _Debouncer {
  final Duration delay;
  Timer? _timer;

  _Debouncer(this.delay);

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }
}
