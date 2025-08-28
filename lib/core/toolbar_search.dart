import 'package:flutter/material.dart';

class ToolbarSearch extends StatelessWidget {
  final String hint;
  final void Function(String) onSubmitted;
  final double height;
  const ToolbarSearch({
    super.key,
    required this.hint,
    required this.onSubmitted,
    this.height = 44,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}
