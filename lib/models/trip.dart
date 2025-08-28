import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final String id;
  final String status;
  final String customerUid;
  final String? driverUid;
  final String pickupAddress;
  final String destinationAddress;
  final double estimatedFare;
  final String? paymentStatus;
  final String? paymentIntentId;
  final DateTime? requestedAt;

  Trip({
    required this.id,
    required this.status,
    required this.customerUid,
    required this.driverUid,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.estimatedFare,
    this.paymentStatus,
    this.paymentIntentId,
    this.requestedAt,
  });

  factory Trip.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data()!;
    return Trip(
      id: d.id,
      status: (m['status'] ?? 'unknown') as String,
      customerUid: (m['customerUid'] ?? '') as String,
      driverUid: m['driverUid'] as String?,
      pickupAddress: (m['pickupAddress'] ?? '') as String,
      destinationAddress: (m['destinationAddress'] ?? '') as String,
      estimatedFare: (m['estimatedFare'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: m['paymentStatus'] as String?,
      paymentIntentId: m['paymentIntentId'] as String?,
      requestedAt: (m['requestedAt'] as Timestamp?)?.toDate(),
    );
  }
}
