import 'package:yallago_admin_dashboard/models/driver.dart';

class DriverRowVM {
  final Driver original;
  final String id;
  final String name;
  final String phone;
  final String email;
  final String status;
  final String balanceStr;

  DriverRowVM({
    required this.original,
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.status,
    required this.balanceStr,
  });

  factory DriverRowVM.fromDriver(Driver d) {
    final bal = (d.balance).toStringAsFixed(2);
    return DriverRowVM(
      original: d,
      id: d.id,
      name: d.fullName,
      phone: d.phone ?? '-',
      email: d.email ?? '-',
      status: d.status,
      balanceStr: 'EGP $bal',
    );
  }
}
