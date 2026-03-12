import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/colors.dart';

class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return Container(
      margin: margin ?? EdgeInsets.only(bottom: 14.h),
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            AppColors.panelSurfaceStartFor(brightness),
            AppColors.panelSurfaceEndFor(brightness).withValues(
              alpha: brightness == Brightness.dark ? 1 : 0.96,
            ),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.outlineFor(brightness)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: brightness == Brightness.dark
                ? const Color(0x28000000)
                : const Color(0x08183B2F),
            blurRadius: brightness == Brightness.dark ? 26 : 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
