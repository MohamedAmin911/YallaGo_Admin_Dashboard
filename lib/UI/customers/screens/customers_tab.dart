import 'package:flutter/material.dart';
import 'package:yallago_admin_dashboard/UI/customers/widgets/customers%20tab/customers_data_grid.dart';
import 'package:yallago_admin_dashboard/UI/customers/widgets/customers%20tab/customers_filter_row.dart';

class CustomersTab extends StatefulWidget {
  const CustomersTab({super.key});

  @override
  State<CustomersTab> createState() => _CustomersTabState();
}

class _CustomersTabState extends State<CustomersTab> {
  final _searchRightCtrl = TextEditingController();

  @override
  void dispose() {
    _searchRightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomersFilterRow(
            searchController: _searchRightCtrl,
            onSearchSubmitted: (q) {
              // TODO: wire to CustomerCubit if you want server-side search
            },
          ),
          const SizedBox(height: 16),
          const Expanded(child: CustomersDataGrid()),
        ],
      ),
    );
  }
}
