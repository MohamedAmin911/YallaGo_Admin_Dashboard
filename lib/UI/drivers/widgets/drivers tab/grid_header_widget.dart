import 'package:flutter/material.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';

Widget buildGridHeader(
  BuildContext context,
  String text, {
  bool alignRight = false,
}) {
  final style = Theme.of(context).textTheme.labelLarge?.copyWith(
    color: AdminColors.secondaryText,
    fontWeight: FontWeight.w700,
  );
  return Container(
    alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Text(text, style: style),
  );
}

// Column width constants
const double kWDriverId = 300;
const double kWName = 260;
const double kWPhone = 160;
const double kWEmail = 260;
const double kWStatus = 160;
const double kWBalance = 160;
const double kWActions = 200;
