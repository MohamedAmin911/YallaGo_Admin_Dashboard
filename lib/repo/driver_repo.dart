import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/driver.dart';

class DriversRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<Driver>> listen(String status) {
    Query<Map<String, dynamic>> q = _db
        .collection('drivers')
        .orderBy('createdAt', descending: true);
    q = q.where('status', isEqualTo: status);
    return q
        .limit(200)
        .snapshots()
        .map((s) => s.docs.map(Driver.fromDoc).toList());
  }

  Future<void> setStatus(String id, String status) {
    return _db.collection('drivers').doc(id).update({
      'status': status,
      'statusUpdatedAt': FieldValue.serverTimestamp(),
    });
  }
}
