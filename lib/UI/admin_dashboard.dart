import 'package:flutter/material.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';

import 'package:yallago_admin_dashboard/UI/trips/screens/trips_tab.dart';
import 'package:yallago_admin_dashboard/UI/drivers/screens/drivers_tab.dart';
import 'package:yallago_admin_dashboard/UI/customers/screens/customers_tab.dart';
import 'package:yallago_admin_dashboard/UI/driver%20tracking/screen/driver_tracking_tab.dart';
import 'package:yallago_admin_dashboard/UI/payouts/screens/payout_requests_tab.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';
import 'package:yallago_admin_dashboard/core/keys.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late final PageController _pageCtrl;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thumb = AdminColors.primary;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.only(left: 30, top: 30),
            child: Image.asset('assets/images/logo5.png', height: 40),
          ),
          SizedBox(height: 40),
          Center(
            child: CustomSlidingSegmentedControl<int>(
              initialValue: _index,
              children: {
                0: _seg('Tracking', 0),
                1: _seg('Trips', 1),
                2: _seg('Customers', 2),
                3: _seg('Drivers', 3),
                4: _seg('Payout Requests', 4),
              },
              decoration: BoxDecoration(
                color: AdminColors.lightGray.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              thumbDecoration: BoxDecoration(
                color: thumb,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AdminColors.primaryText.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              height: 40,
              innerPadding: const EdgeInsets.all(6),
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              onValueChanged: (v) {
                setState(() => _index = v);
                _pageCtrl.animateToPage(
                  v,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),

          // Pages
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const ClampingScrollPhysics(),
              onPageChanged: (i) => setState(() => _index = i),
              children: const [
                DriversTrackingTab(),
                TripsTab(),

                CustomersTab(),
                DriversTab(),
                PayoutsTab(pipedreamBase: KapiKeys.pipedreamBase, adminUid: ""),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _seg(String label, int i) {
    final selected = _index == i;
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 150),
      style: TextStyle(
        fontSize: 14,
        fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
        color: selected ? Colors.white : AdminColors.primaryText,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
