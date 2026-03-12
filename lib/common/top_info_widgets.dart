import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/colors.dart';

BoxDecoration buildTopInfoSurfaceDecoration(
  BuildContext context, {
  Color accentColor = AppColors.kTopInfoAccentColor,
  BorderRadiusGeometry borderRadius = const BorderRadius.all(
    Radius.circular(28),
  ),
}) {
  final Brightness brightness = Theme.of(context).brightness;
  return BoxDecoration(
    borderRadius: borderRadius,
    gradient: AppColors.topInfoSurfaceGradient(
      brightness,
      accentColor: accentColor,
    ),
    border: Border.all(
      color: Colors.white.withValues(
        alpha: brightness == Brightness.dark ? 0.12 : 0.10,
      ),
    ),
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: brightness == Brightness.dark
            ? const Color(0x22000000)
            : const Color(0x12173C32),
        blurRadius: 22,
        offset: const Offset(0, 12),
      ),
    ],
  );
}

BoxDecoration buildTopInfoGlassDecoration({
  BorderRadiusGeometry borderRadius = const BorderRadius.all(
    Radius.circular(16),
  ),
  bool showBorder = false,
  double fillAlpha = 0.12,
  double borderAlpha = 0.14,
}) {
  return BoxDecoration(
    color: Colors.white.withValues(alpha: fillAlpha),
    borderRadius: borderRadius,
    border: showBorder
        ? Border.all(
            color: Colors.white.withValues(alpha: borderAlpha),
          )
        : null,
  );
}

class AppTopInfoCard extends StatelessWidget {
  const AppTopInfoCard({
    super.key,
    required this.child,
    this.accentColor = AppColors.kTopInfoAccentColor,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  final Widget child;
  final Color accentColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final BorderRadiusGeometry resolvedBorderRadius =
        borderRadius ?? BorderRadius.circular(28.r);
    return Container(
      margin: margin,
      padding: padding ?? EdgeInsets.all(14.w),
      decoration: buildTopInfoSurfaceDecoration(
        context,
        accentColor: accentColor,
        borderRadius: resolvedBorderRadius,
      ),
      child: child,
    );
  }
}

class AppTopInfoIconBox extends StatelessWidget {
  const AppTopInfoIconBox({
    super.key,
    required this.icon,
    this.size = 46,
    this.iconSize = 22,
    this.borderRadius = 16,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.h,
      width: size.w,
      decoration: buildTopInfoGlassDecoration(
        borderRadius: BorderRadius.circular(borderRadius.r),
        showBorder: true,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: iconSize.sp,
      ),
    );
  }
}

class AppTopInfoPill extends StatelessWidget {
  const AppTopInfoPill({
    super.key,
    required this.label,
    this.padding,
    this.borderRadius = 999,
    this.showBorder = false,
  });

  final String label;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: 6.h,
          ),
      decoration: buildTopInfoGlassDecoration(
        borderRadius: BorderRadius.circular(borderRadius.r),
        showBorder: showBorder,
        fillAlpha: 0.14,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class AppTopInfoStatusChip extends StatelessWidget {
  const AppTopInfoStatusChip({
    super.key,
    required this.label,
    this.accentColor = AppColors.kTopInfoAccentColor,
    this.padding,
    this.borderRadius = 999,
  });

  final String label;
  final Color accentColor;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 7.h,
          ),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(borderRadius.r),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.98),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accentColor.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class AppTopInfoFilterChip extends StatelessWidget {
  const AppTopInfoFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.accentColor = AppColors.kTopInfoAccentColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected
              ? accentColor.withValues(alpha: 0.88)
              : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: selected
                ? accentColor.withValues(alpha: 0.98)
                : Colors.white.withValues(alpha: 0.16),
          ),
          boxShadow: selected
              ? <BoxShadow>[
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.16),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class AppTopInfoIconPill extends StatelessWidget {
  const AppTopInfoIconPill({
    super.key,
    required this.icon,
    required this.label,
    this.padding,
    this.borderRadius = 16,
    this.maxWidth,
    this.expand = false,
    this.showBorder = false,
  });

  final IconData icon;
  final String label;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double? maxWidth;
  final bool expand;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final Widget text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
    );

    return Container(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: 7.h,
          ),
      decoration: buildTopInfoGlassDecoration(
        borderRadius: BorderRadius.circular(borderRadius.r),
        showBorder: showBorder,
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: Colors.white, size: 15.sp),
          SizedBox(width: 6.w),
          if (expand)
            Expanded(child: text)
          else if (maxWidth != null)
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth!.w),
              child: text,
            )
          else
            text,
        ],
      ),
    );
  }
}

class AppTopInfoStatTile extends StatelessWidget {
  const AppTopInfoStatTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.padding,
    this.borderRadius = 18,
    this.showBorder = false,
    this.fillAlpha = 0.12,
  });

  final String label;
  final String value;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool showBorder;
  final double fillAlpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(10.w),
      decoration: buildTopInfoGlassDecoration(
        borderRadius: BorderRadius.circular(borderRadius.r),
        showBorder: showBorder,
        fillAlpha: fillAlpha,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, color: Colors.white, size: 20.sp),
            SizedBox(height: 12.h),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class AppTopInfoAvatar extends StatelessWidget {
  const AppTopInfoAvatar({
    super.key,
    required this.initials,
    required this.size,
    this.padding = 4,
    this.textStyle,
    this.gradient = const LinearGradient(
      colors: <Color>[Color(0xFFBCDCD3), Color(0xFF5C877F)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    this.shadow,
  });

  final String initials;
  final double size;
  final double padding;
  final TextStyle? textStyle;
  final LinearGradient gradient;
  final BoxShadow? shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.h,
      width: size.w,
      padding: EdgeInsets.all(padding.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
        boxShadow: shadow == null ? null : <BoxShadow>[shadow!],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: gradient,
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: textStyle ??
              Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
        ),
      ),
    );
  }
}
