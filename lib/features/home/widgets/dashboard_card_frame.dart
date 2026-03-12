import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/colors.dart';

class DashboardSectionCard extends StatelessWidget {
  const DashboardSectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool isDark = brightness == Brightness.dark;
    final Color sectionStartColor = Color.alphaBlend(
      AppColors.kGreenColor.withValues(
        alpha: isDark ? 0.10 : 0.03,
      ),
      AppColors.panelSurfaceStartFor(brightness),
    );
    final Color sectionEndColor = Color.alphaBlend(
      AppColors.kDeepGreenColor.withValues(
        alpha: isDark ? 0.06 : 0.015,
      ),
      AppColors.panelSurfaceEndFor(brightness),
    );

    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[sectionStartColor, sectionEndColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(34.r),
        border: Border.all(
          color: isDark
              ? Color.alphaBlend(
                  AppColors.kGreenColor.withValues(alpha: 0.22),
                  AppColors.outlineFor(brightness),
                )
              : AppColors.kCreamPanelBorder,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: isDark ? const Color(0x26000000) : const Color(0x120E0A04),
            blurRadius: isDark ? 24 : 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryTextFor(brightness),
                  fontWeight: FontWeight.w800,
                  fontSize: 16.5.sp,
                ),
          ),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }
}

class DashboardTileCard extends StatelessWidget {
  const DashboardTileCard({
    super.key,
    required this.accentColor,
    required this.child,
    this.onTap,
    this.padding,
    this.borderRadius,
  });

  final Color accentColor;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool isDark = brightness == Brightness.dark;
    final double radius = borderRadius ?? 28.r;
    final Color baseStart = AppColors.surfaceColor(brightness);
    final Color baseEnd = AppColors.softSurfaceFor(brightness);
    final Color cardStartColor = Color.alphaBlend(
      accentColor.withValues(
        alpha: isDark ? 0.22 : 0.055,
      ),
      baseStart,
    );
    final Color cardEndColor = Color.alphaBlend(
      accentColor.withValues(
        alpha: isDark ? 0.12 : 0.025,
      ),
      baseEnd,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          padding: padding ?? EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[cardStartColor, cardEndColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: isDark
                  ? Color.alphaBlend(
                      accentColor.withValues(alpha: 0.18),
                      AppColors.outlineFor(brightness),
                    )
                  : Color.alphaBlend(
                      accentColor.withValues(alpha: 0.10),
                      AppColors.kCreamPanelBorder,
                    ),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color:
                    isDark ? const Color(0x1A000000) : const Color(0x100D0903),
                blurRadius: isDark ? 18 : 13,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class DashboardIconBadge extends StatelessWidget {
  const DashboardIconBadge({
    super.key,
    required this.icon,
    required this.accentColor,
    this.compact = false,
    this.scale = 1,
  });

  final IconData icon;
  final Color accentColor;
  final bool compact;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final double boxSize = (compact ? 24.w : 36.w) * scale;
    final double iconSize = (compact ? 13.sp : 18.sp) * scale;

    return Container(
      height: boxSize,
      width: boxSize,
      decoration: BoxDecoration(
        color: brightness == Brightness.dark
            ? Colors.white.withValues(alpha: compact ? 0.08 : 0.10)
            : accentColor.withValues(alpha: compact ? 0.07 : 0.09),
        borderRadius: BorderRadius.circular(
          (compact ? 10.r : 14.r) * scale.clamp(1, 1.2).toDouble(),
        ),
        border: Border.all(
          color: brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.14)
              : accentColor.withValues(alpha: 0.14),
        ),
      ),
      child: Icon(
        icon,
        color: brightness == Brightness.dark
            ? Colors.white
            : accentColor.withValues(alpha: 0.92),
        size: iconSize,
      ),
    );
  }
}
