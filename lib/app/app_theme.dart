import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/button_styles.dart';
import '../theme/text_theme.dart';
import '../theme/colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _buildTheme(Brightness.light);

  static ThemeData dark() => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color primaryText = AppColors.primaryTextFor(brightness);
    final Color mutedText = AppColors.mutedTextFor(brightness);
    final Color surface = AppColors.surfaceColor(brightness);
    final Color border = AppColors.borderFor(brightness);
    final Color appBarColor = AppColors.appBarColor(brightness);

    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.kGreenColor,
      primary: AppColors.kGreenColor,
      secondary: isDark ? const Color(0xFF6BC191) : const Color(0xFF0F766E),
      surface: surface,
      brightness: brightness,
    );
    final TextTheme baseTextTheme =
        ThemeData(brightness: brightness, useMaterial3: true).textTheme;
    final TextTheme textTheme = baseTextTheme.copyWith(
      headlineLarge: AppTextTheme.displayStyle(
        baseTextTheme.headlineLarge,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: primaryText,
        height: 1.06,
        letterSpacing: -0.35,
      ),
      headlineMedium: AppTextTheme.displayStyle(
        baseTextTheme.headlineMedium,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: primaryText,
        height: 1.15,
        letterSpacing: -0.2,
      ),
      headlineSmall: AppTextTheme.displayStyle(
        baseTextTheme.headlineSmall,
        fontSize: 25,
        fontWeight: FontWeight.w700,
        color: primaryText,
        height: 1.12,
        letterSpacing: -0.18,
      ),
      titleLarge: AppTextTheme.displayStyle(
        baseTextTheme.titleLarge,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryText,
        letterSpacing: -0.12,
      ),
      titleMedium: AppTextTheme.displayStyle(
        baseTextTheme.titleMedium,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryText,
        letterSpacing: -0.05,
      ),
      titleSmall: AppTextTheme.bodyStyle(
        baseTextTheme.titleSmall,
        fontSize: 15.5,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      bodyLarge: AppTextTheme.bodyStyle(
        baseTextTheme.bodyLarge,
        fontSize: 17,
        color: primaryText,
        height: 1.38,
        letterSpacing: 0.02,
      ),
      bodyMedium: AppTextTheme.bodyStyle(
        baseTextTheme.bodyMedium,
        fontSize: 15,
        color: mutedText,
        height: 1.42,
        letterSpacing: 0.01,
      ),
      bodySmall: AppTextTheme.captionStyle(
        baseTextTheme.bodySmall,
        fontSize: 13.5,
        color: mutedText,
        height: 1.4,
        letterSpacing: 0.01,
      ),
      labelLarge: AppTextTheme.bodyStyle(
        baseTextTheme.labelLarge,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      labelMedium: AppTextTheme.bodyStyle(
        baseTextTheme.labelMedium,
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      canvasColor: surface,
      cardColor: surface,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF09130F) : AppColors.kBackgroundColor,
      textTheme: textTheme,
      iconTheme: IconThemeData(
        color: isDark ? Colors.white : primaryText,
      ),
      primaryIconTheme: IconThemeData(
        color: isDark ? Colors.white : primaryText,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: appBarColor,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: AppButtonStyles.filled(brightness),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: AppButtonStyles.outlined(
          brightness,
          color: isDark ? const Color(0xFF9FDAB7) : AppColors.kDeepGreenColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppButtonStyles.filled(brightness),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor:
            isDark ? const Color(0xFF173025) : const Color(0xFFF2F7F4),
        selectedColor:
            isDark ? const Color(0xFF204635) : const Color(0xFFE2F1E7),
        secondarySelectedColor:
            isDark ? const Color(0xFF204635) : const Color(0xFFE2F1E7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        side: BorderSide.none,
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: primaryText,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.tonalSurfaceFor(brightness),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: textTheme.bodyMedium,
        labelStyle: textTheme.bodySmall?.copyWith(
          color: mutedText,
          fontWeight: FontWeight.w700,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.outlineFor(brightness)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.kGreenColor,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFB42318)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFB42318), width: 1.4),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(
            AppColors.tonalSurfaceFor(brightness),
          ),
          surfaceTintColor:
              const WidgetStatePropertyAll<Color>(Colors.transparent),
          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: AppColors.outlineFor(brightness)),
            ),
          ),
        ),
        textStyle: textTheme.bodyLarge?.copyWith(
          color: primaryText,
          fontWeight: FontWeight.w600,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: primaryText,
        textColor: primaryText,
        tileColor: Colors.transparent,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.kGreenColor;
            }
            return isDark ? const Color(0xFF8CA79C) : null;
          },
        ),
        trackColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.kGreenColor.withValues(alpha: 0.40);
            }
            return isDark ? const Color(0xFF264137) : null;
          },
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          textStyle: WidgetStatePropertyAll<TextStyle?>(
            textTheme.bodyMedium?.copyWith(
              color: primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return isDark ? Colors.white : AppColors.kSecondaryColor;
              }
              return mutedText;
            },
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.kGreenColor.withValues(
                  alpha: isDark ? 0.28 : 0.14,
                );
              }
              return AppColors.softSurfaceFor(brightness).withValues(
                alpha: isDark ? 0.92 : 0.82,
              );
            },
          ),
          side: WidgetStateProperty.resolveWith<BorderSide?>(
            (Set<WidgetState> states) {
              return BorderSide(
                color: states.contains(WidgetState.selected)
                    ? AppColors.kGreenColor.withValues(alpha: 0.48)
                    : border,
              );
            },
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isDark ? const Color(0xFF163127) : AppColors.kSecondaryColor,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor:
              isDark ? const Color(0xFF88D3A7) : AppColors.kGreenColor,
          textStyle: textTheme.labelLarge?.copyWith(
            color: isDark ? const Color(0xFF88D3A7) : AppColors.kGreenColor,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
