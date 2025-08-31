import 'package:flutter/material.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';

class ActionsRow extends StatelessWidget {
  final String status;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onSuspend;
  final VoidCallback onActivate;
  final bool busy;

  const ActionsRow({
    super.key,
    required this.status,
    required this.onApprove,
    required this.onReject,
    required this.onSuspend,
    required this.onActivate,
    required this.busy,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = status == 'pending_approval';
    final isActive = status == 'active';
    final isSusp = status == 'suspended';

    return Row(
      children: [
        if (isPending)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: busy ? null : onApprove,
              icon: const Icon(Icons.check),
              label: const Text(
                'Approve',
                style: TextStyle(color: AdminColors.bg),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primary,
                foregroundColor: AdminColors.primaryText,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        if (isPending) const SizedBox(width: 12),
        if (isPending)
          Expanded(
            child: ElevatedButton(
              onPressed: busy ? null : onReject,
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.danger,
                side: const BorderSide(color: AdminColors.danger),
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Reject',
                style: TextStyle(color: AdminColors.bg),
              ),
            ),
          ),
        if (!isPending && isActive) ...[
          Expanded(
            child: ElevatedButton(
              onPressed: busy ? null : onSuspend,
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.danger,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Suspend',
                style: TextStyle(color: AdminColors.bg),
              ),
            ),
          ),
        ],
        if (!isPending && isSusp) ...[
          Expanded(
            child: ElevatedButton(
              onPressed: busy ? null : onActivate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Activate',
                style: TextStyle(color: AdminColors.bg),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
