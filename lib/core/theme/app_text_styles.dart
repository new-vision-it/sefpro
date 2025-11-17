import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:play5/core/theme/app_colors.dart';

/// Text styles built on Cairo font to support Arabic and English.
class AppTextStyles {
  static TextTheme textTheme(BuildContext context) {
    final base = Theme.of(context).textTheme;
    return GoogleFonts.cairoTextTheme(base).copyWith(
      displayLarge: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: AppColors.secondary),
      displayMedium: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: AppColors.secondary),
      headlineMedium: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: AppColors.secondary),
      headlineSmall: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: AppColors.secondary),
      titleLarge: GoogleFonts.cairo(fontWeight: FontWeight.w600, color: AppColors.secondary),
      titleMedium: GoogleFonts.cairo(fontWeight: FontWeight.w600, color: AppColors.secondary),
      titleSmall: GoogleFonts.cairo(fontWeight: FontWeight.w500, color: AppColors.secondary),
      bodyLarge: GoogleFonts.cairo(fontWeight: FontWeight.w500, color: AppColors.secondary),
      bodyMedium: GoogleFonts.cairo(fontWeight: FontWeight.w400, color: AppColors.secondary),
      bodySmall: GoogleFonts.cairo(fontWeight: FontWeight.w400, color: AppColors.secondary.withOpacity(0.8)),
      labelLarge: GoogleFonts.cairo(fontWeight: FontWeight.w600, color: Colors.white),
    );
  }
}
