import 'package:cloud_firestore/cloud_firestore.dart';

class PayoutRequest {
  final String id;
  final String driverUid;
  final String driverName;
  final String driverStripeAccountId;
  final int amountCents;
  final String currency;
  final String status;
  final Timestamp createdAt;
  final Timestamp? approvedAt;
  final String? approvedBy;
  final Timestamp? processedAt;
  final String? failureReason;
  final String? transferId;
  final String? payoutId;
  final int? balanceSnapshotCents;
  final int? feeCents;
  final String? note;

  PayoutRequest({
    required this.id,
    required this.driverUid,
    required this.driverName,
    required this.driverStripeAccountId,
    required this.amountCents,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.approvedAt,
    this.approvedBy,
    this.processedAt,
    this.failureReason,
    this.transferId,
    this.payoutId,
    this.balanceSnapshotCents,
    this.feeCents,
    this.note,
  });

  Map<String, dynamic> toMap() => {
    'driverUid': driverUid,
    'driverName': driverName,
    'driverStripeAccountId': driverStripeAccountId,
    'amountCents': amountCents,
    'currency': currency,
    'status': status,
    'createdAt': createdAt,
    'approvedAt': approvedAt,
    'approvedBy': approvedBy,
    'processedAt': processedAt,
    'failureReason': failureReason,
    'transferId': transferId,
    'payoutId': payoutId,
    'balanceSnapshotCents': balanceSnapshotCents,
    'feeCents': feeCents,
    'note': note,
  };

  factory PayoutRequest.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return PayoutRequest(
      id: doc.id,
      driverUid: d['driverUid'],
      driverName: d['driverName'] ?? '',
      driverStripeAccountId: d['driverStripeAccountId'],
      amountCents: (d['amountCents'] ?? 0) as int,
      currency: d['currency'] ?? 'usd',
      status: d['status'] ?? 'pending',
      createdAt: d['createdAt'] as Timestamp,
      approvedAt: d['approvedAt'] as Timestamp?,
      approvedBy: d['approvedBy'] as String?,
      processedAt: d['processedAt'] as Timestamp?,
      failureReason: d['failureReason'] as String?,
      transferId: d['transferId'] as String?,
      payoutId: d['payoutId'] as String?,
      balanceSnapshotCents: d['balanceSnapshotCents'] as int?,
      feeCents: d['feeCents'] as int?,
      note: d['note'] as String?,
    );
  }
}
