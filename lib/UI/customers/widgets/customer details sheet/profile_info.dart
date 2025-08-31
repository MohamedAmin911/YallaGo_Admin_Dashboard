import 'package:flutter/material.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';
import 'package:yallago_admin_dashboard/models/customer.dart';

class ProfileInfo extends StatelessWidget {
  final Customer customer;

  const ProfileInfo({super.key, required this.customer});

  Widget _kv(String k, String v, {bool bold = true}) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
    final c = customer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _kv('Name', c.fullName),
        SizedBox(height: 8),
        _kv('Email', c.email ?? '—'),
        SizedBox(height: 8),
        _kv('Phone', c.phone ?? '—'),
        SizedBox(height: 8),
        _kv('Home Address', c.homeAddress ?? '—'),
        SizedBox(height: 8),
        _kv('User ID', c.uid),
        SizedBox(height: 8),
        _kv('Stripe ID', c.stripeCustomerId ?? '—', bold: false),
        SizedBox(height: 8),
        if (c.createdAt != null) ...[
          _kv('Member Since', c.createdAt!.toDate().toString().split(' ')[0]),
        ],
      ],
    );
  }
}
