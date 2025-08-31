import 'package:flutter/material.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';
import 'package:yallago_admin_dashboard/models/customer.dart';

class RideHistory extends StatelessWidget {
  final List<SearchHistoryItem> history;

  const RideHistory({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(
        child: Text(
          'No ride history',
          style: TextStyle(color: AdminColors.secondaryText),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AdminColors.lightWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AdminColors.lightGray),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.title != null)
                Text(
                  item.title!,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              if (item.address != null)
                Text(
                  item.address!,
                  style: const TextStyle(color: AdminColors.secondaryText),
                ),
              if (item.timestamp != null)
                Text(
                  '${item.timestamp!.toDate().toString().split(' ')[0]}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AdminColors.secondaryText,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
