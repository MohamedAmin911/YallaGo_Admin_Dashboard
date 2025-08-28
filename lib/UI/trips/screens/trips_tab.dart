import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';
import 'package:yallago_admin_dashboard/core/payment_chip.dart';
import 'package:yallago_admin_dashboard/core/pill_button.dart';
import 'package:yallago_admin_dashboard/core/status_chip.dart';
import 'package:yallago_admin_dashboard/core/surface_card.dart';
import 'package:yallago_admin_dashboard/cubit/trip/trip_cubit.dart';
import 'package:yallago_admin_dashboard/cubit/trip/trip_state.dart';
import 'package:syncfusion_flutter_core/theme.dart';

// =====================================================================================
// Fixed column widths (matching your mock). Tweak as needed.
// =====================================================================================
const double kWTripId = 210;
const double kWStatus = 120;
const double kWRider = 160;
const double kWDriver = 160;
const double kWPickup = 160;
const double kWDest = 160;
const double kWFare = 120;
const double kWPayment = 140;
const double kWRequestedAt = 170;
const double kWActions = 100;

// =====================================================================================
// Trips Screen
// =====================================================================================
class TripsTab extends StatefulWidget {
  const TripsTab({super.key});
  @override
  State<TripsTab> createState() => _TripsTabState();
}

class _TripsTabState extends State<TripsTab> {
  final _searchRightCtrl = TextEditingController();
  DateTimeRange? _range;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filters row: left (date range + status) / right (search)
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
                      PillButton(
                        label:
                            _range == null
                                ? 'Select Date Range'
                                : '${DateFormat('yyyy-MM-dd').format(_range!.start)} → ${DateFormat('yyyy-MM-dd').format(_range!.end)}',
                        onPressed: () async {
                          final today = DateTime.now();
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(today.year - 1),
                            lastDate: DateTime(today.year + 1),
                            initialDateRange:
                                _range ??
                                DateTimeRange(
                                  start: DateTime(
                                    today.year,
                                    today.month,
                                    today.day,
                                  ),
                                  end: DateTime(
                                    today.year,
                                    today.month,
                                    today.day,
                                  ),
                                ),
                          );
                          if (picked != null) {
                            setState(() => _range = picked);
                            // TODO: send to TripsCubit if you want server-side filtering by date range
                          }
                        },
                      ),
                      const SizedBox(width: 12),

                      // Status dropdown; Shortcuts prevent web space-repeat crash
                      Shortcuts(
                        shortcuts: {
                          LogicalKeySet(LogicalKeyboardKey.space):
                              const DoNothingAndStopPropagationIntent(),
                        },
                        child: BlocBuilder<TripsCubit, TripsState>(
                          buildWhen: (p, c) => p.statusFilter != c.statusFilter,
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
                                  value: state.statusFilter,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'all',
                                      child: Text('Status'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'searching',
                                      child: Text('Searching'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'in_progress',
                                      child: Text('Ongoing'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'completed',
                                      child: Text('Completed'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'canceled',
                                      child: Text('Canceled'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'paid',
                                      child: Text('Paid'),
                                    ),
                                  ],
                                  onChanged:
                                      (v) =>
                                          v != null
                                              ? context
                                                  .read<TripsCubit>()
                                                  .setStatus(v)
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
                      controller: _searchRightCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Search by Trip ID, Rider, Driver...',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (q) {
                        // TODO: wire to Cubit (client-side filter or query param)
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Table card with Syncfusion DataGrid
          const Expanded(child: _TripsGridCard()),
        ],
      ),
    );
  }
}

// =====================================================================================
// DataGrid Card Wrapper + Grid
// =====================================================================================
class _TripsGridCard extends StatefulWidget {
  const _TripsGridCard();

  @override
  State<_TripsGridCard> createState() => _TripsGridCardState();
}

class _TripsGridCardState extends State<_TripsGridCard> {
  late TripsGridSource _source;
  bool _initialized = false;

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
                padding: EdgeInsets.all(24),
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
              columnWidthMode: ColumnWidthMode.none, // use fixed widths
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
                  label: _header(context, 'Trip ID'),
                ),
                GridColumn(
                  columnName: 'status',
                  width: kWStatus,
                  label: _header(context, 'Status'),
                ),
                GridColumn(
                  columnName: 'rider',
                  width: kWRider,
                  label: _header(context, 'Rider'),
                ),
                GridColumn(
                  columnName: 'driver',
                  width: kWDriver,
                  label: _header(context, 'Driver'),
                ),
                GridColumn(
                  columnName: 'pickup',
                  width: kWPickup,
                  label: _header(context, 'Pickup'),
                ),
                GridColumn(
                  columnName: 'dest',
                  width: kWDest,
                  label: _header(context, 'Destination'),
                ),
                GridColumn(
                  columnName: 'fare',
                  width: kWFare,
                  label: _header(context, 'Fare', alignRight: false),
                ),
                GridColumn(
                  columnName: 'payment',
                  width: kWPayment,
                  label: _header(context, 'Payment Status'),
                ),
                GridColumn(
                  columnName: 'requestedAt',
                  width: kWRequestedAt,
                  label: _header(context, 'Requested At'),
                ),
                GridColumn(
                  columnName: 'actions',
                  width: kWActions,
                  label: _header(context, 'Actions', alignRight: false),
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

  void _openTrip(BuildContext context, TripRowVM row) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => TripDetailsSheet(trip: row.toTripLike()),
    );
  }
}

// =====================================================================================
// DataGrid Source (maps your list from state to grid rows with fixed columns)
// =====================================================================================
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

// =====================================================================================
// Trip row view-model helper (works with Map or your Trip class via dynamic)
// =====================================================================================
class TripRowVM {
  final String tripId;
  final String status;
  final String rider;
  final String driver;
  final String pickup;
  final String dest;
  final String fareStr;
  final String paymentLabel;
  final DateTime? requestedAt;

  TripRowVM({
    required this.tripId,
    required this.status,
    required this.rider,
    required this.driver,
    required this.pickup,
    required this.dest,
    required this.fareStr,
    required this.paymentLabel,
    required this.requestedAt,
  });

  // NEW: formatted date string used by the grid
  String get requestedAtStr {
    if (requestedAt == null) return '-';
    return DateFormat('yyyy-MM-dd HH:mm').format(requestedAt!);
  }

  factory TripRowVM.fromDynamic(dynamic t) {
    // Try to read as object (Trip-like), else as Map<String, dynamic>
    String id, status, customerUid, driverUid, pickup, dest, pay;
    double fare;
    DateTime? reqAt;

    try {
      // Object with getters
      id = t.id as String;
      status = (t.status as String?) ?? 'unknown';
      customerUid = (t.customerUid as String?) ?? '-';
      driverUid = (t.driverUid as String?) ?? '-';
      pickup = (t.pickupAddress as String?) ?? '-';
      dest = (t.destinationAddress as String?) ?? '-';
      fare = (t.estimatedFare as num?)?.toDouble() ?? 0.0;
      pay = (t.paymentStatus as String?) ?? 'Pending';
      reqAt = t.requestedAt as DateTime?;
    } catch (_) {
      // Map fallback
      final m = (t as Map).cast<String, dynamic>();
      id = (m['id'] ?? m['tripId'] ?? '') as String;
      status = (m['status'] ?? 'unknown') as String;
      customerUid = (m['customerUid'] ?? '-') as String;
      driverUid = (m['driverUid'] ?? '-') as String;
      pickup = (m['pickupAddress'] ?? '-') as String;
      dest = (m['destinationAddress'] ?? '-') as String;
      fare = (m['estimatedFare'] as num?)?.toDouble() ?? 0.0;
      pay = (m['paymentStatus'] ?? 'Pending') as String;
      final ts = m['requestedAt'];
      if (ts is DateTime) reqAt = ts;
      if (ts?.toDate != null) {
        reqAt = ts.toDate();
      }
    }

    final fareStr = 'EGP ${fare.toStringAsFixed(2)}';
    final paymentLabel = pay == 'succeeded' ? 'Paid' : pay;
    return TripRowVM(
      tripId: id,
      status: status,
      rider: customerUid,
      driver: driverUid,
      pickup: pickup,
      dest: dest,
      fareStr: fareStr,
      paymentLabel: paymentLabel,
      requestedAt: reqAt,
    );
  }

  // For details sheet we convert to a simple map-like Trip object
  _TripLike toTripLike() => _TripLike(
    id: tripId,
    status: status,
    customerUid: rider,
    driverUid: driver == '-' ? null : driver,
    pickupAddress: pickup,
    destinationAddress: dest,
    estimatedFare:
        double.tryParse(fareStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0,
    paymentStatus: paymentLabel == 'Paid' ? 'succeeded' : paymentLabel,
    requestedAt: requestedAt,
  );
}

// Minimal "Trip-like" model used by the details sheet (so this file is self-contained)
class _TripLike {
  final String id;
  final String status;
  final String customerUid;
  final String? driverUid;
  final String pickupAddress;
  final String destinationAddress;
  final double estimatedFare;
  final String? paymentStatus;

  final DateTime? requestedAt;

  _TripLike({
    required this.id,
    required this.status,
    required this.customerUid,
    required this.driverUid,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.estimatedFare,
    this.paymentStatus,

    this.requestedAt,
  });
}

// =====================================================================================
// Trip Details Sheet (simple cards; align with your styles)
// =====================================================================================
class TripDetailsSheet extends StatelessWidget {
  final _TripLike trip;
  const TripDetailsSheet({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final dateFmt = DateFormat('yyyy-MM-dd HH:mm');

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Trip Details #${trip.id}',
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                StatusChip(label: trip.status),
              ],
            ),
            const SizedBox(height: 16),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kv('Customer', trip.customerUid),
                  _kv('Driver', trip.driverUid ?? '-'),
                  _kv('Pickup', trip.pickupAddress),
                  _kv('Destination', trip.destinationAddress),
                  _kv('Fare', 'EGP ${trip.estimatedFare.toStringAsFixed(2)}'),
                  _kv(
                    'Requested At',
                    trip.requestedAt == null
                        ? '-'
                        : dateFmt.format(trip.requestedAt!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Payment Details',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (trip.paymentStatus != null)
                        PaymentChip(label: trip.paymentStatus!),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _kv('Payment Status', trip.paymentStatus ?? '-'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(
            '$k:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(v)),
      ],
    ),
  );
}
