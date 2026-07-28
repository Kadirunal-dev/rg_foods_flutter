import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color brandPrimary = Color(0xFFA30B29);
  static const Color brandSecondary = Color(0xFFEDA345);
  static const Color brandTetiary = Color(0xFF645DAF);

  static const Color textPrimary = Color(0xFF3E4462);
  static const Color textSecondary = Color(0xFF7E7E7E);
  static const Color textTertiary = Color(0xFFCACACA);
  static const Color bgColor = Color(0xFFF7F5F2);

  static const Color white = Color(0xFFFFFFFF);
  static const Color errorColor = Color.fromARGB(255, 235, 7, 7);
  static const Color errorRed = Color(0xFFFF0000);
}

abstract class AppTextStyles {
  static const titleLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 28,
    fontWeight: FontWeight.w900,
    height: 1.5,
  );
  static const titleMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1,
  );
  static const titleSmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 0.5,
  );
  static const bodymedium20 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1,
  );
  static const bodymedium16 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1,
  );
  static const bodyregular16 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1,
  );
  static const bodymedium14 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1,
  );
  static const bodyregular14 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1,
  );
  static const bodymedium12 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1,
  );
  static const bodyregular12 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1,
  );
  static const bodymedium10 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1,
  );
  static final ThemeData myTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.brandPrimary,
      primary: AppColors.brandPrimary,
      secondary: AppColors.brandSecondary,
      tertiary: AppColors.brandTetiary,

      onPrimary: AppColors.textPrimary,
      onSecondary: AppColors.textSecondary,
      onTertiary: AppColors.textTertiary,
      // ignore: deprecated_member_use
      onBackground: AppColors.bgColor,
      onSurface: AppColors.white,
      error: AppColors.errorColor,
    ),
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.titleLarge,
      displayMedium: AppTextStyles.titleMedium,
      displaySmall: AppTextStyles.titleSmall,
      bodyLarge: AppTextStyles.bodymedium20,
      bodyMedium: AppTextStyles.bodymedium16,
      bodySmall: AppTextStyles.bodyregular16,
      labelLarge: AppTextStyles.bodymedium14,
      labelMedium: AppTextStyles.bodyregular14,
      labelSmall: AppTextStyles.bodymedium12,
      titleMedium: AppTextStyles.bodyregular12,
      titleSmall: AppTextStyles.bodymedium10,
    ),
  );
}
