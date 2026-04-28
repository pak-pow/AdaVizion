// ─── APP COLORS ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

/// Global color palette for the EUventure app.
///
/// All colors are defined here as a single source of truth.
/// Screen-level color constants (e.g. `QRCodeConstants`, `kQuizMaroon`)
/// should be replaced with references to this class.
///
/// When light/dark mode is introduced, split this into
/// [AppColors.light] and [AppColors.dark] and wire into [ThemeData].
abstract final class AppColors {
  // ─── BRAND: MAROON ────────────────────────────────────────────────────────

  /// Primary brand color. Used for borders, icons, and accent elements.
  static const Color maroon = Color(0xFF7A1D1D);

  /// Darker maroon. Used for buttons, dialog headers, and filled surfaces.
  static const Color maroonDark = Color(0xFF5D1414);

  /// Mid maroon. Used for gradient tops in quiz and dashboard banners.
  static const Color maroonGradientTop = Color(0xFFB11C1C);

  /// Lighter brand maroon. Used for secondary elements or highlights.
  static const Color maroonLight = Color(0xFFA62121);

  /// Bright brand maroon. Used in primary branding gradients.
  static const Color maroonBright = Color(0xFFB72424);

  /// Darkest gradient stop. Used on quiz list screen header banner.
  static const Color maroonGradientBottom = Color(0xFF4B0C0C);

  /// Deep brand maroon. Used for specific highlight elements.
  static const Color maroonDeep = Color(0xFF700000);

  // ─── BRAND: NEUTRALS ──────────────────────────────────────────────────────

  /// Light grey. Used as AppBar background across screens.
  static const Color headerGrey = Color(0xFFF5F5F5);

  /// Divider / separator color.
  static const Color divider = Color(0xFFDDDDDD);

  /// Light background grey. Used in gradients and surfaces.
  static const Color backgroundGrey = Color(0xFFEBEBEB);

  /// Light surface grey. Used in app bars and cards.
  static const Color surfaceGrey = Color(0xFFF5F5F5);

  /// Near-white surface color. Used for screen backgrounds.
  static const Color surfaceWhite = Color(0xFFF7F7F9);

  /// Near-black surface color. Used for screen backgrounds (primarily in QR SCAN).
  static const Color surfaceBlack = Color(0xFF080806);

  // --- Neutral / Grey semantic tokens ---
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575); // shade 600
  static const Color textLight = Color(0xFF9E9E9E); // shade 400
  static const Color borderLight = Color(0xFFE0E0E0); // shade 300
  static const Color shadowLight = Color(0x0D000000); // black with 0.05 alpha

  // ─── ACCENTS ──────────────────────────────────────────────────────────────

  /// Gold. Used for XP and reward highlights on the dashboard.
  static const Color gold = Color(0xFFFFB300);

  /// Scholar Gold. Used for scholar category badge accents.
  static const Color scholarGold = Color(0xFFFFD700);

  /// Amber / warm peach. Used for decorative accents on the dashboard.
  static const Color amber = Color(0xFFE8A87C);

  /// Silver / Metallic. Used for unlocked badge borders.
  static const Color silver = Color(0xFFC0C0C0);

  // ─── SEMANTIC: SUCCESS / PASS ─────────────────────────────────────────────

  /// Dark green. Used for pass indicators, correct answers, and fun-fact headers.
  static const Color green = Color(0xFF2E7D32);

  /// Fun-fact card green. Used for the lightbulb icon and "FUN FACT" label text.
  static const Color funFactIcon = Color(0xFF2E7D52);

  /// Fun-fact card mint. Used as the card background fill.
  static const Color funFactBGFill = Color(0xFFF0FAF4);

  /// Fun-fact card sage. Used as the card border color.
  static const Color funFactBorder = Color(0xFFB2DFC4);

  /// Fun-fact card deep green. Used for the body text inside the card.
  static const Color funFactBody = Color(0xFF1A3D2B);

  // ─── SEMANTIC: ERROR / FAIL ───────────────────────────────────────────────

  /// Red. Used for fail indicators and wrong answer highlights in quizzes.
  static const Color failRed = Color(0xFFC62828);
}
