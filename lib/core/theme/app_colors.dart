import 'package:flutter/material.dart';

/// Centralized color palette for CampusHub.
/// Never hardcode colors in widgets — always reference AppColors.
class AppColors {
  AppColors._(); // prevents instantiation

  // Brand
  static const Color primary = Color(0xFF1E3A5F); // Deep Indigo/Navy
  static const Color secondary = Color(0xFF3E7C87); // Muted Teal

  // Backgrounds
  static const Color background = Color(0xFFF8F9FB);
  static const Color surface = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF2B2D33);
  static const Color textSecondary = Color(0xFF6B6F76);

  // Status colors (complaint tracking)
  static const Color statusRed = Color(0xFFD64545); // Urgent/unresolved
  static const Color statusOrange = Color(0xFFE0932C); // In progress
  static const Color statusYellow = Color(0xFFE8C547); // Pending review
  static const Color statusGreen = Color(0xFF4A9B6E); // Resolved

  // Utility
  static const Color divider = Color(0xFFE3E5E9);
  static const Color error = Color(0xFFD64545);
}
