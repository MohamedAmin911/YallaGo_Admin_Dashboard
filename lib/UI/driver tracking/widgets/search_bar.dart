// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:yallago_admin_dashboard/core/color_theme.dart';
// import 'package:yallago_admin_dashboard/core/common%20widgets/surface_card.dart';
// import 'package:yallago_admin_dashboard/cubit/driver%20tracking/driver_tracking_cubit.dart';
// import 'package:yallago_admin_dashboard/cubit/driver%20tracking/driver_tracking_state.dart';

// class TrackingSearchBar extends StatefulWidget {
//   const TrackingSearchBar({super.key});

//   @override
//   State<TrackingSearchBar> createState() => _TrackingSearchBarState();
// }

// class _TrackingSearchBarState extends State<TrackingSearchBar> {
//   final TextEditingController _controller = TextEditingController();
//   Timer? _debounceTimer;

//   @override
//   void dispose() {
//     _debounceTimer?.cancel();
//     _controller.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged(String value) {
//     _debounceTimer?.cancel();
//     _debounceTimer = Timer(const Duration(milliseconds: 500), () {
//       if (value.length > 2) {
//         context.read<DriverTrackingCubit>().searchDrivers(value);
//       } else if (value.isEmpty) {
//         context.read<DriverTrackingCubit>().clearSearch();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<DriverTrackingCubit, DriverTrackingState>(
//       builder: (context, state) {
//         return SurfaceCard(
//           padding: EdgeInsets.zero,
//           child: SizedBox(
//             height: 56,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: InputDecoration(
//                       hintText: 'Search drivers by ID or name...',
//                       prefixIcon: const Icon(Icons.search),
//                       suffixIcon:
//                           state.isSearching
//                               ? IconButton(
//                                 icon: const Icon(Icons.clear),
//                                 onPressed: () {
//                                   _controller.clear();
//                                   context
//                                       .read<DriverTrackingCubit>()
//                                       .clearSearch();
//                                 },
//                               )
//                               : null,
//                       border: InputBorder.none,
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 14,
//                       ),
//                     ),
//                     onChanged: _onSearchChanged,
//                   ),
//                 ),
//                 if (state.isSearching) ...[
//                   const VerticalDivider(),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     child: Text(
//                       state.visibleDrivers.isNotEmpty
//                           ? '${state.visibleDrivers.length} found'
//                           : 'No results',
//                       style: TextStyle(
//                         color:
//                             state.visibleDrivers.isNotEmpty
//                                 ? Colors.green
//                                 : AdminColors.danger,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
