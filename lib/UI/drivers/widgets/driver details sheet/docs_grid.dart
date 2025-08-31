import 'package:flutter/material.dart';
import 'package:yallago_admin_dashboard/UI/drivers/widgets/driver%20details%20sheet/doc_card.dart';

class DocsGrid extends StatelessWidget {
  final List<(String, String?)> docs;

  const DocsGrid({super.key, required this.docs});

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
        return DocCard(title: title, url: url);
      },
    );
  }
}
