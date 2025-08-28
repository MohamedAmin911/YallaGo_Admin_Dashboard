import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/trip.dart';

/// Bottom sheet that shows a single trip details in a clean, modern layout.
/// - No external deps (url_launcher optional; see comment)
/// - Uses current Theme for colors (works with your Admin theme)
class TripDetailsSheet extends StatelessWidget {
  final Trip trip;

  /// Optional action for future (refund/dispute).
  final VoidCallback? onRefund;

  const TripDetailsSheet({super.key, required this.trip, this.onRefund});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final dateFmt = DateFormat('yyyy-MM-dd HH:mm');

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: title + status chip
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Trip Details #${trip.id}',
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _statusChip(trip.status, cs),
              ],
            ),
            const SizedBox(height: 16),

            // Trip basic info
            _SectionCard(
              title: 'Trip Overview',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kv('Customer', trip.customerUid),
                  _kv('Driver', trip.driverUid ?? '-'),
                  _kv('Pickup', trip.pickupAddress),
                  _kv('Destination', trip.destinationAddress),
                  _kv('Fare', 'EGP ${trip.estimatedFare.toStringAsFixed(2)}'),
                  _kv(
                    'Requested At',
                    trip.requestedAt != null
                        ? dateFmt.format(trip.requestedAt!)
                        : '-',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Payment section
            _SectionCard(
              title: 'Payment Details',
              trailing:
                  trip.paymentStatus != null
                      ? _paymentChip(trip.paymentStatus!, cs)
                      : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kv('Status', trip.paymentStatus ?? '-'),
                  _kv('PaymentIntent', trip.paymentIntentId ?? '-'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Optional: open in Stripe (uncomment if url_launcher added)
                      // ElevatedButton.icon(
                      //   onPressed: trip.paymentIntentId == null ? null : () async {
                      //     final url = Uri.parse('https://dashboard.stripe.com/test/payments/${trip.paymentIntentId}');
                      //     if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
                      //   },
                      //   icon: const Icon(Icons.open_in_new),
                      //   label: const Text('Open in Stripe'),
                      // ),
                      OutlinedButton.icon(
                        onPressed: () {
                          if (trip.paymentIntentId == null) return;
                          // You can add Clipboard.setData here to copy the id.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('PaymentIntent ID copied'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_all_rounded),
                        label: const Text('Copy PaymentIntent ID'),
                      ),
                      if (onRefund != null)
                        TextButton.icon(
                          onPressed: onRefund,
                          icon: const Icon(Icons.reply_rounded),
                          label: const Text('Refund (coming soon)'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Minimal timeline (requested -> completed)
            _SectionCard(
              title: 'Timeline',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bullet(
                    'Requested',
                    trip.requestedAt != null
                        ? dateFmt.format(trip.requestedAt!)
                        : '—',
                  ),
                  _bullet(
                    'Completed',
                    '—',
                  ), // add completedAt to Trip model if available
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Key–Value row
  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$k:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }

  // Bullet line for the timeline section
  Widget _bullet(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 8, color: Colors.black38),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Status chip (trip)
  Widget _statusChip(String s, ColorScheme cs) {
    Color c = Colors.grey;
    if (s == 'completed') c = Colors.green;
    if (s == 'searching' || s == 'in_progress' || s == 'paid') c = Colors.blue;
    if (s == 'canceled') c = Colors.red;
    return Chip(
      label: Text(s),
      backgroundColor: c.withOpacity(0.14),
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
    );
  }

  // Payment chip
  static Widget _paymentChip(String s, ColorScheme cs) {
    final c = s == 'succeeded' ? Colors.green : Colors.orange;
    return Chip(
      label: Text(s),
      backgroundColor: c.withOpacity(0.14),
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
    );
  }
}

/// Small reusable section card used across the bottom sheet.
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surface;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + optional trailing (e.g., payment chip)
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
