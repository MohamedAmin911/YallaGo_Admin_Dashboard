import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yallago_admin_dashboard/cubit/payouts/payouts_cubit.dart';
import 'package:yallago_admin_dashboard/models/payout_request.dart';

class PayoutDetailsScreen extends StatelessWidget {
  final PayoutRequest req;
  final String adminUid;
  const PayoutDetailsScreen({
    super.key,
    required this.req,
    required this.adminUid,
  });

  @override
  Widget build(BuildContext context) {
    final canAct = req.status == 'pending';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payout Details'),
        actions: [
          TextButton(
            onPressed:
                canAct
                    ? () => context.read<PayoutsCubit>().reject(
                      req.id,
                      adminUid,
                      reason: 'Admin rejected',
                    )
                    : null,
            child: const Text(
              'Reject',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed:
                canAct
                    ? () => context.read<PayoutsCubit>().approve(
                      req,
                      adminUid,
                      createBankPayout: true,
                    )
                    : null,
            child: const Text('Approve & Pay'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('Overview', [
            _row('Status', req.status),
            _row(
              'Amount',
              '${(req.amountCents / 100).toStringAsFixed(2)} ${req.currency.toUpperCase()}',
            ),
            _row('Created', req.createdAt.toDate().toString()),
            if (req.approvedAt != null)
              _row('Approved At', req.approvedAt!.toDate().toString()),
            if (req.processedAt != null)
              _row('Processed At', req.processedAt!.toDate().toString()),
          ]),
          const SizedBox(height: 16),
          _section('Driver', [
            _row('Driver Name', req.driverName),
            _row('Driver UID', req.driverUid),
            _row('Stripe Account', req.driverStripeAccountId, copyable: true),
          ]),
          const SizedBox(height: 16),
          _section('Stripe', [
            _row(
              'Transfer Id',
              req.transferId ?? '-',
              copyable: req.transferId != null,
            ),
            _row(
              'Payout Id',
              req.payoutId ?? '-',
              copyable: req.payoutId != null,
            ),
          ]),
          const SizedBox(height: 16),
          _section('Meta', [
            _row(
              'Balance Snapshot (cents)',
              (req.balanceSnapshotCents ?? 0).toString(),
            ),
            _row('Fee (cents)', (req.feeCents ?? 0).toString()),
            _row('Approved By', req.approvedBy ?? '-'),
            if ((req.failureReason ?? '').isNotEmpty)
              _row('Failure Reason', req.failureReason!),
            if ((req.note ?? '').isNotEmpty) _row('Note', req.note!),
          ]),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (copyable)
                  IconButton(
                    tooltip: 'Copy',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: value));
                    },
                    icon: const Icon(Icons.copy, size: 18),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
