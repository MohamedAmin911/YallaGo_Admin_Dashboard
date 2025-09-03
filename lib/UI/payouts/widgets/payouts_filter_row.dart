import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';
import 'package:yallago_admin_dashboard/core/common%20widgets/surface_card.dart';
import 'package:yallago_admin_dashboard/cubit/payouts/payouts_cubit.dart';
import 'package:yallago_admin_dashboard/cubit/payouts/payouts_state.dart';

class PayoutsFilterRow extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String>? onSearchSubmitted;

  const PayoutsFilterRow({
    super.key,
    required this.searchController,
    this.onSearchSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SurfaceCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Shortcuts(
                  shortcuts: {
                    LogicalKeySet(LogicalKeyboardKey.space):
                        const DoNothingAndStopPropagationIntent(),
                  },
                  child: BlocBuilder<PayoutsCubit, PayoutsState>(
                    buildWhen: (p, c) => p.filter != c.filter,
                    builder: (context, state) {
                      return Container(
                        height: 34,
                        decoration: BoxDecoration(
                          border: Border.all(color: AdminColors.lightGray),
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<PayoutFilter>(
                            value: state.filter,
                            items:
                                PayoutFilter.values.map((filter) {
                                  return DropdownMenuItem<PayoutFilter>(
                                    value: filter,
                                    child: Text(filter.label),
                                  );
                                }).toList(),
                            onChanged:
                                (v) =>
                                    v != null
                                        ? context
                                            .read<PayoutsCubit>()
                                            .setFilter(v)
                                        : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 360,
          child: SurfaceCard(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 44,
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Search payouts by ID, driver, amount...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                onSubmitted: onSearchSubmitted,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
