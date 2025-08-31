import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Your files
import 'package:yallago_admin_dashboard/UI/admin_dashboard.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';
import 'package:yallago_admin_dashboard/cubit/customer/customer_cubit.dart';
import 'package:yallago_admin_dashboard/cubit/driver%20tracking/driver_tracking_cubit.dart';
import 'package:yallago_admin_dashboard/cubit/driver/driver_cubit.dart';
import 'package:yallago_admin_dashboard/cubit/trip/trip_cubit.dart';
import 'package:yallago_admin_dashboard/repo/customer_repo.dart';
import 'package:yallago_admin_dashboard/repo/driver_repo.dart';
import 'package:yallago_admin_dashboard/repo/driver_tracking_repo.dart';
import 'package:yallago_admin_dashboard/repo/trip_repo.dart';

// 1) Add a top-level main() for the admin entrypoint
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // If you don’t use flutterfire (firebase_options.dart) yet, pass constants like in your main.dart:
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyC-5rpX3IBv8cY3_jLoN0z7TU0vgHEdAU4",
      authDomain: "taxi-app-337b4.firebaseapp.com",
      projectId: "taxi-app-337b4",
      storageBucket: "taxi-app-337b4.firebasestorage.app",
      messagingSenderId: "651879327595",
      appId: "1:651879327595:web:9ff9d875af37c841c54e2e",
      measurementId: "G-415QS7KQ2N",
    ),
  );

  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TripsCubit>(
          create: (context) => TripsCubit(TripsRepository())..start(),
        ),
        BlocProvider<DriversCubit>(
          create:
              (context) => DriversCubit(DriversRepository())..setTab('active'),
        ),
        BlocProvider<CustomerCubit>(
          create:
              (context) => CustomerCubit(CustomersRepository())..setTab('all'),
        ),
        BlocProvider<DriversTrackingCubit>(
          create:
              (context) => DriversTrackingCubit(DriversTrackingRepository()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: adminTheme(),
        home:
            const AdminDashboard(), // this returns a Scaffold under a MaterialApp -> Directionality OK
      ),
    );
  }
}
// flutter run -t lib/main_admin.dart -d chrome