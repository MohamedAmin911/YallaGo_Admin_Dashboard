import 'package:flutter/material.dart';

import 'package:yallago_admin_dashboard/UI/drivers/widgets/drivers%20tab/drivers_filter_row.dart';
import 'package:yallago_admin_dashboard/UI/drivers/widgets/drivers%20tab/drivers_data_grid.dart';

class DriversTab extends StatefulWidget {
  const DriversTab({super.key});

  @override
  State<DriversTab> createState() => _DriversTabState();
}

class _DriversTabState extends State<DriversTab> {
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
          DriversFilterRow(
            searchController: _searchRightCtrl,
            onSearchSubmitted: (q) {
              // TODO: wire to DriversCubit if you want server-side search
            },
          ),
          const SizedBox(height: 16),
          const Expanded(child: DriversDataGrid()),
        ],
      ),
    );
  }
}
