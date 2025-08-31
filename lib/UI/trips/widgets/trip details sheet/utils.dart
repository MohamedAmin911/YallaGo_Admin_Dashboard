import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TripDetailsUtils {
  static String prettyStatus(String s) {
    final l = s.toLowerCase();
    if (l == 'in_progress') return 'Ongoing';
    return l.isEmpty ? '-' : l[0].toUpperCase() + l.substring(1);
  }

  static String prettyPayment(String s) {
    final l = s.toLowerCase();
    if (l == 'succeeded') return 'Paid';
    if (l == 'pending') return 'Pending';
    return l.isEmpty ? '-' : l[0].toUpperCase() + l.substring(1);
  }

  static Future<void> copyToClipboard(BuildContext context, String v) async {
    await Clipboard.setData(ClipboardData(text: v));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }
}
