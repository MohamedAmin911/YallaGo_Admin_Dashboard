import 'package:flutter/material.dart';
import 'package:yallago_admin_dashboard/UI/customers/screens/customers_tab.dart';
import 'package:yallago_admin_dashboard/UI/drivers/screens/drivers_tab.dart';
import 'package:yallago_admin_dashboard/UI/trips/screens/trips_tab.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final tabs = const [
      Tab(text: 'Trips'),
      Tab(text: 'Drivers'),
      Tab(text: 'Customers'),
      // Tab(text: 'Realtime Tracking'),
      // Tab(text: 'Support Chat'),
      // Tab(text: 'Payout Requests'),
      // Tab(text: 'Insights'),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 30),
              child: Image.asset('assets/images/logo5.png', height: 40),
            ),
            TabBar(
              labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              padding: EdgeInsets.only(top: 30),
              isScrollable: true,
              tabs: tabs,
              dividerColor: Colors.transparent,
              tabAlignment: TabAlignment.center,
            ),

            Expanded(
              child: const TabBarView(
                children: [
                  TripsTab(),
                  DriversTab(),
                  CustomersTab(),
                  // TrackingTab(),
                  // ChatTab(),
                  // PayoutsTab(),
                  // InsightsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
