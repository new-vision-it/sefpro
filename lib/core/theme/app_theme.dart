import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:play5/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme(Locale locale) {
    final isRtl = locale.languageCode == 'ar';
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    return base.copyWith(
      primaryColor: AppColors.gold,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.gold,
        brightness: Brightness.light,
        primary: AppColors.gold,
        secondary: AppColors.secondary,
        background: AppColors.background,
        error: AppColors.error,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.secondary,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: GoogleFonts.cairo(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: AppColors.secondary,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.card,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 2,
      ),
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme).copyWith(
        titleLarge: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: AppColors.secondary),
        titleMedium: GoogleFonts.cairo(fontWeight: FontWeight.w600, color: AppColors.secondary),
        titleSmall: GoogleFonts.cairo(fontWeight: FontWeight.w500, color: AppColors.secondary),
        bodyLarge: GoogleFonts.cairo(fontWeight: FontWeight.w500, color: AppColors.secondary),
        bodyMedium: GoogleFonts.cairo(fontWeight: FontWeight.w400, color: AppColors.secondary),
        bodySmall: GoogleFonts.cairo(fontWeight: FontWeight.w400, color: AppColors.secondary.withOpacity(0.8)),
        labelLarge: GoogleFonts.cairo(fontWeight: FontWeight.w600, color: Colors.white),
      ),
      visualDensity: isRtl ? VisualDensity.compact : VisualDensity.adaptivePlatformDensity,
      dividerColor: Colors.grey.shade200,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
    );
  }

  static ThemeData darkTheme(Locale locale) {
    final isRtl = locale.languageCode == 'ar';
    final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);
    return base.copyWith(
      primaryColor: AppColors.gold,
      scaffoldBackgroundColor: const Color(0xFF0F1720),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.gold,
        brightness: Brightness.dark,
        primary: AppColors.gold,
        secondary: AppColors.goldDark,
        background: const Color(0xFF0F1720),
        error: AppColors.error,
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1F2933),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 2,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1F2933),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: GoogleFonts.cairo(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme).copyWith(
        titleLarge: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: Colors.white),
        titleMedium: GoogleFonts.cairo(fontWeight: FontWeight.w600, color: Colors.white),
        titleSmall: GoogleFonts.cairo(fontWeight: FontWeight.w500, color: Colors.white),
        bodyLarge: GoogleFonts.cairo(fontWeight: FontWeight.w500, color: Colors.white),
        bodyMedium: GoogleFonts.cairo(fontWeight: FontWeight.w400, color: Colors.white),
        bodySmall: GoogleFonts.cairo(fontWeight: FontWeight.w400, color: Colors.white70),
        labelLarge: GoogleFonts.cairo(fontWeight: FontWeight.w600, color: Colors.white),
      ),
      visualDensity: isRtl ? VisualDensity.compact : VisualDensity.adaptivePlatformDensity,
      dividerColor: Colors.grey.shade800,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
    );
  }
}
