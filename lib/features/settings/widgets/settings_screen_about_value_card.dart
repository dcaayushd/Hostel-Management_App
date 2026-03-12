part of '../screens/settings_screen.dart';

class _AboutValueCard extends StatelessWidget {
  const _AboutValueCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 11.h, 12.w, 11.h),
      decoration: BoxDecoration(
        color: AppColors.softSurfaceFor(brightness).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.borderFor(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedTextFor(brightness),
                  fontWeight: FontWeight.w700,
                ),
          ),
          heightSpacer(6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primaryTextFor(brightness),
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
