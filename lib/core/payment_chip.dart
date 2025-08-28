import 'package:flutter/material.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';

class PaymentChip extends StatelessWidget {
  final String label;
  const PaymentChip({super.key, required this.label});
  @override
  Widget build(BuildContext context) {
    final paid =
        label.toLowerCase() == 'paid' || label.toLowerCase() == 'succeeded';
    final c = paid ? Colors.green : AdminColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: c.withOpacity(0.3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _labelCase(label),
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
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
    default:
      return lower[0].toUpperCase() + lower.substring(1);
  }
}
