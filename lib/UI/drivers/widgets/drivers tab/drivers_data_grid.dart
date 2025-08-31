import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';
import 'package:yallago_admin_dashboard/core/common%20widgets/pill_button.dart';
import 'package:yallago_admin_dashboard/core/common%20widgets/status_chip.dart';
import 'package:yallago_admin_dashboard/core/common%20widgets/surface_card.dart';
import 'package:yallago_admin_dashboard/cubit/driver/driver_cubit.dart';
import 'package:yallago_admin_dashboard/cubit/driver/driver_state.dart';
import 'package:yallago_admin_dashboard/UI/drivers/screens/driver_details_sheet.dart';
import 'package:yallago_admin_dashboard/models/driver.dart';
import 'package:yallago_admin_dashboard/UI/drivers/widgets/drivers%20tab/driver_row_vm.dart';
import 'package:yallago_admin_dashboard/UI/drivers/widgets/drivers%20tab/grid_header_widget.dart';

class DriversDataGrid extends StatefulWidget {
  const DriversDataGrid({super.key});

  @override
  State<DriversDataGrid> createState() => _DriversDataGridState();
}

class _DriversDataGridState extends State<DriversDataGrid> {
  late DriversGridSource _source;
  bool _initialized = false;

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
                  label: buildGridHeader(context, 'Driver ID'),
                ),
                GridColumn(
                  columnName: 'name',
                  width: kWName,
                  label: buildGridHeader(context, 'Name'),
                ),
                GridColumn(
                  columnName: 'phone',
                  width: kWPhone,
                  label: buildGridHeader(context, 'Phone'),
                ),
                GridColumn(
                  columnName: 'email',
                  width: kWEmail,
                  label: buildGridHeader(context, 'Email'),
                ),
                GridColumn(
                  columnName: 'status',
                  width: kWStatus,
                  label: buildGridHeader(context, 'Status'),
                ),
                GridColumn(
                  columnName: 'balance',
                  width: kWBalance,
                  label: buildGridHeader(context, 'Balance'),
                ),
                GridColumn(
                  columnName: 'actions',
                  width: kWActions,
                  label: buildGridHeader(context, 'Actions'),
                ),
              ],
            ),
          );
        },
      ),
    );
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
