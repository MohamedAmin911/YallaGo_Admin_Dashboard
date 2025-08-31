// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:yallago_admin_dashboard/UI/driver%20tracking/widgets/web_map_widget.dart';
// import 'package:yallago_admin_dashboard/cubit/driver%20tracking/driver_tracking_cubit.dart';
// import 'package:yallago_admin_dashboard/cubit/driver%20tracking/driver_tracking_state.dart';
// import 'package:yallago_admin_dashboard/models/driver.dart';
// import 'driver_marker.dart';

// class TrackingMap extends StatefulWidget {
//   const TrackingMap({super.key});

//   @override
//   State<TrackingMap> createState() => _TrackingMapState();
// }

// class _TrackingMapState extends State<TrackingMap> {
//   final Set<Marker> _markers = {};

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<DriverTrackingCubit, DriverTrackingState>(
//       builder: (context, state) {
//         _updateMarkers(state.visibleDrivers, state.selectedDriver);

//         return ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: WebMapWidget(
//             markers: _markers,
//             initialCameraPosition: const LatLng(30.0444, 31.2357),
//             initialZoom: 12,
//           ),
//         );
//       },
//     );
//   }

//   void _updateMarkers(List<Driver> drivers, Driver? selectedDriver) {
//     try {
//       _markers.clear();

//       for (final driver in drivers) {
//         if (driver.currentLocation != null) {
//           try {
//             final isSelected = selectedDriver?.id == driver.id;
//             _markers.add(
//               DriverMarker.createMarker(driver, isSelected: isSelected),
//             );
//           } catch (e) {
//             print('Error creating marker for driver ${driver.id}: $e');
//           }
//         }
//       }
//     } catch (e) {
//       print('Error updating markers: $e');
//     }
//   }
// }
