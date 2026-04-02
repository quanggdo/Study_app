import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // Light Theme
  // ---------------------------------------------------------------------------
  static ThemeData light = FlexThemeData.light(
    scheme: FlexScheme.indigo,
    surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
    blendLevel: 12,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 14,
      blendOnColors: true,
      useTextTheme: true,
      useM2StyleDividerInM3: true,
      alignedDropdown: true,
      useInputDecoratorThemeInDialogs: true,
      // AppBar
      appBarBackgroundSchemeColor: SchemeColor.primary,
      appBarForegroundSchemeColor: SchemeColor.onPrimary,
      // Cards
      cardRadius: 16,
      // Buttons
      filledButtonRadius: 16,
      outlinedButtonRadius: 16,
      textButtonRadius: 12,
      // Input decoration
      inputDecoratorRadius: 16,
      inputDecoratorBackgroundAlpha: 20,
      // Dialogs
      dialogRadius: 20,
      // Chips
      chipRadius: 20,
      // Navigation bar
      navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
      navigationBarSelectedIconSchemeColor: SchemeColor.primary,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    swapLegacyOnMaterial3: true,
    fontFamily: GoogleFonts.inter().fontFamily,
  ).copyWith(
    scaffoldBackgroundColor: const Color(0xFFF5F6FA),
    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: const Color(0xFF3949AB).withOpacity(0.10),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        shadowColor: const Color(0xFF3949AB).withOpacity(0.25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
  );

  // ---------------------------------------------------------------------------
  // Dark Theme
  // ---------------------------------------------------------------------------
  static ThemeData dark = FlexThemeData.dark(
    scheme: FlexScheme.indigo,
    surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
    blendLevel: 18,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 24,
      useTextTheme: true,
      useM2StyleDividerInM3: true,
      alignedDropdown: true,
      useInputDecoratorThemeInDialogs: true,
      // AppBar
      appBarBackgroundSchemeColor: SchemeColor.surfaceContainer,
      // Cards
      cardRadius: 16,
      // Buttons
      filledButtonRadius: 16,
      outlinedButtonRadius: 16,
      textButtonRadius: 12,
      // Input
      inputDecoratorRadius: 16,
      inputDecoratorBackgroundAlpha: 30,
      // Dialogs
      dialogRadius: 20,
      chipRadius: 20,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    swapLegacyOnMaterial3: true,
    fontFamily: GoogleFonts.inter().fontFamily,
  ).copyWith(
    scaffoldBackgroundColor: const Color(0xFF0F1117),
    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.4),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  // ---------------------------------------------------------------------------
  // Design Tokens
  // ---------------------------------------------------------------------------

  /// Standard screen horizontal padding (from README).
  static const double screenPadding = 16.0;

  /// Standard corner radius for cards, buttons, dialogs (from README).
  static const double cardRadius = 16.0;

  /// Indigo primary gradient used throughout the app.
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3949AB), // Indigo 600
      Color(0xFF5C6BC0), // Indigo 400
      Color(0xFF7986CB), // Indigo 300
    ],
    stops: [0.0, 0.55, 1.0],
  );

  /// Deeper gradient for hero areas.
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A237E), // Indigo 900
      Color(0xFF283593), // Indigo 800
      Color(0xFF3949AB), // Indigo 600
    ],
    stops: [0.0, 0.45, 1.0],
  );
}
