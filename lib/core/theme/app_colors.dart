import 'package:flutter/material.dart';

/// Raw color values for the JobologyX design system. Widgets should read
/// colors from `Theme.of(context).colorScheme` / `AppTextStyles` rather than
/// referencing this class directly, except for status colors which have no
/// ColorScheme equivalent.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryDark = Color(0xFF6366F1); // Indigo 500 (dark mode)
  static const Color secondary = Color(0xFF0EA5E9); // Sky 500

  // Light theme surfaces
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Dark theme surfaces
  static const Color darkBackground = Color(0xFF0F172A); // slate-900
  static const Color darkSurface = Color(0xFF1E293B); // slate-800
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Semantic
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  // Application status badges
  static const Color statusApplied = Color(0xFF2563EB);
  static const Color statusReviewing = Color(0xFFD97706);
  static const Color statusShortlisted = Color(0xFF7C3AED);
  static const Color statusRejected = Color(0xFFDC2626);
  static const Color statusHired = Color(0xFF16A34A);

  // Job status badges
  static const Color statusActive = Color(0xFF16A34A);
  static const Color statusClosed = Color(0xFF64748B);
  static const Color statusDraft = Color(0xFFD97706);
}
