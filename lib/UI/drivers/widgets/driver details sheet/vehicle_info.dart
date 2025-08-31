import 'package:flutter/material.dart';
import 'package:yallago_admin_dashboard/core/color_theme.dart';
import 'package:yallago_admin_dashboard/models/driver.dart';

class VehicleInfo extends StatelessWidget {
  final Driver driver;

  const VehicleInfo({super.key, required this.driver});

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
