import 'package:flutter/material.dart';
import 'package:yallago_admin_dashboard/UI/customers/widgets/customer%20details%20sheet/profile_info.dart';
import 'package:yallago_admin_dashboard/UI/customers/widgets/customer%20details%20sheet/ride_history.dart';
import 'package:yallago_admin_dashboard/UI/customers/widgets/customer%20details%20sheet/section_card.dart';
import 'package:yallago_admin_dashboard/UI/customers/widgets/customer%20details%20sheet/utils.dart';
import 'package:yallago_admin_dashboard/UI/trips/widgets/trip%20details%20sheet/tag_chip.dart';
import 'package:yallago_admin_dashboard/models/customer.dart';

class CustomerDetailsSheet extends StatelessWidget {
  final Customer customer;

  const CustomerDetailsSheet({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final c = customer;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Avatar + name + info chips
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child:
                          (c.profileImageUrl != null &&
                                  c.profileImageUrl!.isNotEmpty)
                              ? Image.network(
                                c.profileImageUrl!,
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              )
                              : const Icon(Icons.person, size: 200),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TagChip(
                                icon: Icons.badge_outlined,
                                label: 'Customer: ${c.id}',
                                onCopy:
                                    () => CustomerDetailsUtils.copyToClipboard(
                                      context,
                                      c.id,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              if ((c.stripeCustomerId ?? '').isNotEmpty) ...[
                                TagChip(
                                  icon: Icons.account_balance_rounded,
                                  label: 'Stripe: ${c.stripeCustomerId}',
                                  onCopy:
                                      () =>
                                          CustomerDetailsUtils.copyToClipboard(
                                            context,
                                            c.stripeCustomerId!,
                                          ),
                                ),
                                const SizedBox(height: 8),
                              ],

                              TagChip(
                                icon: Icons.directions_car_rounded,
                                label: 'Rides: ${c.totalRides}',
                                onCopy: null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final tight = constraints.maxWidth < 700;

                    if (tight) {
                      return Column(
                        children: [
                          SectionCard(
                            title: 'Profile Information',
                            child: ProfileInfo(customer: c),
                          ),
                          const SizedBox(height: 12),
                          SectionCard(
                            title: 'Ride History',
                            child: RideHistory(history: c.searchHistory),
                          ),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column
                        Expanded(
                          child: SectionCard(
                            title: 'Profile Information',
                            child: ProfileInfo(customer: c),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Right column
                        Expanded(
                          child: SectionCard(
                            title: 'Ride History',
                            child: RideHistory(history: c.searchHistory),
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
}
