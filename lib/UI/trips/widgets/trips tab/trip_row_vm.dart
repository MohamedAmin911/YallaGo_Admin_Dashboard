import 'package:intl/intl.dart';
import 'package:yallago_admin_dashboard/UI/trips/widgets/trips%20tab/trip_like_model.dart';

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

  String get requestedAtStr {
    if (requestedAt == null) return '-';
    return DateFormat('yyyy-MM-dd HH:mm').format(requestedAt!);
  }

  factory TripRowVM.fromDynamic(dynamic t) {
    String id, status, customerUid, driverUid, pickup, dest, pay;
    double fare;
    DateTime? reqAt;

    try {
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

  TripLike toTripLike() => TripLike(
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
