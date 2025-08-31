import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yallago_admin_dashboard/UI/trips/widgets/trip%20details%20sheet/info_block_addresses.dart';
import 'package:yallago_admin_dashboard/UI/trips/widgets/trip%20details%20sheet/info_block_meta.dart';
import 'package:yallago_admin_dashboard/UI/trips/widgets/trip%20details%20sheet/tag_chip.dart';
import 'package:yallago_admin_dashboard/UI/trips/widgets/trip%20details%20sheet/timeline_compact.dart';
import 'package:yallago_admin_dashboard/UI/trips/widgets/trip%20details%20sheet/utils.dart';
import 'package:yallago_admin_dashboard/UI/trips/widgets/trips%20tab/trip_like_model.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';
import 'package:yallago_admin_dashboard/core/common%20widgets/payment_chip.dart';
import 'package:yallago_admin_dashboard/core/common%20widgets/status_chip.dart';
import 'package:yallago_admin_dashboard/core/common%20widgets/surface_card.dart';

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
                StatusChip(label: TripDetailsUtils.prettyStatus(trip.status)),
              ],
            ),
            const SizedBox(height: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (trip.paymentStatus != null)
                  Row(
                    children: [
                      PaymentChip(
                        label: TripDetailsUtils.prettyPayment(
                          trip.paymentStatus!,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TagChip(icon: Icons.payments_rounded, label: fareStr),
                    ],
                  ),

                TagChip(
                  icon: Icons.confirmation_number_outlined,
                  label: 'Trip: ${trip.id}',
                  onCopy:
                      () => TripDetailsUtils.copyToClipboard(context, trip.id),
                ),
                TagChip(
                  icon: Icons.person_outline,
                  label: 'Customer: ${trip.customerUid}',
                  onCopy:
                      () => TripDetailsUtils.copyToClipboard(
                        context,
                        trip.customerUid,
                      ),
                ),
                if (trip.driverUid != null &&
                    trip.driverUid!.trim().isNotEmpty &&
                    trip.driverUid! != '-')
                  TagChip(
                    icon: Icons.local_taxi_outlined,
                    label: 'Driver: ${trip.driverUid}',
                    onCopy:
                        () => TripDetailsUtils.copyToClipboard(
                          context,
                          trip.driverUid!,
                        ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            SurfaceCard(
              child: LayoutBuilder(
                builder: (context, c) {
                  final tight = c.maxWidth < 640;
                  if (tight) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InfoBlockAddresses(trip: trip),
                        const Divider(height: 24),
                        InfoBlockMeta(fareStr: fareStr, requested: requested),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: InfoBlockAddresses(trip: trip)),
                      const VerticalDivider(width: 32),
                      Expanded(
                        child: InfoBlockMeta(
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

            LayoutBuilder(
              builder: (context, c) {
                final tight = c.maxWidth < 640;
                if (tight) {
                  return Column(
                    children: [
                      SurfaceCard(
                        child: TimelineCompact(
                          status: trip.status,
                          requested: trip.requestedAt,
                        ),
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      child: SurfaceCard(
                        child: TimelineCompact(
                          status: trip.status,
                          requested: trip.requestedAt,
                        ),
                      ),
                    ),
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
}
