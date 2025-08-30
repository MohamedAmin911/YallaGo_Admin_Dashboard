import 'package:flutter/material.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';

class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const PillButton({super.key, required this.label, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: AdminColors.lightWhite,
        foregroundColor: AdminColors.primaryText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AdminColors.lightGray),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
