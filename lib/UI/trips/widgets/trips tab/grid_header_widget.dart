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

const double kWTripId = 210;
const double kWStatus = 120;
const double kWRider = 160;
const double kWDriver = 160;
const double kWPickup = 160;
const double kWDest = 160;
const double kWFare = 120;
const double kWPayment = 140;
const double kWRequestedAt = 170;
const double kWActions = 100;
