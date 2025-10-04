import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:yallago_admin_dashboard/UI/customers/screens/customer_details_sheet.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';
import 'package:yallago_admin_dashboard/core/common%20widgets/pill_button.dart';
import 'package:yallago_admin_dashboard/core/common%20widgets/surface_card.dart';
import 'package:yallago_admin_dashboard/cubit/customer/customer_cubit.dart';
import 'package:yallago_admin_dashboard/cubit/customer/customer_state.dart';
import 'package:yallago_admin_dashboard/models/customer.dart';

const double kWCustomerId = 300;
const double kWName = 260;
const double kWEmail = 260;
const double kWPhone = 160;
const double kWRides = 120;
const double kWActions = 200;

class CustomersDataGrid extends StatefulWidget {
  const CustomersDataGrid({super.key});

  @override
  State<CustomersDataGrid> createState() => _CustomersDataGridState();
}

class _CustomersDataGridState extends State<CustomersDataGrid> {
  late CustomersGridSource _source;
  bool _initialized = false;

  void _openDetails(BuildContext context, CustomerRowVM vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => CustomerDetailsSheet(customer: vm.original),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: BlocBuilder<CustomerCubit, CustomerState>(
        builder: (context, state) {
          if (!_initialized) {
            _source = CustomersGridSource(
              items: state.items,
              onView: (vm) => _openDetails(context, vm),
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
                child: Text('No customers'),
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
                  columnName: 'customerId',
                  width: kWCustomerId,
                  label: _buildGridHeader(context, 'Customer ID'),
                ),
                GridColumn(
                  columnName: 'name',
                  width: kWName,
                  label: _buildGridHeader(context, 'Name'),
                ),
                GridColumn(
                  columnName: 'email',
                  width: kWEmail,
                  label: _buildGridHeader(context, 'Email'),
                ),
                GridColumn(
                  columnName: 'phone',
                  width: kWPhone,
                  label: _buildGridHeader(context, 'Phone'),
                ),
                GridColumn(
                  columnName: 'rides',
                  width: kWRides,
                  label: _buildGridHeader(context, 'Total Rides'),
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

class CustomersGridSource extends DataGridSource {
  CustomersGridSource({required List<Customer> items, required this.onView}) {
    _rows = _toRows(items);
  }

  final void Function(CustomerRowVM) onView;
  late List<DataGridRow> _rows;

  void update(List<Customer> items) {
    _rows = _toRows(items);
    notifyListeners();
  }

  List<DataGridRow> _toRows(List<Customer> items) {
    return items.map((c) {
      final vm = CustomerRowVM.fromCustomer(c);
      return DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'customerId', value: vm.id),
          DataGridCell<String>(columnName: 'name', value: vm.name),
          DataGridCell<String>(columnName: 'email', value: vm.email),
          DataGridCell<String>(columnName: 'phone', value: vm.phone),
          DataGridCell<String>(columnName: 'rides', value: vm.ridesStr),
          DataGridCell<CustomerRowVM>(columnName: 'actions', value: vm),
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
            as CustomerRowVM;

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
        textCell(vm.email),
        textCell(vm.phone),
        textCell(vm.ridesStr, right: false),
        widgetCell(
          PillButton(label: 'View Details', onPressed: () => onView(vm)),
        ),
      ],
    );
  }
}

class CustomerRowVM {
  final Customer original;
  final String id;
  final String name;
  final String email;
  final String phone;
  final String ridesStr;

  CustomerRowVM({
    required this.original,
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.ridesStr,
  });

  factory CustomerRowVM.fromCustomer(Customer c) {
    return CustomerRowVM(
      original: c,
      id: c.id,
      name: c.fullName,
      email: c.email ?? '-',
      phone: c.phone ?? '-',
      ridesStr: '${c.totalRides} rides',
    );
  }
}
