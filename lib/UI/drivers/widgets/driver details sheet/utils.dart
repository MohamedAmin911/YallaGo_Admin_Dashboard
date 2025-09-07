import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverReviewUtils {
  static Future<void> copyToClipboard(
    BuildContext context,
    String value,
  ) async {
    await Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  // Open a URL in the external browser (mobile) or new tab (web).
  static Future<void> openUrl(
    String url, {
    BuildContext? context,
    LaunchMode mode = LaunchMode.externalApplication,
  }) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showSnack(context, 'Invalid URL');
      return;
    }
    try {
      final can = await canLaunchUrl(uri);
      if (!can) {
        _showSnack(context, 'Cannot open URL');
        return;
      }
      final ok = await launchUrl(uri, mode: mode);
      if (!ok) {
        _showSnack(context, 'Failed to open URL');
      }
    } catch (e) {
      _showSnack(context, 'Failed to open URL: $e');
    }
  }

  static void _showSnack(BuildContext? ctx, String msg) {
    if (ctx == null) return;
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
  }
}
