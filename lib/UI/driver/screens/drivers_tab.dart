import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yallago_admin_dashboard/UI/driver/widgets/driver_review_sheet.dart';
import 'package:yallago_admin_dashboard/cubit/driver/driver_cubit.dart';
import 'package:yallago_admin_dashboard/cubit/driver/driver_state.dart';
import '../../../models/driver.dart';

class DriversTab extends StatelessWidget {
  const DriversTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _DriversToolbar(),
        Divider(height: 1),
        Expanded(child: _DriversTable()),
      ],
    );
  }
}

class _DriversToolbar extends StatelessWidget {
  const _DriversToolbar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriversCubit, DriversState>(
      buildWhen: (p, c) => p.tab != c.tab || p.loading != c.loading,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Text('Status:'),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: state.tab,
                items: const [
                  DropdownMenuItem(
                    value: 'pending_approval',
                    child: Text('Pending approvals'),
                  ),
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(
                    value: 'suspended',
                    child: Text('Suspended'),
                  ),
                ],
                onChanged:
                    (v) =>
                        v != null
                            ? context.read<DriversCubit>().setTab(v)
                            : null,
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}

class _DriversTable extends StatelessWidget {
  const _DriversTable();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriversCubit, DriversState>(
      builder: (context, state) {
        if (state.loading)
          return const Center(child: CircularProgressIndicator());
        if (state.error != null)
          return Center(child: Text('Error: ${state.error}'));
        if (state.items.isEmpty) return const Center(child: Text('No drivers'));

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Driver ID')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Phone')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Balance')),
              DataColumn(label: Text('Actions')),
            ],
            rows: state.items.map((d) => row(context, d)).toList(),
          ),
        );
      },
    );
  }

  DataRow row(BuildContext context, Driver d) {
    return DataRow(
      cells: [
        DataCell(Text(d.id)),
        DataCell(Text(d.fullName)),
        DataCell(Text(d.phone ?? '-')),
        DataCell(Text(d.email ?? '-')),
        DataCell(Chip(label: Text(d.status))),
        DataCell(Text('EGP ${d.balance.toStringAsFixed(2)}')),
        DataCell(
          Row(
            children: [
              TextButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (context) => DriverReviewSheet(driver: d),
                  );
                },
                child: const Text('Review'),
              ),
              const SizedBox(width: 8),
              if (d.status == 'active')
                TextButton(
                  onPressed:
                      () => context.read<DriversCubit>().repo.setStatus(
                        d.id,
                        'suspended',
                      ),
                  child: const Text('Suspend'),
                ),
              if (d.status == 'suspended')
                TextButton(
                  onPressed:
                      () => context.read<DriversCubit>().repo.setStatus(
                        d.id,
                        'active',
                      ),
                  child: const Text('Activate'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
