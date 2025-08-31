import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';
import 'package:yallago_admin_dashboard/core/common%20widgets/surface_card.dart';
import 'package:yallago_admin_dashboard/cubit/customer/customer_cubit.dart';
import 'package:yallago_admin_dashboard/cubit/customer/customer_state.dart';

class CustomersFilterRow extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchSubmitted;

  const CustomersFilterRow({
    super.key,
    required this.searchController,
    required this.onSearchSubmitted,
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
                  child: BlocBuilder<CustomerCubit, CustomerState>(
                    buildWhen: (p, c) => p.tab != c.tab,
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
                          child: DropdownButton<String>(
                            value: state.tab,
                            items: const [
                              DropdownMenuItem(
                                value: 'all',
                                child: Text('All Customers'),
                              ),
                              DropdownMenuItem(
                                value: 'active',
                                child: Text('Active'),
                              ),
                              DropdownMenuItem(
                                value: 'inactive',
                                child: Text('Inactive'),
                              ),
                            ],
                            onChanged:
                                (v) =>
                                    v != null
                                        ? context.read<CustomerCubit>().setTab(
                                          v,
                                        )
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
                  hintText: 'Search customers by ID, name, email...',
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
