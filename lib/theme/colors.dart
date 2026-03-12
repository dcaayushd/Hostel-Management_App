import 'package:flutter/material.dart';

LinearGradient linearColor() {
  return LinearGradient(
    colors: AppColors.colors,
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    stops: const [0.4, 0.7],
    tileMode: TileMode.repeated,
  );
}

LinearGradient backgroundLinearColor() {
  return const LinearGradient(
    colors: [AppColors.kBackgroundColor, AppColors.kSoftSurfaceColor],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.4, 0.7],
    tileMode: TileMode.repeated,
  );
}

class AppColors {
  AppColors._();
  static const Color kPrimaryColor = Color(0xFF133B2F);
  static const Color kGreenColor = Color(0xFF2E8B57);
  static const Color kDeepGreenColor = Color(0xFF1F5A45);
  static const Color kTopInfoAccentColor = Color(0xFF2B6CB0);
  static const Color kLightBlue = Color(0xFF8AB8D0);
  static const Color kSecondaryColor = Color(0xFF173C32);
  static const Color kMutedTextColor = Color(0xFF5E746C);
  static const Color kBackgroundColor = Color(0xFFFFFCF7);
  static const Color kSoftSurfaceColor = Color(0xFFFDF7EE);
  static const Color kBorderColor = Color(0xFFECE1D0);
  static const Color kCreamSurface = Color(0xFFFFFBF4);
  static const Color kCreamSurfaceSoft = Color(0xFFFCF7EF);
  static const Color kCreamSurfaceAlt = Color(0xFFF9F1E3);
  static const Color kCreamPanelStart = Color(0xFFFFFAF2);
  static const Color kCreamPanelEnd = Color(0xFFFDF4E8);
  static const Color kCreamPanelBorder = Color(0xFFEBDFC9);
  static const Color kFormLabelColor = kGreenColor;
  static const Color kLight = Color(0xFFffffff);
  static const Color kGreyDk = Color(0xFF9091AD);
  static const Color kAppBarColor = Color(0xFF0B2C47);
  static const Color kRewardBackgroundColor = Color(0xFF18122B);
  static const Color kButtonColor = Color(0xF1F1F1F1);
  static const Color keventCardColor = Color(0xFFF1F3FF);
  static const Color kchatBackgroundColor = Color(0xFFF1F3FF);

  static List<Color> colors = [
    const Color(0xFF3765DD),
    const Color(0xFF7464D2)
  ];
  static List<Color> winnerBackgroundColors = [
    const Color(0xFF6C00FF),
    const Color(0xFF7147E5),
  ];

  static Color appBarColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? const Color(0xFF203B36)
        : const Color(0xFF2C5951);
  }

  static LinearGradient appBarChromeGradient(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const LinearGradient(
        colors: <Color>[Color(0xFF355E56), Color(0xFF152D29)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return const LinearGradient(
      colors: <Color>[Color(0xFF4F8075), Color(0xFF244842)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient heroGradient(Brightness brightness) {
    return appBarChromeGradient(brightness);
  }

  static LinearGradient topInfoSurfaceGradient(
    Brightness brightness, {
    Color accentColor = kTopInfoAccentColor,
  }) {
    final LinearGradient base = heroGradient(brightness);
    final Color startColor = Color.alphaBlend(
      accentColor.withValues(
        alpha: brightness == Brightness.dark ? 0.16 : 0.10,
      ),
      base.colors.first,
    );
    final Color endColor = Color.alphaBlend(
      accentColor.withValues(
        alpha: brightness == Brightness.dark ? 0.08 : 0.05,
      ),
      base.colors.last,
    );
    return LinearGradient(
      colors: <Color>[startColor, endColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient topChromeFade(Brightness brightness) {
    final Color color = appBarColor(brightness);
    return LinearGradient(
      colors: <Color>[
        color,
        color.withValues(alpha: brightness == Brightness.dark ? 0.92 : 0.88),
        color.withValues(alpha: brightness == Brightness.dark ? 0.42 : 0.24),
        Colors.transparent,
      ],
      stops: const <double>[0.0, 0.36, 0.72, 1.0],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  static LinearGradient floatingChromeGradient(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const LinearGradient(
        colors: <Color>[Color(0xFF17382D), Color(0xFF10261E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return const LinearGradient(
      colors: <Color>[Color(0xFF224E40), Color(0xFF17382E)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient screenBackgroundGradient(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const LinearGradient(
        colors: <Color>[
          Color(0xFF355E56),
          Color(0xFF254842),
          Color(0xFF18322D),
          Color(0xFF0D1814),
          Color(0xFF0A1512),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: <double>[0.0, 0.24, 0.42, 0.58, 1.0],
      );
    }
    return const LinearGradient(
      colors: <Color>[
        Color(0xFF4F8075),
        Color(0xFF3A6B62),
        Color(0xFF244842),
        kBackgroundColor,
        kSoftSurfaceColor,
        kCreamSurface,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: <double>[0.0, 0.24, 0.42, 0.58, 0.76, 1.0],
    );
  }

  static Color surfaceColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? const Color(0xFF12271E)
        : kCreamSurface;
  }

  static Color softSurfaceFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? const Color(0xFF183228)
        : kCreamSurfaceSoft;
  }

  static Color borderFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? const Color(0xFF2C4A3D)
        : kBorderColor;
  }

  static Color primaryTextFor(Brightness brightness) {
    return brightness == Brightness.dark ? Colors.white : kSecondaryColor;
  }

  static Color mutedTextFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? const Color(0xD9FFFFFF)
        : kMutedTextColor;
  }

  static Color panelSurfaceStartFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? const Color(0xFF10261D)
        : kCreamPanelStart;
  }

  static Color panelSurfaceEndFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? const Color(0xFF0C1B15)
        : kCreamPanelEnd;
  }

  static Color tonalSurfaceFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? const Color(0xFF173127)
        : kCreamSurfaceSoft;
  }

  static Color tonalSurfaceAltFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? const Color(0xFF1C382D)
        : kCreamSurfaceAlt;
  }

  static Color outlineFor(Brightness brightness) {
    return Color.alphaBlend(
      AppColors.kGreenColor.withValues(
        alpha: brightness == Brightness.dark ? 0.22 : 0.08,
      ),
      borderFor(brightness),
    );
  }
}
