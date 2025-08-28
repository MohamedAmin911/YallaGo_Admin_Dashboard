import 'package:flutter/material.dart';

class AdminColors {
  static const primary = Color(0xfffcbd01);
  static const secondary = Color(0xFF5433FF);
  static const primaryText = Color(0xff282F39);
  static const whiteText = Color(0xffFFFFFF);
  static const secondaryText = Color(0xff7F7F7F);
  static const placeholder = Color(0xffBBBBBB);
  static const lightGray = Color(0xffDADEE3);
  static const lightWhite = Color(0xffF2F5F7);
  static const danger = Color(0xffDF344B);
  static const bg = Colors.white;
}

ThemeData adminTheme() {
  final base = ThemeData.light();
  return base.copyWith(
    scaffoldBackgroundColor: AdminColors.bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: AdminColors.bg,
      foregroundColor: AdminColors.primaryText,
      elevation: 0,
    ),
    colorScheme: base.colorScheme.copyWith(
      primary: AdminColors.primary,
      secondary: AdminColors.secondary,
      surface: AdminColors.bg,
      error: AdminColors.danger,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AdminColors.lightGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AdminColors.lightGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AdminColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );
}
