import 'package:flutter/material.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';
import 'package:yallago_admin_dashboard/models/driver.dart';

class ProfileInfo extends StatelessWidget {
  final Driver driver;

  const ProfileInfo({super.key, required this.driver});

  Widget _kv(String k, String v, {bool bold = true}) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$k:',
            style: const TextStyle(
              color: AdminColors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            v.isEmpty ? '—' : v,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final balance = 'EGP ${(driver.balance).toStringAsFixed(2)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _kv('Name', driver.fullName),
        _kv('Phone', driver.phone ?? '—'),
        _kv('Email', driver.email ?? '—'),
        _kv('Balance', balance),
        _kv('Rating', driver.rating.toString()),
        _kv('Stripe Account', driver.stripeAccountId ?? '—', bold: false),
      ],
    );
  }
}
