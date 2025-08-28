import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip.dart';

class TripsRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<Trip>> listen({String? status}) {
    Query<Map<String, dynamic>> q = _db
        .collection('trips')
        .orderBy('requestedAt', descending: true)
        .limit(200);
    if (status != null && status != 'all') {
      q = q.where('status', isEqualTo: status);
    }
    return q.snapshots().map((s) => s.docs.map(Trip.fromDoc).toList());
  }
}
