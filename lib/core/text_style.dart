import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

TextStyle appStyle({
  // double? fw,
  required double size,
  required Color color,
  required FontWeight fontWeight,
}) {
  return TextStyle(
    fontFamily: "NunitoSans",
    fontSize: size.sp,
    color: color,
    fontWeight: fontWeight,
    // fontVariations: fw == null ? [] : [FontVariation("wght", fw)],
  );
}
