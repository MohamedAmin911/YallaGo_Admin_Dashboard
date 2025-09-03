import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yallago_admin_dashboard/cubit/payouts/payouts_cubit.dart';
import 'package:yallago_admin_dashboard/cubit/payouts/payouts_state.dart';
import 'package:yallago_admin_dashboard/repo/payouts_repo.dart';
import 'package:yallago_admin_dashboard/UI/payouts/widgets/payouts_filter_row.dart';
import 'package:yallago_admin_dashboard/UI/payouts/widgets/payouts_data_grid.dart';

class PayoutsTab extends StatefulWidget {
  final String pipedreamBase;
  final String adminUid;
  const PayoutsTab({
    super.key,
    required this.pipedreamBase,
    required this.adminUid,
  });

  @override
  State<PayoutsTab> createState() => _PayoutsTabState();
}

class _PayoutsTabState extends State<PayoutsTab> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchCtrl.text.trim();
    context.read<PayoutsCubit>().setQuery(query);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              PayoutsCubit(PayoutsRepository(base: widget.pipedreamBase))
                ..start(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PayoutsFilterRow(
              searchController: _searchCtrl,
              onSearchSubmitted: (query) {
                context.read<PayoutsCubit>().setQuery(query);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocConsumer<PayoutsCubit, PayoutsState>(
                listener: (context, state) {
                  if (state.error != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.error!)));
                  }
                },
                builder: (context, state) {
                  if (state.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return PayoutsDataGrid(adminUid: widget.adminUid);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
