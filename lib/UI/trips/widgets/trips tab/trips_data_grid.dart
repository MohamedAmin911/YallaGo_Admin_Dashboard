import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';
import 'package:yallago_admin_dashboard/core/common%20widgets/payment_chip.dart';
import 'package:yallago_admin_dashboard/core/common%20widgets/pill_button.dart';
import 'package:yallago_admin_dashboard/core/common%20widgets/status_chip.dart';
import 'package:yallago_admin_dashboard/core/common%20widgets/surface_card.dart';
import 'package:yallago_admin_dashboard/cubit/trip/trip_cubit.dart';
import 'package:yallago_admin_dashboard/cubit/trip/trip_state.dart';
import 'package:yallago_admin_dashboard/UI/trips/screens/trip_details_sheet.dart';
import 'package:yallago_admin_dashboard/UI/trips/widgets/trips%20tab/trip_row_vm.dart';
import 'package:yallago_admin_dashboard/UI/trips/widgets/trips%20tab/grid_header_widget.dart';

class TripsDataGrid extends StatefulWidget {
  const TripsDataGrid({super.key});

  @override
  State<TripsDataGrid> createState() => _TripsDataGridState();
}

class _TripsDataGridState extends State<TripsDataGrid> {
  late TripsGridSource _source;
  bool _initialized = false;

  void _openTrip(BuildContext context, TripRowVM row) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => TripDetailsSheet(trip: row.toTripLike()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: BlocBuilder<TripsCubit, TripsState>(
        builder: (context, state) {
          if (!_initialized) {
            _source = TripsGridSource(
              items: state.trips,
              onView: (row) => _openTrip(context, row),
            );
            _initialized = true;
          } else {
            _source.update(state.trips);
          }

          if (state.loading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
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
          if (state.trips.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No trips'),
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
                  columnName: 'tripId',
                  width: kWTripId,
                  label: buildGridHeader(context, 'Trip ID'),
                ),
                GridColumn(
                  columnName: 'status',
                  width: kWStatus,
                  label: buildGridHeader(context, 'Status'),
                ),
                GridColumn(
                  columnName: 'rider',
                  width: kWRider,
                  label: buildGridHeader(context, 'Rider'),
                ),
                GridColumn(
                  columnName: 'driver',
                  width: kWDriver,
                  label: buildGridHeader(context, 'Driver'),
                ),
                GridColumn(
                  columnName: 'pickup',
                  width: kWPickup,
                  label: buildGridHeader(context, 'Pickup'),
                ),
                GridColumn(
                  columnName: 'dest',
                  width: kWDest,
                  label: buildGridHeader(context, 'Destination'),
                ),
                GridColumn(
                  columnName: 'fare',
                  width: kWFare,
                  label: buildGridHeader(context, 'Fare', alignRight: false),
                ),
                GridColumn(
                  columnName: 'payment',
                  width: kWPayment,
                  label: buildGridHeader(context, 'Payment Status'),
                ),
                GridColumn(
                  columnName: 'requestedAt',
                  width: kWRequestedAt,
                  label: buildGridHeader(context, 'Requested At'),
                ),
                GridColumn(
                  columnName: 'actions',
                  width: kWActions,
                  label: buildGridHeader(context, 'Actions', alignRight: false),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TripsGridSource extends DataGridSource {
  TripsGridSource({required List<dynamic> items, required this.onView}) {
    _rows = _toRows(items);
  }

  final void Function(TripRowVM) onView;
  late List<DataGridRow> _rows;

  void update(List<dynamic> items) {
    _rows = _toRows(items);
    notifyListeners();
  }

  List<DataGridRow> _toRows(List<dynamic> items) {
    return items.map((it) {
      final vm = TripRowVM.fromDynamic(it);
      return DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'tripId', value: vm.tripId),
          DataGridCell<String>(columnName: 'status', value: vm.status),
          DataGridCell<String>(columnName: 'rider', value: vm.rider),
          DataGridCell<String>(columnName: 'driver', value: vm.driver),
          DataGridCell<String>(columnName: 'pickup', value: vm.pickup),
          DataGridCell<String>(columnName: 'dest', value: vm.dest),
          DataGridCell<String>(columnName: 'fare', value: vm.fareStr),
          DataGridCell<String>(columnName: 'payment', value: vm.paymentLabel),
          DataGridCell<String>(
            columnName: 'requestedAt',
            value: vm.requestedAtStr,
          ),
          DataGridCell<TripRowVM>(columnName: 'actions', value: vm),
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
            as TripRowVM;

    Widget _text(String v, {bool right = false}) => Container(
      alignment: right ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Text(v, maxLines: 1, overflow: TextOverflow.ellipsis),
    );

    Widget child(Widget w, {bool right = false}) => Container(
      alignment: right ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: w,
    );

    return DataGridRowAdapter(
      cells: [
        _text(vm.tripId),
        child(StatusChip(label: vm.status)),
        _text(vm.rider),
        _text(vm.driver),
        _text(vm.pickup),
        _text(vm.dest),
        _text(vm.fareStr, right: false),
        child(PaymentChip(label: vm.paymentLabel)),
        _text(vm.requestedAtStr),
        child(
          PillButton(label: 'View', onPressed: () => onView(vm)),
          right: false,
        ),
      ],
    );
  }
}
