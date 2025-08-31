import 'package:flutter/material.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';

class InfoBlockMeta extends StatelessWidget {
  final String fareStr;
  final String requested;

  const InfoBlockMeta({
    super.key,
    required this.fareStr,
    required this.requested,
  });

  Widget _line(
    String label,
    String value, {
    bool bold = false,
    bool right = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AdminColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
            ),
            textAlign: right ? TextAlign.right : TextAlign.left,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _line('Total Fare:', fareStr, bold: true, right: true),
        _line('Requested At:', requested, right: true),
      ],
    );
  }
}
