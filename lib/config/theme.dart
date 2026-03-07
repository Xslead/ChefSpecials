import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary palette
  static const Color primaryColor = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8F65);
  static const Color primaryDark = Color(0xFFE85A25);

  // Warm neutrals
  static const Color backgroundColor = Color(0xFFFFF8F3);
  static const Color surfaceColor = Colors.white;
  static const Color surfaceVariant = Color(0xFFFFF1E8);
  static const Color warmBeige = Color(0xFFF5E6D3);
  static const Color warmCream = Color(0xFFFFF5EC);

  // Text
  static const Color textPrimary = Color(0xFF2D1B0E);
  static const Color textSecondary = Color(0xFF8B7355);
  static const Color textTertiary = Color(0xFFB8A08A);

  // Semantic
  static const Color secondaryColor = Color(0xFF2EC4B6);
  static const Color errorColor = Color(0xFFE63946);
  static const Color starColor = Color(0xFFFFB800);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmBackgroundGradient = LinearGradient(
    colors: [Color(0xFFFFF8F3), Color(0xFFFFF1E8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Warm shadows (brown-tinted instead of pure black)
  static BoxShadow warmShadowLight() => BoxShadow(
        color: const Color(0xFF8B4513).withValues(alpha: 0.06),
        blurRadius: 8,
        offset: const Offset(0, 2),
      );

  static BoxShadow warmShadowMedium() => BoxShadow(
        color: const Color(0xFF8B4513).withValues(alpha: 0.10),
        blurRadius: 16,
        offset: const Offset(0, 4),
      );

  static BoxShadow warmShadowHeavy() => BoxShadow(
        color: const Color(0xFF8B4513).withValues(alpha: 0.15),
        blurRadius: 24,
        offset: const Offset(0, 8),
      );

  static ThemeData get lightTheme {
    final base = ThemeData(useMaterial3: true);
    final poppinsTextTheme = GoogleFonts.poppinsTextTheme(base.textTheme);

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: poppinsTextTheme.copyWith(
        headlineLarge: poppinsTextTheme.headlineLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: poppinsTextTheme.headlineMedium?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: poppinsTextTheme.headlineSmall?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: poppinsTextTheme.titleLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: poppinsTextTheme.titleMedium?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: poppinsTextTheme.titleSmall?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: poppinsTextTheme.bodyLarge?.copyWith(
          color: textPrimary,
        ),
        bodyMedium: poppinsTextTheme.bodyMedium?.copyWith(
          color: textSecondary,
        ),
        bodySmall: poppinsTextTheme.bodySmall?.copyWith(
          color: textTertiary,
        ),
        labelLarge: poppinsTextTheme.labelLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: poppinsTextTheme.labelMedium?.copyWith(
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: poppinsTextTheme.labelSmall?.copyWith(
          color: textTertiary,
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: warmCream,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: warmBeige),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: warmBeige),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorColor),
        ),
        hintStyle: GoogleFonts.poppins(
          color: textTertiary,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.poppins(
          color: textSecondary,
          fontSize: 14,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        color: surfaceColor,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFF0E4D8),
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: warmBeige,
        selectedColor: primaryColor,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }
}
