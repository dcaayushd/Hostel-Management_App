part of '../screens/search_screen.dart';

class _SearchStatChip extends StatelessWidget {
  const _SearchStatChip({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.softSurfaceFor(brightness).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderFor(brightness)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 16.sp,
            color: AppColors.iconColorFor(brightness),
          ),
          widthSpacer(8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryTextFor(brightness),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
