import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Spacing scale ───
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 12;
  static const double spacingL = 16;
  static const double spacingXL = 24;
  static const double spacingXXL = 32;

  // ─── Border radius scale ───
  static const double radiusS = 10;
  static const double radiusM = 14;
  static const double radiusL = 18;
  static const double radiusXL = 24;

  // ─── Primary palette ───
  static const Color primaryColor = Color(0xFF0EA5E9);
  static const Color primaryLight = Color(0xFF38BDF8);
  static const Color primaryDark = Color(0xFF0284C7);

  // ─── Light neutrals ───
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color neutralLight = Color(0xFFE2E8F0);
  static const Color neutralSoft = Color(0xFFF1F5F9);

  // Keep old names as aliases so existing screens compile
  static const Color warmBeige = neutralLight;
  static const Color warmCream = neutralSoft;

  // ─── Dark neutrals ───
  static const Color _darkBackground = Color(0xFF0F172A);
  static const Color _darkSurface = Color(0xFF1E293B);
  static const Color _darkSurfaceVariant = Color(0xFF334155);
  static const Color _darkNeutralLight = Color(0xFF475569);
  static const Color _darkNeutralSoft = Color(0xFF1E293B);

  // ─── Text ───
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);

  static const Color _darkTextPrimary = Color(0xFFF1F5F9);
  static const Color _darkTextSecondary = Color(0xFF94A3B8);
  static const Color _darkTextTertiary = Color(0xFF64748B);

  // ─── Semantic ───
  static const Color secondaryColor = Color(0xFF06B6D4);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color starColor = Color(0xFFF59E0B);

  // ─── Macro nutrient colors ───
  static const Color proteinLight = Color(0xFFE0F2FE);
  static const Color proteinDark = Color(0xFF0C4A6E);
  static const Color proteinBorderLight = Color(0xFFBAE6FD);
  static const Color proteinBorderDark = Color(0xFF075985);

  static const Color carbsLight = Color(0xFFFEF3C7);
  static const Color carbsDark = Color(0xFF78350F);
  static const Color carbsBorderLight = Color(0xFFFDE68A);
  static const Color carbsBorderDark = Color(0xFF92400E);

  static const Color fatLight = Color(0xFFD1FAE5);
  static const Color fatDark = Color(0xFF064E3B);
  static const Color fatBorderLight = Color(0xFFA7F3D0);
  static const Color fatBorderDark = Color(0xFF065F46);

  // ─── Meal type colors ───
  static const Color breakfastColor = Color(0xFFF59E0B);
  static const Color lunchColor = Color(0xFF0EA5E9);
  static const Color dinnerColor = Color(0xFF10B981);
  static const Color snackColor = Color(0xFF8B5CF6);

  // ─── Glass morphism ───
  static const Color glassWhite = Color(0xFFFFFFFF);

  // ─── Gradients (kept for backward compat, now teal) ───
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmBackgroundGradient = LinearGradient(
    colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Shadows (cool slate instead of warm brown) ───
  static BoxShadow warmShadowLight() => BoxShadow(
        color: const Color(0xFF0F172A).withValues(alpha: 0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      );

  static BoxShadow warmShadowMedium() => BoxShadow(
        color: const Color(0xFF0F172A).withValues(alpha: 0.08),
        blurRadius: 12,
        offset: const Offset(0, 2),
      );

  static BoxShadow warmShadowHeavy() => BoxShadow(
        color: const Color(0xFF0F172A).withValues(alpha: 0.12),
        blurRadius: 20,
        offset: const Offset(0, 6),
      );

  // ─── Dark shadow ───
  static BoxShadow darkShadow() => BoxShadow(
        color: Colors.black.withValues(alpha: 0.20),
        blurRadius: 12,
        offset: const Offset(0, 2),
      );

  // ─── Adaptive helpers ───
  static Color adaptive(BuildContext context,
      {required Color light, required Color dark}) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }

  static Color backgroundOf(BuildContext context) =>
      adaptive(context, light: backgroundColor, dark: _darkBackground);

  static Color surfaceOf(BuildContext context) =>
      adaptive(context, light: surfaceColor, dark: _darkSurface);

  static Color surfaceVariantOf(BuildContext context) =>
      adaptive(context, light: surfaceVariant, dark: _darkSurfaceVariant);

  static Color neutralLightOf(BuildContext context) =>
      adaptive(context, light: neutralLight, dark: _darkNeutralLight);

  static Color neutralSoftOf(BuildContext context) =>
      adaptive(context, light: neutralSoft, dark: _darkNeutralSoft);

  static Color textPrimaryOf(BuildContext context) =>
      adaptive(context, light: textPrimary, dark: _darkTextPrimary);

  static Color textSecondaryOf(BuildContext context) =>
      adaptive(context, light: textSecondary, dark: _darkTextSecondary);

  static Color textTertiaryOf(BuildContext context) =>
      adaptive(context, light: textTertiary, dark: _darkTextTertiary);

  static BoxShadow shadowOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkShadow()
          : warmShadowLight();

  // ─── Macro nutrient adaptive helpers ───
  static Color proteinTintOf(BuildContext context) =>
      adaptive(context, light: proteinLight, dark: proteinDark);
  static Color proteinBorderOf(BuildContext context) =>
      adaptive(context, light: proteinBorderLight, dark: proteinBorderDark);
  static Color carbsTintOf(BuildContext context) =>
      adaptive(context, light: carbsLight, dark: carbsDark);
  static Color carbsBorderOf(BuildContext context) =>
      adaptive(context, light: carbsBorderLight, dark: carbsBorderDark);
  static Color fatTintOf(BuildContext context) =>
      adaptive(context, light: fatLight, dark: fatDark);
  static Color fatBorderOf(BuildContext context) =>
      adaptive(context, light: fatBorderLight, dark: fatBorderDark);

  // ─── Light Theme ───
  static ThemeData get lightTheme {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    final poppinsTextTheme = GoogleFonts.poppinsTextTheme(base.textTheme);

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: _buildTextTheme(poppinsTextTheme, Brightness.light),
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
      inputDecorationTheme: _buildInputDecoration(Brightness.light),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: surfaceColor,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      dividerTheme: const DividerThemeData(
        color: neutralLight,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: neutralLight,
        selectedColor: primaryColor,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: textTertiary,
        elevation: 0,
      ),
    );
  }

  // ─── Dark Theme ───
  static ThemeData get darkTheme {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);
    final poppinsTextTheme = GoogleFonts.poppinsTextTheme(base.textTheme);

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: _darkSurface,
        error: errorColor,
      ),
      scaffoldBackgroundColor: _darkBackground,
      textTheme: _buildTextTheme(poppinsTextTheme, Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: _darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _darkTextPrimary,
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
      inputDecorationTheme: _buildInputDecoration(Brightness.dark),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: _darkSurface,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      dividerTheme: const DividerThemeData(
        color: _darkSurfaceVariant,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _darkSurfaceVariant,
        selectedColor: primaryColor,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _darkTextPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _darkSurface,
        selectedItemColor: primaryColor,
        unselectedItemColor: _darkTextTertiary,
        elevation: 0,
      ),
    );
  }

  // ─── Shared text theme builder ───
  static TextTheme _buildTextTheme(TextTheme base, Brightness brightness) {
    final primary =
        brightness == Brightness.dark ? _darkTextPrimary : textPrimary;
    final secondary =
        brightness == Brightness.dark ? _darkTextSecondary : textSecondary;
    final tertiary =
        brightness == Brightness.dark ? _darkTextTertiary : textTertiary;

    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: base.titleSmall?.copyWith(
        color: primary,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: base.bodyLarge?.copyWith(color: primary),
      bodyMedium: base.bodyMedium?.copyWith(color: secondary),
      bodySmall: base.bodySmall?.copyWith(color: tertiary),
      labelLarge: base.labelLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: base.labelMedium?.copyWith(
        color: secondary,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: base.labelSmall?.copyWith(
        color: tertiary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // ─── High Contrast Themes ───
  static ThemeData get highContrastLightTheme {
    return lightTheme.copyWith(
      colorScheme: lightTheme.colorScheme.copyWith(
        surface: Colors.white,
        onSurface: Colors.black,
      ),
      scaffoldBackgroundColor: Colors.white,
      textTheme: lightTheme.textTheme.apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.black, width: 1.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.black,
        thickness: 1.5,
      ),
    );
  }

  static ThemeData get highContrastDarkTheme {
    return darkTheme.copyWith(
      colorScheme: darkTheme.colorScheme.copyWith(
        surface: Colors.black,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.black,
      textTheme: darkTheme.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white, width: 1.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.white,
        thickness: 1.5,
      ),
    );
  }

  // ─── Shared input decoration builder ───
  static InputDecorationTheme _buildInputDecoration(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final fillColor = isDark ? _darkNeutralSoft : neutralSoft;
    final borderColor = isDark ? _darkNeutralLight : neutralLight;
    final hintColor = isDark ? _darkTextTertiary : textTertiary;
    final labelColor = isDark ? _darkTextSecondary : textSecondary;

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      hintStyle: GoogleFonts.poppins(
        color: hintColor,
        fontSize: 14,
      ),
      labelStyle: GoogleFonts.poppins(
        color: labelColor,
        fontSize: 14,
      ),
    );
  }
}
