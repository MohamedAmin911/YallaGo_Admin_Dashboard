import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yallago_admin_dashboard/models/driver.dart';

class DriversTrackingRepository {
  final FirebaseFirestore _db;
  DriversTrackingRepository([FirebaseFirestore? db])
    : _db = db ?? FirebaseFirestore.instance;

  Stream<List<Driver>> listenAllWithLocation() {
    return _db
        .collection('drivers')
        .orderBy('createdAt', descending: true)
        .limit(2000)
        .snapshots()
        .map(
          (s) =>
              s.docs
                  .map(Driver.fromDoc)
                  .where((d) => d.currentLocation != null)
                  .toList(),
        );
  }
}
