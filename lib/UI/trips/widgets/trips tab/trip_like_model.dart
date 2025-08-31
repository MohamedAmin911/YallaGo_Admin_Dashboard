class TripLike {
  final String id;
  final String status;
  final String customerUid;
  final String? driverUid;
  final String pickupAddress;
  final String destinationAddress;
  final double estimatedFare;
  final String? paymentStatus;
  final DateTime? requestedAt;

  TripLike({
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
