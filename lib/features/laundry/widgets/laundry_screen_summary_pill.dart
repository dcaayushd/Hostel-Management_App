part of '../screens/laundry_screen.dart';

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: highlighted
              ? AppColors.activeSurfaceFor(
                  brightness,
                  color: AppColors.kGreenColor,
                  lightAlpha: 0.10,
                  darkAlpha: 0.18,
                )
              : AppColors.tonalSurfaceFor(brightness),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: highlighted
                ? AppColors.activeBorderFor(brightness)
                : AppColors.outlineFor(brightness),
          ),
          boxShadow: highlighted
              ? <BoxShadow>[
                  AppColors.activeShadow(
                    brightness,
                    color: AppColors.kGreenColor,
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryTextFor(brightness),
                    fontWeight: FontWeight.w800,
                  ),
            ),
            heightSpacer(2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedTextFor(brightness),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
