import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
  BitmapDescriptor _driverIcon = BitmapDescriptor.defaultMarker;
  // Default center (Port Said, Egypt)
  static const LatLng _defaultCenter = LatLng(31.2653, 32.3019);
  static const CameraPosition _initialCamera = CameraPosition(
    target: _defaultCenter,
    zoom: 12,
  );

  // Rendered markers and per-driver version to force refresh on web
  Set<Marker> _renderMarkers = const {};
  final Map<String, LatLng> _lastPos = {};
  final Map<String, int> _version = {};

  // Track last visible driver IDs to avoid over-animating camera
  Set<String> _lastVisibleIds = {};

  @override
  void initState() {
    super.initState();
    context.read<DriversTrackingCubit>().start();
    _loadIcons();
  }

  Future<void> _loadIcons() async {
    try {
      // Base icon
      _driverIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/images/locationpin.png',
      );
    } catch (e) {
      debugPrint('Failed to load driver icon: $e');
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Always update markers via setState when state changes
        BlocListener<DriversTrackingCubit, DriversTrackingState>(
          listenWhen: (prev, next) => true,
          listener: (context, state) {
            _updateMarkers(state.visible);
            _maybeAdjustCamera(state.visible);
          },
        ),
      ],
      child: BlocBuilder<DriversTrackingCubit, DriversTrackingState>(
        builder: (context, state) {
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
                    // Use the locally rendered markers (updated via setState)
                    markers: _renderMarkers,
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
                            // If you have filtering:
                            // context.read<DriversTrackingCubit>().setQuery(v.trim());
                          }),
                      onClear: () {
                        _searchCtrl.clear();
                        // context.read<DriversTrackingCubit>().setQuery('');
                      },
                    ),
                  ),
                ),
              ),

              // Bottom-left info chip
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
      ),
    );
  }

  // Build and apply markers with setState; force repaint on web
  void _updateMarkers(List<Driver> drivers) {
    final seen = <String>{};
    final next = <Marker>{};

    for (final d in drivers) {
      final gp = d.currentLocation;
      if (gp == null) continue;
      seen.add(d.id);

      final pos = LatLng(gp.latitude, gp.longitude);
      final last = _lastPos[d.id];

      final moved =
          last == null ||
          last.latitude != pos.latitude ||
          last.longitude != pos.longitude;

      if (kIsWeb && moved) {
        _version[d.id] = (_version[d.id] ?? 0) + 1;
      }
      final ver = _version[d.id] ?? 0;

      final markerId = kIsWeb ? MarkerId('${d.id}_$ver') : MarkerId(d.id);

      next.add(
        Marker(
          markerId: markerId,
          position: pos,
          infoWindow: InfoWindow(
            title: d.fullName.isEmpty ? 'Unnamed driver' : d.fullName,
            snippet:
                'ID: ${d.id}${d.licensePlate != null ? ' | Plate: ${d.licensePlate}' : ''}',
          ),
          icon: _driverIcon,
        ),
      );

      _lastPos[d.id] = pos;
    }

    // cleanup internal state
    _lastPos.removeWhere((id, _) => !seen.contains(id));
    _version.removeWhere((id, _) => !seen.contains(id));

    if (kIsWeb) {
      // Force full refresh: render empty set for one microtask, then new markers
      setState(() => _renderMarkers = const {});
      scheduleMicrotask(() {
        if (!mounted) return;
        setState(() => _renderMarkers = next);
      });
    } else {
      setState(() => _renderMarkers = next);
    }
  }

  void _maybeAdjustCamera(List<Driver> visible) {
    final newIds = visible.map((d) => d.id).toSet();
    final idsChanged =
        newIds.length != _lastVisibleIds.length ||
        !_lastVisibleIds.containsAll(newIds);

    if (idsChanged) {
      _lastVisibleIds = newIds;
      _autoAdjustCamera(visible);
    }
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
    if (visible.length == 1) {
      final gp = locs.first;
      await _mapCtrl!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(gp.latitude, gp.longitude), zoom: 16),
        ),
      );
      return;
    }
    final bounds = _boundsFromGeoPoints(locs);
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
