part of '../screens/mess_screen.dart';

class _MealStatusPill extends StatelessWidget {
  const _MealStatusPill({
    required this.label,
    required this.active,
  });

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color color =
        active ? AppColors.kGreenColor : AppColors.mutedTextFor(brightness);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: active
            ? AppColors.activeSurfaceFor(
                brightness,
                color: color,
                lightAlpha: 0.12,
                darkAlpha: 0.22,
              )
            : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: active
              ? AppColors.activeBorderFor(
                  brightness,
                  color: color,
                  lightAlpha: 0.24,
                  darkAlpha: 0.34,
                )
              : color.withValues(alpha: 0.12),
        ),
        boxShadow: active
            ? <BoxShadow>[
                AppColors.activeShadow(
                  brightness,
                  color: color,
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (active) ...<Widget>[
            Icon(Icons.check_circle_rounded, size: 14.sp, color: color),
            widthSpacer(6),
          ],
          Text(
            active ? '$label done' : '$label off',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
