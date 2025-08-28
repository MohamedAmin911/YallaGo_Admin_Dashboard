import 'package:cloud_firestore/cloud_firestore.dart';

class Driver {
  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String status;
  final double balance;
  final String? stripeAccountId;
  final String? nationalIdUrl;
  final String? driversLicenseUrl;
  final String? carLicenseUrl;
  final String? criminalRecordUrl;

  Driver({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    required this.status,
    required this.balance,
    this.stripeAccountId,
    this.nationalIdUrl,
    this.driversLicenseUrl,
    this.carLicenseUrl,
    this.criminalRecordUrl,
  });

  factory Driver.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data()!;
    return Driver(
      id: d.id,
      fullName: (m['fullName'] ?? '') as String,
      email: m['email'] as String?,
      phone: m['phoneNumber'] as String?,
      status: (m['status'] ?? 'pending_approval') as String,
      balance: (m['balance'] as num?)?.toDouble() ?? 0.0,
      stripeAccountId: m['stripeConnectAccountId'] as String?,
      nationalIdUrl: m['nationalIdUrl'] as String?,
      driversLicenseUrl: m['driversLicenseUrl'] as String?,
      carLicenseUrl: m['carLicenseUrl'] as String?,
      criminalRecordUrl: m['criminalRecordUrl'] as String?,
    );
  }
}
