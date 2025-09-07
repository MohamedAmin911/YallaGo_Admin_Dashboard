import 'package:flutter/material.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';

class StatusPill extends StatelessWidget {
  final String status;

  const StatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l = status.toLowerCase();
    Color c = Colors.grey;
    if (l == 'pending_approval') c = Colors.orange;
    if (l == 'active' || l == 'paid') c = Colors.green;
    if (l == 'suspended') c = AdminColors.danger;
    if (l == 'rejected') c = Colors.redAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        l.isEmpty
            ? '-'
            : l[0].toUpperCase() + l.substring(1).replaceAll('_', ' '),
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
