import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/driver.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';

class DriverReviewSheet extends StatefulWidget {
  final Driver driver;
  const DriverReviewSheet({super.key, required this.driver});

  @override
  State<DriverReviewSheet> createState() => _DriverReviewSheetState();
}

class _DriverReviewSheetState extends State<DriverReviewSheet> {
  bool _busy = false;

  Driver get d => widget.driver;

  @override
  Widget build(BuildContext context) {
    final docs = [
      ('National ID', d.nationalIdUrl),
      ('Driver License', d.driversLicenseUrl),
      ('Car License', d.carLicenseUrl),
      ('Criminal Record', d.criminalRecordUrl),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Avatar + name + status + copy chips
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child:
                          (d.profileImageUrl != null &&
                                  d.profileImageUrl!.isNotEmpty)
                              ? Image.network(
                                d.profileImageUrl!,
                                width: 200,
                                height: 200,
                                fit: BoxFit.fitWidth,
                              )
                              : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _StatusPill(status: d.status),
                              const SizedBox(height: 8),
                              _TagChip(
                                icon: Icons.badge_outlined,
                                label: 'Driver: ${d.id}',
                                onCopy: () => _copy(d.id),
                              ),
                              if ((d.stripeAccountId ?? '').isNotEmpty) ...[
                                const SizedBox(height: 8),
                                _TagChip(
                                  icon:
                                      Icons
                                          .account_balance_rounded, // fallback icon; Android can lack this — it’s ok
                                  label: 'Stripe: ${d.stripeAccountId}',
                                  onCopy: () => _copy(d.stripeAccountId!),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_busy)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Two-column responsive content
                LayoutBuilder(
                  builder: (context, c) {
                    final tight = c.maxWidth < 700;

                    if (tight) {
                      return Column(
                        children: [
                          _SectionCard(
                            title: 'Profile Information',
                            child: _ProfileInfo(driver: d),
                          ),
                          const SizedBox(height: 12),
                          _SectionCard(
                            title: 'Vehicle Information',
                            child: _VehicleInfo(driver: d),
                          ),
                          const SizedBox(height: 12),
                          _SectionCard(
                            title: 'KYC Documents',
                            child: _DocsGrid(docs: docs),
                          ),
                          const SizedBox(height: 12),
                          _SectionCard(
                            title: 'Actions',
                            child: _ActionsRow(
                              status: d.status,
                              onApprove: () => _setStatus(context, 'active'),
                              onReject: () => _setStatus(context, 'rejected'),
                              onSuspend: () => _setStatus(context, 'suspended'),
                              onActivate: () => _setStatus(context, 'active'),
                              busy: _busy,
                            ),
                          ),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column
                        Expanded(
                          child: Column(
                            children: [
                              _SectionCard(
                                title: 'Profile Information',
                                child: _ProfileInfo(driver: d),
                              ),
                              const SizedBox(height: 12),
                              _SectionCard(
                                title: 'Vehicle Information',
                                child: _VehicleInfo(driver: d),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Right column
                        Expanded(
                          child: Column(
                            children: [
                              _SectionCard(
                                title: 'KYC Documents',
                                child: _DocsGrid(docs: docs),
                              ),
                              const SizedBox(height: 12),
                              _SectionCard(
                                title: 'Actions',
                                child: _ActionsRow(
                                  status: d.status,
                                  onApprove:
                                      () => _setStatus(context, 'active'),
                                  onReject:
                                      () => _setStatus(context, 'rejected'),
                                  onSuspend:
                                      () => _setStatus(context, 'suspended'),
                                  onActivate:
                                      () => _setStatus(context, 'active'),
                                  busy: _busy,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _setStatus(BuildContext context, String status) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await FirebaseFirestore.instance.collection('drivers').doc(d.id).update({
        'status': status,
        'statusUpdatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Driver $status')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copy(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
    }
  }
}

// ========== UI Blocks ==========

class _ProfileInfo extends StatelessWidget {
  final Driver driver;
  const _ProfileInfo({required this.driver});

  Widget _kv(String k, String v, {bool bold = true}) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$k:',
            style: const TextStyle(
              color: AdminColors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            v.isEmpty ? '—' : v,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final balance = 'EGP ${(driver.balance).toStringAsFixed(2)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _kv('Name', driver.fullName),
        _kv('Phone', driver.phone ?? '—'),
        _kv('Email', driver.email ?? '—'),
        _kv('Balance', balance),
        _kv('Stripe Account', driver.stripeAccountId ?? '—', bold: false),
      ],
    );
  }
}

class _VehicleInfo extends StatelessWidget {
  final Driver driver;
  const _VehicleInfo({required this.driver});

  Widget _kv(String k, Widget v) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$k:',
            style: const TextStyle(
              color: AdminColors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        v,
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _kv(
          'Model',
          Text(
            driver.carModel ?? "",
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        _kv(
          'Plate',
          Text(
            driver.licensePlate ?? "",
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        _kv(
          'Color',
          Icon(
            Icons.lens,
            size: 20,
            color: Color(int.parse('0xff${driver.carColor!.substring(1)}')),
          ),
        ),
        const SizedBox(height: 8),
        if ((driver.carImageUrl ?? '').isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              driver.carImageUrl!,
              height: 140,
              width: 140,
              fit: BoxFit.cover,
            ),
          ),
      ],
    );
  }
}

class _DocsGrid extends StatelessWidget {
  final List<(String, String?)> docs;
  const _DocsGrid({required this.docs});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: docs.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (_, i) {
        final (title, url) = docs[i];
        return _DocCard(title: title, url: url);
      },
    );
  }
}

class _DocCard extends StatelessWidget {
  final String title;
  final String? url;
  const _DocCard({required this.title, required this.url});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (url ?? '').isEmpty ? null : () => openPreview(context, url!),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AdminColors.lightGray.withOpacity(0.6)),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(10),
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child:
                  (url ?? '').isEmpty
                      ? const Center(
                        child: Text(
                          'No file',
                          style: TextStyle(color: AdminColors.secondaryText),
                        ),
                      )
                      : Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(url!, fit: BoxFit.cover),
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.zoom_in,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }

  void openPreview(BuildContext context, String url) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: InteractiveViewer(
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
          ),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  final String status;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onSuspend;
  final VoidCallback onActivate;
  final bool busy;

  const _ActionsRow({
    required this.status,
    required this.onApprove,
    required this.onReject,
    required this.onSuspend,
    required this.onActivate,
    required this.busy,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = status == 'pending_approval';
    final isActive = status == 'active';
    final isSusp = status == 'suspended';

    return Row(
      children: [
        if (isPending)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: busy ? null : onApprove,
              icon: const Icon(Icons.check),
              label: const Text(
                'Approve',
                style: TextStyle(color: AdminColors.bg),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primary,
                foregroundColor: AdminColors.primaryText,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        if (isPending) const SizedBox(width: 12),
        if (isPending)
          Expanded(
            child: ElevatedButton(
              onPressed: busy ? null : onReject,
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.danger,
                side: const BorderSide(color: AdminColors.danger),
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              child: const Text(
                'Reject',
                style: TextStyle(color: AdminColors.bg),
              ),
            ),
          ),
        if (!isPending && isActive) ...[
          Expanded(
            child: ElevatedButton(
              onPressed: busy ? null : onSuspend,
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.danger,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Suspend',
                style: TextStyle(color: AdminColors.bg),
              ),
            ),
          ),
        ],
        if (!isPending && isSusp) ...[
          Expanded(
            child: ElevatedButton(
              onPressed: busy ? null : onActivate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,

                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Activate',
                style: TextStyle(color: AdminColors.bg),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final l = status.toLowerCase();
    Color c = Colors.grey;
    if (l == 'pending_approval') c = Colors.orange;
    if (l == 'active') c = Colors.green;
    if (l == 'suspended') c = AdminColors.danger;
    if (l == 'rejected') c = Colors.redAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        l.isEmpty
            ? '-'
            : l[0].toUpperCase() + l.substring(1).replaceAll('_', ' '),
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AdminColors.lightGray.withOpacity(0.6)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onCopy;

  const _TagChip({required this.icon, required this.label, this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AdminColors.lightWhite,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AdminColors.lightGray),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AdminColors.secondaryText),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          if (onCopy != null) ...[
            const SizedBox(width: 4),
            InkWell(
              customBorder: const CircleBorder(),
              onTap: onCopy,
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.copy, size: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
