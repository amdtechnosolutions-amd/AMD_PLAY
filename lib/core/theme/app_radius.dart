import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Border radius tokens adhering to the 18–28px rounded modern sports aesthetic.
class AppRadius {
  AppRadius._();

  static double get xs => 8.r;
  static double get sm => 12.r;
  static double get md => 16.r;
  static double get lg => 20.r;
  static double get xl => 24.r;
  static double get xxl => 28.r;
  static double get pill => 999.r;

  // BorderRadius objects
  static BorderRadius get xsBorder => BorderRadius.circular(xs);
  static BorderRadius get smBorder => BorderRadius.circular(sm);
  static BorderRadius get mdBorder => BorderRadius.circular(md);
  static BorderRadius get lgBorder => BorderRadius.circular(lg);
  static BorderRadius get xlBorder => BorderRadius.circular(xl);
  static BorderRadius get xxlBorder => BorderRadius.circular(xxl);
  static BorderRadius get pillBorder => BorderRadius.circular(pill);

  // Top rounded for bottom sheets and curved headers
  static BorderRadius get sheetBorder => BorderRadius.vertical(top: Radius.circular(xxl));
}
