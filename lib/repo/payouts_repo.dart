import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:yallago_admin_dashboard/core/keys.dart';
import 'package:yallago_admin_dashboard/models/payout_request.dart';

class PayoutsRepository {
  final FirebaseFirestore _db;
  final String base;
  PayoutsRepository({FirebaseFirestore? db, required this.base})
    : _db = db ?? FirebaseFirestore.instance;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'x-api-key': KapiKeys.pipedreamApiKey,
  };

  Stream<List<PayoutRequest>> listenAll({int limit = 1000}) {
    return _db
        .collection('payouts')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(PayoutRequest.fromDoc).toList());
  }

  Future<void> approvePayout({
    required PayoutRequest req,
    required String adminUid,
    bool alsoCreateBankPayout = true,
  }) async {
    final ref = _db.collection('payouts').doc(req.id);
    // 1) Transfer (and payout) via your Pipedream route (two-step or combined)
    final r = await http.post(
      Uri.parse(
        '$base/payout_execute',
      ), // or payout_execute_smart if you added it
      headers: _headers,
      body: json.encode({
        'accountId': req.driverStripeAccountId,
        'amountCents': req.amountCents,
        'currency': 'usd',
        'idempotencyKey': req.id,
        'createPayout': alsoCreateBankPayout,
      }),
    );
    final data = json.decode(r.body) as Map<String, dynamic>;
    if (data['ok'] != true) {
      await ref.update({
        'status': 'failed',
        'approvedBy': adminUid,
        'approvedAt': FieldValue.serverTimestamp(),
        'failureReason': data['error'] ?? 'Unknown error',
      });
      throw Exception(data['error'] ?? 'Payout failed');
    }

    final transferId = (data['transfer'] ?? {})['id'] as String?;
    final payoutId = (data['payout'] ?? {})['id'] as String?;

    await ref.update({
      'status': payoutId != null ? 'paid' : 'approved',
      'approvedBy': adminUid,
      'approvedAt': FieldValue.serverTimestamp(),
      'processedAt': FieldValue.serverTimestamp(),
      'transferId': transferId,
      'payoutId': payoutId,
    });
  }

  Future<void> rejectPayout({
    required String payoutId,
    required String adminUid,
    String? reason,
  }) async {
    final ref = _db.collection('payouts').doc(payoutId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) throw Exception('Payout not found');
      final d = snap.data() as Map<String, dynamic>;
      if (d['status'] != 'pending') throw Exception('Not pending');

      // refund balance
      final driverUid = d['driverUid'] as String;
      final amountCents = d['amountCents'] as int;
      final driverRef = _db.collection('drivers').doc(driverUid);
      final dsnap = await tx.get(driverRef);
      final balance = ((dsnap.data()?['balance'] ?? 0.0) as num).toDouble();
      tx.update(driverRef, {'balance': balance + amountCents / 100.0});

      tx.update(ref, {
        'status': 'rejected',
        'approvedBy': adminUid,
        'approvedAt': FieldValue.serverTimestamp(),
        'failureReason': reason ?? 'Admin rejected',
      });
    });
  }
}
