import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:yallago_admin_dashboard/UI/driver/widgets/driver_review_sheet.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';
import 'package:yallago_admin_dashboard/core/common%20widgets/pill_button.dart';
import 'package:yallago_admin_dashboard/core/common%20widgets/status_chip.dart';
import 'package:yallago_admin_dashboard/core/common%20widgets/surface_card.dart';

import 'package:yallago_admin_dashboard/cubit/driver/driver_cubit.dart';
import 'package:yallago_admin_dashboard/cubit/driver/driver_state.dart';
import 'package:yallago_admin_dashboard/models/driver.dart';

// Fixed column widths (pixel-perfect alignment like Trips)
const double kWDriverId = 300;
const double kWName = 260;
const double kWPhone = 160;
const double kWEmail = 260;
const double kWStatus = 160;
const double kWBalance = 160;
const double kWActions = 200;

class DriversTab extends StatefulWidget {
  const DriversTab({super.key});

  @override
  State<DriversTab> createState() => _DriversTabState();
}

class _DriversTabState extends State<DriversTab> {
  final _searchRightCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filters row: left (status) / right (search)
          Row(
            children: [
              Expanded(
                child: SurfaceCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      // Status dropdown (rounded, like Trips)
                      Shortcuts(
                        shortcuts: {
                          LogicalKeySet(LogicalKeyboardKey.space):
                              const DoNothingAndStopPropagationIntent(),
                        },
                        child: BlocBuilder<DriversCubit, DriversState>(
                          buildWhen: (p, c) => p.tab != c.tab,
                          builder: (context, state) {
                            return Container(
                              height: 34,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AdminColors.lightGray,
                                ),
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: state.tab,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'pending_approval',
                                      child: Text('Pending approvals'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'active',
                                      child: Text('Active'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'suspended',
                                      child: Text('Suspended'),
                                    ),
                                  ],
                                  onChanged:
                                      (v) =>
                                          v != null
                                              ? context
                                                  .read<DriversCubit>()
                                                  .setTab(v)
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
              // Right search (same height, rounded card)
              SizedBox(
                width: 360,
                child: SurfaceCard(
                  padding: EdgeInsets.zero,
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      controller: _searchRightCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Search drivers by ID, name, phone…',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (q) {
                        // TODO: wire to DriversCubit if you want server-side search
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Table card with Syncfusion DataGrid
          const Expanded(child: _DriversGridCard()),
        ],
      ),
    );
  }
}

class _DriversGridCard extends StatefulWidget {
  const _DriversGridCard();

  @override
  State<_DriversGridCard> createState() => _DriversGridCardState();
}

class _DriversGridCardState extends State<_DriversGridCard> {
  late DriversGridSource _source;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: BlocBuilder<DriversCubit, DriversState>(
        builder: (context, state) {
          if (!_initialized) {
            _source = DriversGridSource(
              items: state.items,
              onReview: (vm) => _openReview(context, vm),
              onToggleStatus: (vm) => _toggleStatus(context, vm),
            );
            _initialized = true;
          } else {
            _source.update(state.items);
          }

          if (state.loading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: AdminColors.primary),
              ),
            );
          }
          if (state.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error: ${state.error}'),
              ),
            );
          }
          if (state.items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No drivers'),
              ),
            );
          }

          return SfDataGridTheme(
            data: SfDataGridThemeData(
              gridLineStrokeWidth: 1,
              gridLineColor: AdminColors.lightGray.withOpacity(0.6),
              headerColor: Colors.white,
              headerHoverColor: Colors.white,
              rowHoverColor: AdminColors.lightWhite,
            ),
            child: SfDataGrid(
              source: _source,
              columnWidthMode: ColumnWidthMode.none,
              headerRowHeight: 52,
              rowHeight: 64,
              gridLinesVisibility: GridLinesVisibility.horizontal,
              headerGridLinesVisibility: GridLinesVisibility.horizontal,
              allowSorting: false,
              selectionMode: SelectionMode.none,
              columns: [
                GridColumn(
                  columnName: 'driverId',
                  width: kWDriverId,
                  label: _header(context, 'Driver ID'),
                ),
                GridColumn(
                  columnName: 'name',
                  width: kWName,
                  label: _header(context, 'Name'),
                ),
                GridColumn(
                  columnName: 'phone',
                  width: kWPhone,
                  label: _header(context, 'Phone'),
                ),
                GridColumn(
                  columnName: 'email',
                  width: kWEmail,
                  label: _header(context, 'Email'),
                ),
                GridColumn(
                  columnName: 'status',
                  width: kWStatus,
                  label: _header(context, 'Status'),
                ),
                GridColumn(
                  columnName: 'balance',
                  width: kWBalance,
                  label: _header(context, 'Balance'),
                ),
                GridColumn(
                  columnName: 'actions',
                  width: kWActions,
                  label: _header(context, 'Actions'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context, String text, {bool alignRight = false}) {
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: AdminColors.secondaryText,
      fontWeight: FontWeight.w700,
    );
    return Container(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(text, style: style),
    );
  }

  void _openReview(BuildContext context, DriverRowVM vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => DriverReviewSheet(driver: vm.original),
    );
  }

  Future<void> _toggleStatus(BuildContext context, DriverRowVM vm) async {
    final repo = context.read<DriversCubit>().repo;
    final next = vm.status == 'active' ? 'suspended' : 'active';
    await repo.setStatus(vm.id, next);
  }
}

class DriversGridSource extends DataGridSource {
  DriversGridSource({
    required List<Driver> items,
    required this.onReview,
    required this.onToggleStatus,
  }) {
    _rows = _toRows(items);
  }

  final void Function(DriverRowVM) onReview;
  final Future<void> Function(DriverRowVM) onToggleStatus;

  late List<DataGridRow> _rows;

  void update(List<Driver> items) {
    _rows = _toRows(items);
    notifyListeners();
  }

  List<DataGridRow> _toRows(List<Driver> items) {
    return items.map((d) {
      final vm = DriverRowVM.fromDriver(d);
      return DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'driverId', value: vm.id),
          DataGridCell<String>(columnName: 'name', value: vm.name),
          DataGridCell<String>(columnName: 'phone', value: vm.phone),
          DataGridCell<String>(columnName: 'email', value: vm.email),
          DataGridCell<String>(columnName: 'status', value: vm.status),
          DataGridCell<String>(columnName: 'balance', value: vm.balanceStr),
          DataGridCell<DriverRowVM>(columnName: 'actions', value: vm),
        ],
      );
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final vm =
        row.getCells().firstWhere((c) => c.columnName == 'actions').value
            as DriverRowVM;

    Widget textCell(String v, {bool right = false}) => Container(
      alignment: right ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Text(v, maxLines: 1, overflow: TextOverflow.ellipsis),
    );

    Widget widgetCell(Widget child, {bool right = false}) => Container(
      alignment: right ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: child,
    );

    return DataGridRowAdapter(
      cells: [
        textCell(vm.id),
        textCell(vm.name),
        textCell(vm.phone),
        textCell(vm.email),
        widgetCell(StatusChip(label: _prettyStatus(vm.status))),
        textCell(vm.balanceStr, right: false),
        widgetCell(
          Row(
            children: [
              PillButton(label: 'Review', onPressed: () => onReview(vm)),
              const SizedBox(width: 8),
              // Activate / Suspend buttons like your original
              if (vm.status == 'active')
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AdminColors.danger,
                  ),
                  onPressed: () => onToggleStatus(vm),
                  child: const Text(
                    'Suspend',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              if (vm.status == 'suspended')
                TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () => onToggleStatus(vm),
                  child: const Text(
                    'Activate',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _prettyStatus(String s) {
    final l = s.toLowerCase();
    if (l == 'pending_approval') return 'Pending';
    return l.isEmpty ? '-' : l[0].toUpperCase() + l.substring(1);
  }
}

class DriverRowVM {
  final Driver original;
  final String id;
  final String name;
  final String phone;
  final String email;
  final String status;
  final String balanceStr;

  DriverRowVM({
    required this.original,
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.status,
    required this.balanceStr,
  });

  factory DriverRowVM.fromDriver(Driver d) {
    final bal = (d.balance).toStringAsFixed(2);
    return DriverRowVM(
      original: d,
      id: d.id,
      name: d.fullName,
      phone: d.phone ?? '-',
      email: d.email ?? '-',
      status: d.status,
      balanceStr: 'EGP $bal',
    );
  }
}
