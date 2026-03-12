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
    final Color color =
        active ? AppColors.kGreenColor : AppColors.kMutedTextColor;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: active ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        active ? '$label done' : '$label off',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
