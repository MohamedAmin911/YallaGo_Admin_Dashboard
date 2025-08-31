import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomerDetailsUtils {
  static Future<void> copyToClipboard(
    BuildContext context,
    String value,
  ) async {
    await Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }
}
