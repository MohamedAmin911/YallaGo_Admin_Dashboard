import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yallago_admin_dashboard/models/driver.dart';

class DriversTrackingRepository {
  final FirebaseFirestore _db;
  DriversTrackingRepository([FirebaseFirestore? db])
    : _db = db ?? FirebaseFirestore.instance;

  // Guaranteed-to-stream version (no index needed)
  Stream<List<Driver>> listenOnlineWithLocation() {
    final query = _db.collection('drivers').where('isOnline', isEqualTo: true);
    return query.snapshots(includeMetadataChanges: false).map((s) {
      // Debug: see if Firestore is sending changes
      // ignore: unused_local_variable
      for (final c in s.docChanges) {
        // expect many "modified" while driver moves
        // print('[drivers] ${c.type} ${c.doc.id}');
      }
      return s.docs
          .map(Driver.fromDoc)
          .where((d) => d.currentLocation != null)
          .toList();
    });
  }

  // When everything works and you create the index, you can switch to this:
  Stream<List<Driver>> listenOnlineWithLocationOrdered() {
    final query = _db
        .collection('drivers')
        .where('isOnline', isEqualTo: true)
        .orderBy('updatedAt', descending: false)
        .limit(2000);
    return query.snapshots().map((s) {
      return s.docs
          .map(Driver.fromDoc)
          .where((d) => d.currentLocation != null)
          .toList();
    });
  }
}
