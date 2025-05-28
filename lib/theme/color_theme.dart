import 'package:flutter/material.dart';

/// Centralised colour palette for the whole app.
///
///  ── *Add/edit here → propagates everywhere*.
class AppColors {
  // ── Brand
  static const primary = Color(0xFF2563EB); // Vibrant blue
  static const secondary = Color(0xFF0D9488); // Modern teal
  static const accent = Color(0xFF7C3AED); // Purple (CTAs/links)

  // ── Status
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  // ── Background / surface
  static const background = Color(0xFFF9FAFB);
  static const surface = Color(0xFFFFFFFF);

  // ── Text
  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);
  static const textDisabled = Color(0xFF9CA3AF);

  // ── Greys
  static const grayLight = Color(0xFFE5E7EB);
  static const gray = Color(0xFFD1D5DB);
  static const grayDark = Color(0xFF4B5563);

  // ── Extras (hover / pressed)
  static const lightBlue = Color(0xFFEFF6FF);
  static const darkBlue = Color(0xFF1E40AF);

  // ── Newly-added: tertiary shades used in Auth screens
  static const tertiary = Color(0xFF0EA5E9); // Sky blue – form focus states
  static const tertiary2 = Color(0xFF0284C7); // Darker sky – primary buttons

  // Convenience
  static const white = Color(0xFFFFFFFF);
}
