// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';

import 'package:yallago_admin_dashboard/cubit/payouts/payouts_cubit.dart';
import 'package:yallago_admin_dashboard/models/payout_request.dart';

// Reuse your existing UI atoms used in DriverReviewSheet
import 'package:yallago_admin_dashboard/UI/drivers/widgets/driver%20details%20sheet/section_card.dart';
import 'package:yallago_admin_dashboard/UI/drivers/widgets/driver%20details%20sheet/status_pill.dart';
import 'package:yallago_admin_dashboard/UI/drivers/widgets/driver%20details%20sheet/utils.dart';
import 'package:yallago_admin_dashboard/UI/trips/widgets/trip%20details%20sheet/tag_chip.dart';

class PayoutReviewSheet extends StatefulWidget {
  final PayoutRequest req;
  final String adminUid; // required to call approve/reject

  const PayoutReviewSheet({
    super.key,
    required this.req,
    required this.adminUid,
  });

  @override
  State<PayoutReviewSheet> createState() => _PayoutReviewSheetState();
}

class _PayoutReviewSheetState extends State<PayoutReviewSheet> {
  bool _busy = false;

  PayoutRequest get p => widget.req;

  @override
  Widget build(BuildContext context) {
    final amount = (p.amountCents / 100).toStringAsFixed(2);
    final currency = p.currency.toUpperCase();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: icon/avatar + title + status + ID chips
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Visual placeholder (like driver avatar area)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 200,
                        height: 200,
                        color: Colors.grey.shade100,
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 80,
                          color: AdminColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title: Driver name + amount
                          Text(
                            '${p.driverName.isNotEmpty == true ? p.driverName : "Driver"} • $amount $currency',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StatusPill(status: p.status),
                              const SizedBox(height: 8),
                              // Copyable chips
                              TagChip(
                                icon: Icons.payment_outlined,
                                label: 'Payout: ${p.id}',
                                onCopy:
                                    () => DriverReviewUtils.copyToClipboard(
                                      context,
                                      p.id,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              TagChip(
                                icon: Icons.badge_outlined,
                                label: 'Driver: ${p.driverUid}',
                                onCopy:
                                    () => DriverReviewUtils.copyToClipboard(
                                      context,
                                      p.driverUid,
                                    ),
                              ),
                              if (p.driverStripeAccountId.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                TagChip(
                                  icon: Icons.account_balance_rounded,
                                  label: 'Stripe: ${p.driverStripeAccountId}',
                                  onCopy:
                                      () => DriverReviewUtils.copyToClipboard(
                                        context,
                                        p.driverStripeAccountId,
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

                // Two-column responsive content like DriverReviewSheet
                LayoutBuilder(
                  builder: (context, c) {
                    final tight = c.maxWidth < 700;

                    if (tight) {
                      return Column(
                        children: [
                          SectionCard(
                            title: 'Payout Information',
                            child: _PayoutInfo(p: p),
                          ),
                          const SizedBox(height: 12),
                          SectionCard(
                            title: 'Driver Information',
                            child: _DriverInfo(p: p),
                          ),
                          const SizedBox(height: 12),
                          SectionCard(
                            title: 'Stripe Transactions',
                            child: _StripeInfo(p: p),
                          ),
                          const SizedBox(height: 12),
                          SectionCard(
                            title: 'Actions',
                            child: _ActionsRow(
                              status: p.status,
                              busy: _busy,
                              onApprove: () => _approve(context),
                              onReject: () => _reject(context),
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
                                title: 'Payout Information',
                                child: _PayoutInfo(p: p),
                              ),
                              const SizedBox(height: 12),
                              SectionCard(
                                title: 'Driver Information',
                                child: _DriverInfo(p: p),
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
                                title: 'Stripe Transactions',
                                child: _StripeInfo(p: p),
                              ),
                              const SizedBox(height: 12),
                              SectionCard(
                                title: 'Actions',
                                child: _ActionsRow(
                                  status: p.status,
                                  busy: _busy,
                                  onApprove: () => _approve(context),
                                  onReject: () => _reject(context),
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

  Future<void> _approve(BuildContext context) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await context.read<PayoutsCubit>().approve(
        widget.req,
        widget.adminUid,
        createBankPayout: true,
      );
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payout approved & executed')),
        );
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

  Future<void> _reject(BuildContext context) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await context.read<PayoutsCubit>().reject(
        widget.req.id,
        widget.adminUid,
        reason: 'Admin rejected',
      );
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Payout rejected')));
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

// ===== Blocks used inside SectionCard(s) =====

class _PayoutInfo extends StatelessWidget {
  const _PayoutInfo({required this.p});
  final PayoutRequest p;

  @override
  Widget build(BuildContext context) {
    return _InfoTable(
      rows: [
        _info('Status', p.status),
        _info(
          'Amount',
          '${(p.amountCents / 100).toStringAsFixed(2)} ${p.currency.toUpperCase()}',
        ),
        _info('Created', _fmtTs(p.createdAt)),
        if (p.approvedAt != null) _info('Approved At', _fmtTs(p.approvedAt!)),
        if (p.processedAt != null)
          _info('Processed At', _fmtTs(p.processedAt!)),
        if ((p.approvedBy ?? '').isNotEmpty)
          _info('Approved By', p.approvedBy!),
        if (p.balanceSnapshotCents != null)
          _info(
            'Balance Snapshot (cents)',
            (p.balanceSnapshotCents! / 100).toString(),
          ),
        if (p.feeCents != null) _info('Fee (cents)', p.feeCents!.toString()),
        if ((p.note ?? '').isNotEmpty) _info('Note', p.note!),
        if ((p.failureReason ?? '').isNotEmpty)
          _info('Failure Reason', p.failureReason!),
      ],
    );
  }
}

class _DriverInfo extends StatelessWidget {
  const _DriverInfo({required this.p});
  final PayoutRequest p;

  @override
  Widget build(BuildContext context) {
    return _InfoTable(
      rows: [
        _info('Driver Name', p.driverName),
        _info('Driver UID', p.driverUid, copyable: true),
        _info('Stripe Account', p.driverStripeAccountId, copyable: true),
      ],
    );
  }
}

class _StripeInfo extends StatelessWidget {
  const _StripeInfo({required this.p});
  final PayoutRequest p;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoTable(
          rows: [
            _info(
              'Transfer Id',
              p.transferId ?? '-',
              copyable: p.transferId != null,
            ),
            _info('Payout Id', p.payoutId ?? '-', copyable: p.payoutId != null),
          ],
        ),
        const SizedBox(height: 8),
        // Optional quick links to Stripe (test mode)
        Row(
          children: [
            if ((p.transferId ?? '').isNotEmpty)
              TextButton.icon(
                onPressed:
                    () => DriverReviewUtils.openUrl(
                      'https://dashboard.stripe.com/test/transfers/${p.transferId}',
                    ),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('View transfer in Stripe'),
              ),
            if ((p.payoutId ?? '').isNotEmpty)
              TextButton.icon(
                onPressed:
                    () => DriverReviewUtils.openUrl(
                      'https://dashboard.stripe.com/test/payouts/${p.payoutId}',
                    ),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('View payout in Stripe'),
              ),
          ],
        ),
      ],
    );
  }
}

class _ActionsRow extends StatelessWidget {
  final String status;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final bool busy;

  const _ActionsRow({
    required this.status,
    required this.onApprove,
    required this.onReject,
    required this.busy,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = status == 'pending';
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: isPending && !busy ? onApprove : null,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Approve & Pay'),
        ),
        const SizedBox(width: 12),
        TextButton.icon(
          onPressed: isPending && !busy ? onReject : null,
          icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
          label: const Text(
            'Reject',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
        if (busy) ...[
          const SizedBox(width: 12),
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ],
    );
  }
}

// ===== Small helpers =====

class _InfoTable extends StatelessWidget {
  final List<_InfoRow> rows;
  const _InfoTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(children: rows.map((r) => _InfoLine(row: r)).toList());
  }
}

class _InfoLine extends StatelessWidget {
  final _InfoRow row;
  const _InfoLine({required this.row});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(row.label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    row.value,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (row.copyable)
                  IconButton(
                    tooltip: 'Copy',
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed:
                        () => DriverReviewUtils.copyToClipboard(
                          context,
                          row.value,
                        ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  final bool copyable;
  _InfoRow(this.label, this.value, {this.copyable = false});
}

_InfoRow _info(String label, String value, {bool copyable = false}) =>
    _InfoRow(label, value, copyable: copyable);

String _fmtTs(dynamic ts) {
  try {
    // Firestore Timestamp
    return ts.toDate().toString();
  } catch (_) {
    return ts?.toString() ?? '-';
  }
}
