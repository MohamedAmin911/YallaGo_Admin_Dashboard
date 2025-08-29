import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:yallago_admin_dashboard/UI/trips/screens/trips_tab.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';
import 'package:yallago_admin_dashboard/core/payment_chip.dart';
import 'package:yallago_admin_dashboard/core/status_chip.dart';
import 'package:yallago_admin_dashboard/core/surface_card.dart';

class TripDetailsSheet extends StatelessWidget {
  final TripLike trip;
  final VoidCallback? onRefund;
  final VoidCallback? onDispute;

  const TripDetailsSheet({
    super.key,
    required this.trip,
    this.onRefund,
    this.onDispute,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final dateFmt = DateFormat('yyyy-MM-dd HH:mm');
    final fareStr = 'EGP ${trip.estimatedFare.toStringAsFixed(2)}';
    final requested =
        trip.requestedAt == null ? '—' : dateFmt.format(trip.requestedAt!);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: title + status
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Trip Details #${trip.id}',
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                StatusChip(label: _prettyStatus(trip.status)),
              ],
            ),
            const SizedBox(height: 12),

            // Summary tags (now includes Trip ID, Customer ID, Driver ID copies)
            Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (trip.paymentStatus != null)
                  Row(
                    children: [
                      PaymentChip(label: _prettyPayment(trip.paymentStatus!)),
                      const SizedBox(width: 8),
                      _TagChip(icon: Icons.payments_rounded, label: fareStr),
                    ],
                  ),

                _TagChip(
                  icon: Icons.confirmation_number_outlined,
                  label: 'Trip: ${trip.id}',
                  onCopy: () => _copy(context, trip.id),
                ),
                _TagChip(
                  icon: Icons.person_outline,
                  label: 'Customer: ${trip.customerUid}',
                  onCopy: () => _copy(context, trip.customerUid),
                ),
                if (trip.driverUid != null &&
                    trip.driverUid!.trim().isNotEmpty &&
                    trip.driverUid! != '-')
                  _TagChip(
                    icon: Icons.local_taxi_outlined,
                    label: 'Driver: ${trip.driverUid}',
                    onCopy: () => _copy(context, trip.driverUid!),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Info card (two blocks: addresses + meta)
            SurfaceCard(
              child: LayoutBuilder(
                builder: (context, c) {
                  final tight = c.maxWidth < 640;
                  if (tight) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoBlockAddresses(trip: trip),
                        const Divider(height: 24),
                        _InfoBlockMeta(fareStr: fareStr, requested: requested),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _InfoBlockAddresses(trip: trip)),
                      const VerticalDivider(width: 32),
                      Expanded(
                        child: _InfoBlockMeta(
                          fareStr: fareStr,
                          requested: requested,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Compact timeline + payment (side-by-side on wide)
            LayoutBuilder(
              builder: (context, c) {
                final tight = c.maxWidth < 640;
                if (tight) {
                  return Column(
                    children: [
                      SurfaceCard(
                        child: _TimelineCompact(
                          status: trip.status,
                          requested: trip.requestedAt,
                        ),
                      ),
                      // const SizedBox(height: 12),
                      // SurfaceCard(child: _PaymentDetailsCard(trip: trip)),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      child: SurfaceCard(
                        child: _TimelineCompact(
                          status: trip.status,
                          requested: trip.requestedAt,
                        ),
                      ),
                    ),
                    // const SizedBox(width: 12),
                    // Expanded(
                    //   child: SurfaceCard(
                    //     child: _PaymentDetailsCard(trip: trip),
                    //   ),
                    // ),
                  ],
                );
              },
            ),

            const SizedBox(height: 12),

            // Actions
            SurfaceCard(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AdminColors.danger,
                        side: const BorderSide(color: AdminColors.danger),
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: onDispute ?? () {},
                      child: const Text(
                        'Dispute Trip',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.primary,
                        foregroundColor: AdminColors.primaryText,
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: onRefund ?? () {},
                      child: const Text(
                        'Refund Trip',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pretty labels
  static String _prettyStatus(String s) {
    final l = s.toLowerCase();
    if (l == 'in_progress') return 'Ongoing';
    return l.isEmpty ? '-' : l[0].toUpperCase() + l.substring(1);
  }

  static String _prettyPayment(String s) {
    final l = s.toLowerCase();
    if (l == 'succeeded') return 'Paid';
    if (l == 'pending') return 'Pending';
    return l.isEmpty ? '-' : l[0].toUpperCase() + l.substring(1);
  }

  static Future<void> _copy(BuildContext context, String v) async {
    await Clipboard.setData(ClipboardData(text: v));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }
}

// Address block
class _InfoBlockAddresses extends StatelessWidget {
  final TripLike trip;
  const _InfoBlockAddresses({required this.trip});

  @override
  Widget build(BuildContext context) {
    final label = const TextStyle(
      color: AdminColors.secondaryText,
      fontWeight: FontWeight.w600,
    );
    final value = const TextStyle(fontWeight: FontWeight.w700);

    Widget row(IconData icon, String k, String v) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AdminColors.secondaryText),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(k, style: label),
                const SizedBox(height: 4),
                Text(v, style: value),
              ],
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // row(Icons.person_outline, 'Customer ID', trip.customerUid),
        // row(Icons.local_taxi_outlined, 'Driver ID', trip.driverUid ?? '—'),
        row(Icons.my_location, 'Pickup', trip.pickupAddress),
        row(Icons.location_on, 'Destination', trip.destinationAddress),
      ],
    );
  }
}

// Fare / Requested
class _InfoBlockMeta extends StatelessWidget {
  final String fareStr;
  final String requested;
  const _InfoBlockMeta({required this.fareStr, required this.requested});

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

// Timeline
class _TimelineCompact extends StatelessWidget {
  final String status;
  final DateTime? requested;
  const _TimelineCompact({required this.status, required this.requested});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy-MM-dd HH:mm');

    Widget bullet(
      String label,
      String value, {
      bool active = false,
      bool last = false,
    }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color:
                        active ? AdminColors.secondary : AdminColors.lightGray,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!last)
                  Container(
                    width: 2,
                    height: 22,
                    color: AdminColors.lightGray.withOpacity(0.7),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    value,
                    style: const TextStyle(color: AdminColors.secondaryText),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final l = status.toLowerCase();
    final ongoing = l == 'in_progress' || l == 'ongoing';
    final completed = l == 'completed';

    return Column(
      children: [
        bullet(
          'Requested',
          requested == null ? '—' : fmt.format(requested!),
          active: true,
        ),
        bullet(
          'Ongoing',
          ongoing ? 'Driver en route / trip running' : '—',
          active: ongoing,
        ),
        bullet(
          'Completed',
          completed ? 'Trip finished' : '—',
          active: completed,
          last: true,
        ),
      ],
    );
  }
}

// Payment card (status + PaymentIntent copy button if available)
// class _PaymentDetailsCard extends StatelessWidget {
//   final TripLike trip;
//   const _PaymentDetailsCard({required this.trip});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             const Expanded(
//               child: Text(
//                 'Payment Details',
//                 style: TextStyle(fontWeight: FontWeight.w800),
//               ),
//             ),
//             if (trip.paymentStatus != null)
//               PaymentChip(
//                 label: TripDetailsSheet._prettyPayment(trip.paymentStatus!),
//               ),
//           ],
//         ),
//         // const SizedBox(height: 10),
//         // kv(
//         //   'Payment Status',
//         //   trip.paymentStatus == null
//         //       ? '—'
//         //       : TripDetailsSheet._prettyPayment(trip.paymentStatus!),
//         // ),
//       ],
//     );
//   }
// }

// Summary tag chip with optional copy
class _TagChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onCopy;

  const _TagChip({required this.icon, required this.label, this.onCopy});

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
