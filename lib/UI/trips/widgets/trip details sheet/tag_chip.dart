import 'package:flutter/material.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';

class TagChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onCopy;

  const TagChip({
    super.key,
    required this.icon,
    required this.label,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AdminColors.lightWhite,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AdminColors.lightGray),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AdminColors.secondaryText),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          if (onCopy != null) ...[
            const SizedBox(width: 4),
            InkWell(
              customBorder: const CircleBorder(),
              onTap: onCopy,
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.copy, size: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
