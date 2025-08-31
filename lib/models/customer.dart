import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String id;
  final String uid;

  final String fullName;
  final String? email;
  final String? phone; // maps from 'phoneNumber'
  final String? profileImageUrl;
  final String? fcmToken;
  final String? homeAddress;

  final Timestamp? createdAt;
  final double rating;
  final int totalRides;
  final String? stripeCustomerId;

  final List<SearchHistoryItem> searchHistory;

  Customer({
    required this.id,
    required this.uid,
    required this.fullName,
    this.email,
    this.phone,
    this.profileImageUrl,
    this.fcmToken,
    this.homeAddress,
    this.createdAt,
    this.rating = 0.0,
    this.totalRides = 0,
    this.stripeCustomerId,
    this.searchHistory = const [],
  });

  factory Customer.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};

    final List<SearchHistoryItem> history = [];
    final rawHistory = m['searchHistory'];
    if (rawHistory is List) {
      for (final e in rawHistory) {
        if (e is Map<String, dynamic>) {
          history.add(SearchHistoryItem.fromMap(e));
        } else if (e is Map) {
          history.add(
            SearchHistoryItem.fromMap(
              e.map((k, v) => MapEntry(k.toString(), v)),
            ),
          );
        }
      }
    }

    return Customer(
      id: d.id,
      uid: (m['uid'] as String?) ?? d.id,
      fullName: (m['fullName'] ?? '') as String,
      email: m['email'] as String?,
      phone: m['phoneNumber'] as String?,
      profileImageUrl: m['profileImageUrl'] as String?,
      fcmToken: m['fcmToken'] as String?,
      homeAddress: m['homeAddress'] as String?,
      createdAt:
          m['createdAt'] is Timestamp ? m['createdAt'] as Timestamp : null,
      rating: (m['rating'] as num?)?.toDouble() ?? 0.0,
      totalRides: (m['totalRides'] as num?)?.toInt() ?? 0,
      stripeCustomerId: m['stripeCustomerId'] as String?,
      searchHistory: history,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phone,
      'profileImageUrl': profileImageUrl,
      'fcmToken': fcmToken,
      'homeAddress': homeAddress,
      'createdAt': createdAt,
      'rating': rating,
      'totalRides': totalRides,
      'stripeCustomerId': stripeCustomerId,
      'searchHistory': searchHistory.map((e) => e.toMap()).toList(),
    };

    // Remove nulls to avoid overwriting fields with null in Firestore
    map.removeWhere((_, v) => v == null);
    return map;
  }
}

class SearchHistoryItem {
  final String? title;
  final String? address;
  final double? latitude;
  final double? longitude;
  final Timestamp? timestamp;

  const SearchHistoryItem({
    this.title,
    this.address,
    this.latitude,
    this.longitude,
    this.timestamp,
  });

  factory SearchHistoryItem.fromMap(Map<String, dynamic> m) {
    return SearchHistoryItem(
      title: m['title'] as String?,
      address: m['address'] as String?,
      latitude: (m['latitude'] as num?)?.toDouble(),
      longitude: (m['longitude'] as num?)?.toDouble(),
      timestamp:
          m['timestamp'] is Timestamp ? m['timestamp'] as Timestamp : null,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
    };
    map.removeWhere((_, v) => v == null);
    return map;
  }
}
