import 'package:flutter/material.dart';

import 'colors.dart';

class AppButtonStyles {
  const AppButtonStyles._();

  static const EdgeInsetsGeometry _defaultPadding =
      EdgeInsets.symmetric(horizontal: 18, vertical: 14);
  static const Size _defaultMinimumSize = Size(0, 48);

  static ButtonStyle filled(
    Brightness brightness, {
    Color backgroundColor = AppColors.kGreenColor,
    Color foregroundColor = Colors.white,
    EdgeInsetsGeometry padding = _defaultPadding,
    double radius = 18,
  }) {
    return ButtonStyle(
      elevation: const WidgetStatePropertyAll<double>(0),
      minimumSize: const WidgetStatePropertyAll<Size>(_defaultMinimumSize),
      padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(padding),
      foregroundColor: WidgetStatePropertyAll<Color>(foregroundColor),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return backgroundColor.withValues(
              alpha: brightness == Brightness.dark ? 0.42 : 0.52,
            );
          }
          return backgroundColor;
        },
      ),
      overlayColor: WidgetStatePropertyAll<Color>(
        foregroundColor.withValues(alpha: 0.10),
      ),
      shape: WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  static ButtonStyle outlined(
    Brightness brightness, {
    Color color = AppColors.kGreenColor,
    EdgeInsetsGeometry padding = _defaultPadding,
    double radius = 18,
  }) {
    return ButtonStyle(
      elevation: const WidgetStatePropertyAll<double>(0),
      minimumSize: const WidgetStatePropertyAll<Size>(_defaultMinimumSize),
      padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(padding),
      foregroundColor: WidgetStatePropertyAll<Color>(color),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.emphasisSurface(
              color,
              brightness,
              lightAlpha: 0.04,
              darkAlpha: 0.08,
            );
          }
          return AppColors.emphasisSurface(color, brightness);
        },
      ),
      side: WidgetStateProperty.resolveWith<BorderSide?>(
        (Set<WidgetState> states) {
          return BorderSide(
            color: states.contains(WidgetState.disabled)
                ? AppColors.emphasisBorder(
                    color,
                    brightness,
                    lightAlpha: 0.12,
                    darkAlpha: 0.18,
                  )
                : AppColors.emphasisBorder(color, brightness),
          );
        },
      ),
      shape: WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  static ButtonStyle tonal(
    Brightness brightness, {
    required Color color,
    EdgeInsetsGeometry padding = _defaultPadding,
    double radius = 18,
  }) {
    return ButtonStyle(
      elevation: const WidgetStatePropertyAll<double>(0),
      minimumSize: const WidgetStatePropertyAll<Size>(_defaultMinimumSize),
      padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(padding),
      foregroundColor: WidgetStatePropertyAll<Color>(color),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.emphasisSurface(
              color,
              brightness,
              lightAlpha: 0.06,
              darkAlpha: 0.10,
            );
          }
          return AppColors.emphasisSurface(
            color,
            brightness,
            lightAlpha: 0.10,
            darkAlpha: 0.18,
          );
        },
      ),
      side: WidgetStateProperty.resolveWith<BorderSide?>(
        (Set<WidgetState> states) {
          return BorderSide(
            color: AppColors.emphasisBorder(
              color,
              brightness,
              lightAlpha: 0.14,
              darkAlpha: 0.22,
            ),
          );
        },
      ),
      shape: WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
