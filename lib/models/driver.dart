import 'package:cloud_firestore/cloud_firestore.dart';

class Driver {
  final String id;
  final String uid;

  final String fullName;
  final String? email;
  final String? phone; // maps from 'phoneNumber'
  final String status;
  final double balance;

  final String? stripeAccountId; // maps from 'stripeConnectAccountId'
  final String? nationalIdUrl;
  final String? driversLicenseUrl;
  final String? carLicenseUrl;
  final String? criminalRecordUrl;

  // Added fields
  final String? carColor;
  final String? carImageUrl;
  final String? carModel;
  final Timestamp? createdAt;
  final GeoPoint? currentLocation;
  final String? fcmToken;
  final bool isOnline;
  final String? licensePlate;
  final String? profileImageUrl;
  final double rating;
  final int totalRides;

  Driver({
    required this.id,
    required this.uid,
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
    this.carColor,
    this.carImageUrl,
    this.carModel,
    this.createdAt,
    this.currentLocation,
    this.fcmToken,
    this.isOnline = false,
    this.licensePlate,
    this.profileImageUrl,
    this.rating = 0.0,
    this.totalRides = 0,
  });

  factory Driver.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};

    return Driver(
      id: d.id,
      uid: (m['uid'] as String?) ?? d.id,
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
      carColor: m['carColor'] as String?,
      carImageUrl: m['carImageUrl'] as String?,
      carModel: m['carModel'] as String?,
      createdAt:
          m['createdAt'] is Timestamp ? m['createdAt'] as Timestamp : null,
      currentLocation:
          m['currentLocation'] is GeoPoint
              ? m['currentLocation'] as GeoPoint
              : null,
      fcmToken: m['fcmToken'] as String?,
      isOnline: (m['isOnline'] as bool?) ?? false,
      licensePlate: m['licensePlate'] as String?,
      profileImageUrl: m['profileImageUrl'] as String?,
      rating: (m['rating'] as num?)?.toDouble() ?? 0.0,
      totalRides: (m['totalRides'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phone,
      'status': status,
      'balance': balance,
      'stripeConnectAccountId': stripeAccountId,
      'nationalIdUrl': nationalIdUrl,
      'driversLicenseUrl': driversLicenseUrl,
      'carLicenseUrl': carLicenseUrl,
      'criminalRecordUrl': criminalRecordUrl,
      'carColor': carColor,
      'carImageUrl': carImageUrl,
      'carModel': carModel,
      'createdAt': createdAt,
      'currentLocation': currentLocation,
      'fcmToken': fcmToken,
      'isOnline': isOnline,
      'licensePlate': licensePlate,
      'profileImageUrl': profileImageUrl,
      'rating': rating,
      'totalRides': totalRides,
    };

    // Remove nulls to avoid overwriting fields with null in Firestore
    map.removeWhere((_, v) => v == null);
    return map;
  }
}
