import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';
import 'package:yallago_admin_dashboard/core/common%20widgets/pill_button.dart';
import 'package:yallago_admin_dashboard/core/common%20widgets/status_chip.dart';
import 'package:yallago_admin_dashboard/core/common%20widgets/surface_card.dart';
import 'package:yallago_admin_dashboard/cubit/payouts/payouts_cubit.dart';
import 'package:yallago_admin_dashboard/cubit/payouts/payouts_state.dart';
import 'package:yallago_admin_dashboard/models/payout_request.dart';

// Column width constants
const double kWPayoutId = 300;
const double kWDriver = 260;
const double kWAmount = 160;
const double kWStatus = 160;
const double kWDate = 200;
const double kWActions = 200;

class PayoutsDataGrid extends StatefulWidget {
  final String adminUid;

  const PayoutsDataGrid({super.key, required this.adminUid});

  @override
  State<PayoutsDataGrid> createState() => _PayoutsDataGridState();
}

class _PayoutsDataGridState extends State<PayoutsDataGrid> {
  late PayoutsGridSource _source;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: BlocBuilder<PayoutsCubit, PayoutsState>(
        builder: (context, state) {
          if (!_initialized) {
            _source = PayoutsGridSource(
              items: state.visible,
              adminUid: widget.adminUid,
            );
            _initialized = true;
          } else {
            _source.update(state.visible);
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
          if (state.visible.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No payouts found'),
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
                  columnName: 'payoutId',
                  width: kWPayoutId,
                  label: _buildGridHeader(context, 'Payout ID'),
                ),
                GridColumn(
                  columnName: 'driver',
                  width: kWDriver,
                  label: _buildGridHeader(context, 'Driver'),
                ),
                GridColumn(
                  columnName: 'amount',
                  width: kWAmount,
                  label: _buildGridHeader(context, 'Amount'),
                ),
                GridColumn(
                  columnName: 'status',
                  width: kWStatus,
                  label: _buildGridHeader(context, 'Status'),
                ),
                GridColumn(
                  columnName: 'date',
                  width: kWDate,
                  label: _buildGridHeader(context, 'Date'),
                ),
                GridColumn(
                  columnName: 'actions',
                  width: kWActions,
                  label: _buildGridHeader(context, 'Actions'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridHeader(
    BuildContext context,
    String text, {
    bool alignRight = false,
  }) {
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
}

class PayoutsGridSource extends DataGridSource {
  PayoutsGridSource({
    required List<PayoutRequest> items,
    required this.adminUid,
  }) {
    _rows = _toRows(items);
  }

  final String adminUid;
  late List<DataGridRow> _rows;

  void update(List<PayoutRequest> items) {
    _rows = _toRows(items);
    notifyListeners();
  }

  List<DataGridRow> _toRows(List<PayoutRequest> items) {
    return items.map((payout) {
      final vm = PayoutRowVM.fromPayoutRequest(payout);
      return DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'payoutId', value: vm.payoutId),
          DataGridCell<String>(columnName: 'driver', value: vm.driverName),
          DataGridCell<String>(columnName: 'amount', value: vm.amountStr),
          DataGridCell<String>(columnName: 'status', value: vm.status),
          DataGridCell<String>(columnName: 'date', value: vm.dateStr),
          DataGridCell<PayoutRowVM>(columnName: 'actions', value: vm),
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
            as PayoutRowVM;

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
        textCell(vm.payoutId),
        textCell(vm.driverName),
        textCell(vm.amountStr, right: false),
        widgetCell(StatusChip(label: _prettyStatus(vm.status))),
        textCell(vm.dateStr),
        widgetCell(
          PillButton(
            label: 'View Details',
            onPressed: () {
              // TODO: Implement view details action
            },
          ),
        ),
      ],
    );
  }

  String _prettyStatus(String s) {
    final l = s.toLowerCase();
    if (l == 'pending') return 'Pending';
    if (l == 'approved') return 'Approved';
    if (l == 'paid') return 'Paid';
    if (l == 'rejected') return 'Rejected';
    if (l == 'failed') return 'Failed';
    return l.isEmpty ? '-' : l[0].toUpperCase() + l.substring(1);
  }
}

class PayoutRowVM {
  final PayoutRequest original;
  final String payoutId;
  final String driverName;
  final String amountStr;
  final String status;
  final String dateStr;

  PayoutRowVM({
    required this.original,
    required this.payoutId,
    required this.driverName,
    required this.amountStr,
    required this.status,
    required this.dateStr,
  });

  factory PayoutRowVM.fromPayoutRequest(PayoutRequest payout) {
    final amountStr = 'EGP ${(payout.amountCents / 100).toStringAsFixed(2)}';
    final dateStr =
        // ignore: unnecessary_null_comparison
        payout.createdAt != null
            ? payout.createdAt.toDate().toString().split(' ')[0]
            : '-';

    return PayoutRowVM(
      original: payout,
      payoutId: payout.id,
      driverName: payout.driverName,
      amountStr: amountStr,
      status: payout.status,
      dateStr: dateStr,
    );
  }
}
