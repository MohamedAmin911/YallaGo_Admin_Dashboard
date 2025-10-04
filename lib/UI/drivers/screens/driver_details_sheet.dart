// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yallago_admin_dashboard/UI/drivers/widgets/driver%20details%20sheet/actions_row.dart';
import 'package:yallago_admin_dashboard/UI/drivers/widgets/driver%20details%20sheet/docs_grid.dart';
import 'package:yallago_admin_dashboard/UI/drivers/widgets/driver%20details%20sheet/profile_info.dart';
import 'package:yallago_admin_dashboard/UI/drivers/widgets/driver%20details%20sheet/section_card.dart';
import 'package:yallago_admin_dashboard/UI/drivers/widgets/driver%20details%20sheet/status_pill.dart';
import 'package:yallago_admin_dashboard/UI/drivers/widgets/driver%20details%20sheet/utils.dart';
import 'package:yallago_admin_dashboard/UI/drivers/widgets/driver%20details%20sheet/vehicle_info.dart';
import 'package:yallago_admin_dashboard/UI/trips/widgets/trip%20details%20sheet/tag_chip.dart';
import 'package:yallago_admin_dashboard/models/driver.dart';

class DriverReviewSheet extends StatefulWidget {
  final Driver driver;

  const DriverReviewSheet({super.key, required this.driver});

  @override
  State<DriverReviewSheet> createState() => _DriverReviewSheetState();
}

class _DriverReviewSheetState extends State<DriverReviewSheet> {
  bool _busy = false;

  Driver get d => widget.driver;

  @override
  Widget build(BuildContext context) {
    final docs = [
      ('National ID', d.nationalIdUrl),
      ('Driver License', d.driversLicenseUrl),
      ('Car License', d.carLicenseUrl),
      ('Criminal Record', d.criminalRecordUrl),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child:
                          (d.profileImageUrl != null &&
                                  d.profileImageUrl!.isNotEmpty)
                              ? Image.network(
                                d.profileImageUrl!,
                                width: 200,
                                height: 200,
                                fit: BoxFit.fitWidth,
                              )
                              : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StatusPill(status: d.status),
                              const SizedBox(height: 8),
                              TagChip(
                                icon: Icons.badge_outlined,
                                label: 'Driver: ${d.id}',
                                onCopy:
                                    () => DriverReviewUtils.copyToClipboard(
                                      context,
                                      d.id,
                                    ),
                              ),
                              if ((d.stripeAccountId ?? '').isNotEmpty) ...[
                                const SizedBox(height: 8),
                                TagChip(
                                  icon: Icons.account_balance_rounded,
                                  label: 'Stripe: ${d.stripeAccountId}',
                                  onCopy:
                                      () => DriverReviewUtils.copyToClipboard(
                                        context,
                                        d.stripeAccountId!,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_busy)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                LayoutBuilder(
                  builder: (context, c) {
                    final tight = c.maxWidth < 700;

                    if (tight) {
                      return Column(
                        children: [
                          SectionCard(
                            title: 'Profile Information',
                            child: ProfileInfo(driver: d),
                          ),
                          const SizedBox(height: 12),
                          SectionCard(
                            title: 'Vehicle Information',
                            child: VehicleInfo(driver: d),
                          ),
                          const SizedBox(height: 12),
                          SectionCard(
                            title: 'KYC Documents',
                            child: DocsGrid(docs: docs),
                          ),
                          const SizedBox(height: 12),
                          SectionCard(
                            title: 'Actions',
                            child: ActionsRow(
                              status: d.status,
                              onApprove: () => _setStatus(context, 'active'),
                              onReject: () => _setStatus(context, 'rejected'),
                              onSuspend: () => _setStatus(context, 'suspended'),
                              onActivate: () => _setStatus(context, 'active'),
                              busy: _busy,
                            ),
                          ),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column
                        Expanded(
                          child: Column(
                            children: [
                              SectionCard(
                                title: 'Profile Information',
                                child: ProfileInfo(driver: d),
                              ),
                              const SizedBox(height: 12),
                              SectionCard(
                                title: 'Vehicle Information',
                                child: VehicleInfo(driver: d),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Right column
                        Expanded(
                          child: Column(
                            children: [
                              SectionCard(
                                title: 'KYC Documents',
                                child: DocsGrid(docs: docs),
                              ),
                              const SizedBox(height: 12),
                              SectionCard(
                                title: 'Actions',
                                child: ActionsRow(
                                  status: d.status,
                                  onApprove:
                                      () => _setStatus(context, 'active'),
                                  onReject:
                                      () => _setStatus(context, 'rejected'),
                                  onSuspend:
                                      () => _setStatus(context, 'suspended'),
                                  onActivate:
                                      () => _setStatus(context, 'active'),
                                  busy: _busy,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _setStatus(BuildContext context, String status) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await FirebaseFirestore.instance.collection('drivers').doc(d.id).update({
        'status': status,
        'statusUpdatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Driver $status')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
