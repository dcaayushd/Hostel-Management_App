// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/app_icons.dart';
import '../../../theme/colors.dart';
import 'dashboard_card_frame.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    required this.icon,
    this.subtitle,
    this.countText,
    this.accentColor = AppColors.kGreenColor,
  });

  final String category;
  final String? subtitle;
  final String? countText;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool hasCount = countText != null && countText!.trim().isNotEmpty;
    final String? trimmedSubtitle =
        subtitle == null || subtitle!.trim().isEmpty ? null : subtitle!.trim();
    final Widget? countBadge = hasCount
        ? Container(
            constraints: BoxConstraints(
              minWidth: 40.w,
              minHeight: 28.h,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 5.h,
            ),
            decoration: BoxDecoration(
              color: brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.10)
                  : accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(
                color: brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.14)
                    : accentColor.withValues(alpha: 0.16),
              ),
            ),
            child: Text(
              countText!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: brightness == Brightness.dark
                        ? Colors.white
                        : accentColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                  ),
            ),
          )
        : null;

    return DashboardTileCard(
      accentColor: accentColor,
      onTap: onTap,
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              DashboardIconBadge(
                icon: icon,
                accentColor: accentColor,
                scale: 1.14,
              ),
              const Spacer(),
              DashboardIconBadge(
                icon: AppIcons.open,
                accentColor: accentColor,
                compact: true,
                scale: 1.08,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.primaryTextFor(brightness),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.14,
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        trimmedSubtitle ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.mutedTextFor(brightness),
                              fontWeight: FontWeight.w500,
                              fontSize: 12.4.sp,
                              height: 1.2,
                            ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    countBadge ?? SizedBox(height: 28.h, width: 40.w),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
