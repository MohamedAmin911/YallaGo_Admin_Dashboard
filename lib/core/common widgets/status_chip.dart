import 'package:flutter/material.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';

class StatusChip extends StatelessWidget {
  final String label;
  const StatusChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    Color c = AdminColors.primary;
    if (label.toLowerCase() == 'completed') c = Colors.green;
    if (label.toLowerCase() == 'cancelled') c = AdminColors.danger;
    if (label.toLowerCase() == 'active') c = Colors.green;
    if (label.toLowerCase() == 'suspended') c = AdminColors.danger;
    if (label.toLowerCase() == 'ongoing' ||
        label.toLowerCase() == 'in progress') {
      c = Colors.black87;
    }
    if (label.toLowerCase() == 'pending') c = Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _labelCase(label),
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: Colors.white,
        ),
      ),
    );
  }
}

String _labelCase(String s) {
  if (s.isEmpty) return s;
  final lower = s.toLowerCase();
  // Title case with known labels
  switch (lower) {
    case 'in_progress':
      return 'Ongoing';
    case 'driver_accepted':
      return 'Accepted';
    default:
      return lower[0].toUpperCase() + lower.substring(1);
  }
}
