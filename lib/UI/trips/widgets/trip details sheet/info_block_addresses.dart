import 'package:flutter/material.dart';
import 'package:yallago_admin_dashboard/UI/trips/widgets/trips%20tab/trip_like_model.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';

class InfoBlockAddresses extends StatelessWidget {
  final TripLike trip;

  const InfoBlockAddresses({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final label = const TextStyle(
      color: AdminColors.secondaryText,
      fontWeight: FontWeight.w600,
    );
    final value = const TextStyle(fontWeight: FontWeight.w700);

    Widget row(IconData icon, String k, String v) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AdminColors.secondaryText),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(k, style: label),
                const SizedBox(height: 4),
                Text(v, style: value),
              ],
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row(Icons.my_location, 'Pickup', trip.pickupAddress),
        row(Icons.location_on, 'Destination', trip.destinationAddress),
      ],
    );
  }
}
