import 'package:flutter/material.dart';
import '../../../models/driver.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverReviewSheet extends StatelessWidget {
  final Driver driver;
  const DriverReviewSheet({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    final docs = [
      ('National ID', driver.nationalIdUrl),
      ('Driver License', driver.driversLicenseUrl),
      ('Car License', driver.carLicenseUrl),
      ('Criminal Record', driver.criminalRecordUrl),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review ${driver.fullName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            _kv('Driver ID', driver.id),
            _kv('Phone', driver.phone ?? '-'),
            _kv('Email', driver.email ?? '-'),
            _kv('Stripe Account', driver.stripeAccountId ?? '-'),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemBuilder: (_, i) {
                final title = docs[i].$1;
                final url = docs[i].$2;
                return _docCard(title, url);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _setStatus(context, 'active'),
                  icon: const Icon(Icons.check),
                  label: const Text('Approve'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _setStatus(context, 'rejected'),
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        SizedBox(
          width: 160,
          child: Text(
            '$k:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(v)),
      ],
    ),
  );

  Widget _docCard(String title, String? url) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black12),
      borderRadius: BorderRadius.circular(12),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(8),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child:
              url == null
                  ? const Center(child: Text('No file'))
                  : Image.network(url, fit: BoxFit.cover),
        ),
      ],
    ),
  );

  Future<void> _setStatus(BuildContext context, String status) async {
    await FirebaseFirestore.instance
        .collection('drivers')
        .doc(driver.id)
        .update({
          'status': status,
          'statusUpdatedAt': FieldValue.serverTimestamp(),
        });
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Driver $status')));
  }
}
