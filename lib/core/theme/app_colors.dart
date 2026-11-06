import 'package:flutter/material.dart';

/// Design tokens for colors as defined in the Kinetic Sports Academy brand direction (Brand Yellow #F9D106).
class AppColors {
  AppColors._();

  // Primary Brand Colors (Brand Yellow matching Login #F9D106)
  static const Color primary = Color(0xFFF9D106);
  static const Color primaryDark = Color(0xFFE5BE00);
  static const Color primaryDeep = Color(0xFFD97706);
  static const Color primaryLight = Color(0xFFFFF9DB);
  static const Color primarySubtle = Color(0xFFFFFDE7);

  // Vibrant Accent (Coral / Amber / Dark)
  static const Color accent = Color(0xFF0F172A);
  static const Color accentDark = Color(0xFF0A0D14);
  static const Color accentLight = Color(0xFFFFF1F1);

  // Background & Surfaces
  static const Color background = Color(0xFFF9D106);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF8FAFC);

  // Typography & Neutral Scales
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Semantic Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFF87171);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF0EA5E9);
  static const Color infoLight = Color(0xFFF0F9FF);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);

  // Slot States
  static const Color slotAvailable = Color(0xFF10B981);
  static const Color slotSelected = Color(0xFFF9D106);
  static const Color slotBooked = Color(0xFFCBD5E1);
  static const Color slotMaintenance = Color(0xFFF59E0B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF9D106), Color(0xFFECC100)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient yellowHeroGradient = LinearGradient(
    colors: [Color(0xFFFFDF38), Color(0xFFF9D106), Color(0xFFE5BE00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardOverlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
