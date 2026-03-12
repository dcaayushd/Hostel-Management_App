import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/colors.dart';

class AppMetaChip extends StatelessWidget {
  const AppMetaChip({
    super.key,
    required this.icon,
    required this.label,
    this.accentColor = AppColors.kGreenColor,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final Color accentColor;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.activeSurfaceFor(
                brightness,
                color: accentColor,
                lightAlpha: 0.10,
                darkAlpha: 0.18,
              )
            : AppColors.tonalSurfaceFor(brightness),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: highlighted
              ? AppColors.activeBorderFor(
                  brightness,
                  color: accentColor,
                  lightAlpha: 0.22,
                  darkAlpha: 0.30,
                )
              : AppColors.emphasisBorder(
                  accentColor,
                  brightness,
                  lightAlpha: 0.12,
                  darkAlpha: 0.22,
                ),
        ),
        boxShadow: highlighted
            ? <BoxShadow>[
                AppColors.activeShadow(
                  brightness,
                  color: accentColor,
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 16.sp,
            color: AppColors.iconColorFor(
              brightness,
              lightColor: accentColor,
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryTextFor(brightness),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
