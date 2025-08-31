import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';

class TimelineCompact extends StatelessWidget {
  final String status;
  final DateTime? requested;

  const TimelineCompact({
    super.key,
    required this.status,
    required this.requested,
  });

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
