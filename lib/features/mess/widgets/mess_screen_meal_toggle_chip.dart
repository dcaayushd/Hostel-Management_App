part of '../screens/mess_screen.dart';

class _MealToggleChip extends StatelessWidget {
  const _MealToggleChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color surfaceColor = brightness == Brightness.dark
        ? AppColors.tonalSurfaceFor(brightness)
        : const Color(0xFFF8FCFA);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.activeSurfaceFor(
                    brightness,
                    color: AppColors.kGreenColor,
                    lightAlpha: 0.12,
                    darkAlpha: 0.20,
                  )
                : surfaceColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: selected
                  ? AppColors.activeBorderFor(
                      brightness,
                      color: AppColors.kGreenColor,
                    )
                  : AppColors.outlineFor(brightness),
            ),
            boxShadow: selected
                ? <BoxShadow>[
                    AppColors.activeShadow(
                      brightness,
                      color: AppColors.kGreenColor,
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
                color: selected
                    ? AppColors.kGreenColor
                    : AppColors.mutedTextFor(brightness),
                size: 16.sp,
              ),
              widthSpacer(7),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: selected
                          ? AppColors.primaryTextFor(brightness)
                          : AppColors.mutedTextFor(brightness),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
