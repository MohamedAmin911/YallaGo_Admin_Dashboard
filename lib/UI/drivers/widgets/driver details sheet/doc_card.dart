import 'package:flutter/material.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';

class DocCard extends StatelessWidget {
  final String title;
  final String? url;

  const DocCard({super.key, required this.title, required this.url});

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
}
