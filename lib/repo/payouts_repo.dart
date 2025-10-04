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

  Future<void> _emailPayoutNotification({
    required String driverUid,
    required String payoutId,
    required int amountCents,
    required String currency,
    required String status,
    String? transferId,
  }) async {
    final driverDoc = await _db.collection('drivers').doc(driverUid).get();
    final toEmail = driverDoc.data()?['email'] as String?;
    final driverName = (driverDoc.data()?['fullName'] as String?) ?? 'Driver';
    if (toEmail == null || toEmail.isEmpty) return;

    final amountText = (amountCents / 100).toStringAsFixed(2);
    final subj =
        status == 'paid'
            ? 'Payout ${currency.toUpperCase()} $amountText sent'
            : 'Payout ${currency.toUpperCase()} $amountText approved';

    final bodyHtml = '''
<div style="font-family: Arial, sans-serif; color:#111;">
  <h2 style="margin:0 0 12px;">${status == 'paid' ? 'Payout sent' : 'Payout approved'}</h2>
  <p>Hello $driverName,</p>
  <p>Your payout of <b>EGP $amountText</b> has been $status.</p>
  <p style="margin-top:16px;">Thanks,<br/>Your Team</p>
</div>
''';

    final resp = await http.post(
      Uri.parse('$base/notify_payout_email'),
      headers: _headers,
      body: json.encode({
        'to': toEmail,
        'subject': subj,
        'html': bodyHtml,
        'data': {
          'type': 'payout',
          'payoutId': payoutId,
          'status': status,
          'amountCents': '$amountCents',
          'currency': currency.toUpperCase(),
          'driverName': driverName,
          if (transferId != null) 'transferId': transferId,
        },
      }),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      return;
    }
    final Map<String, dynamic> res =
        json.decode(resp.body) as Map<String, dynamic>;
    if (res['ok'] != true) {
      return;
    }
  }

  Future<void> approvePayout({
    required PayoutRequest req,
    required String adminUid,
    bool alsoCreateBankPayout = true,
  }) async {
    final ref = _db.collection('payouts').doc(req.id);

    final resp = await http.post(
      Uri.parse('$base/payout_execute'),
      headers: _headers,
      body: json.encode({
        'accountId': req.driverStripeAccountId,
        'amountCents': req.amountCents,
        'currency': 'usd',
        'idempotencyKey': req.id,
        'createPayout': alsoCreateBankPayout,
      }),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      await ref.update({
        'status': 'failed',
        'approvedBy': adminUid,
        'approvedAt': FieldValue.serverTimestamp(),
        'failureReason':
            'HTTP ${resp.statusCode}: ${resp.body.isNotEmpty ? resp.body : 'payout_execute error'}',
      });
      throw Exception('payout_execute failed: HTTP ${resp.statusCode}');
    }

    final Map<String, dynamic> data =
        json.decode(resp.body) as Map<String, dynamic>;
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

    final newStatus = payoutId != null ? 'paid' : 'approved';
    await ref.update({
      'status': newStatus,
      'approvedBy': adminUid,
      'approvedAt': FieldValue.serverTimestamp(),
      'processedAt': FieldValue.serverTimestamp(),
      'transferId': transferId,
      'payoutId': payoutId,
    });

    await _emailPayoutNotification(
      driverUid: req.driverUid,
      payoutId: req.id,
      amountCents: req.amountCents,
      currency: 'usd',
      status: newStatus,
      transferId: transferId,
    );
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
      if ((d['status'] ?? '') != 'pending') throw Exception('Not pending');

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
