import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yallago_admin_dashboard/models/customer.dart';

class CustomersRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<Customer>> listen(String tab) {
    // Customers don’t have a status. We keep the same API and
    // let 'tab' be a UI scope (e.g., 'all'). Adjust if you add filters.
    Query<Map<String, dynamic>> q = _db
        .collection('customers')
        .orderBy('createdAt', descending: true);

    return q
        .limit(200)
        .snapshots()
        .map((s) => s.docs.map(Customer.fromDoc).toList());
  }
}
