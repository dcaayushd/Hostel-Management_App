part of '../screens/mess_screen.dart';

class _MenuItemPill extends StatelessWidget {
  const _MenuItemPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final String displayValue =
        value.trim().isEmpty ? 'Not published yet' : value;
    return Container(
      constraints: BoxConstraints(minWidth: 92.w, maxWidth: 240.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.tonalSurfaceAltFor(brightness),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.outlineFor(brightness)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Icon(
              icon,
              size: 14.sp,
              color: AppColors.kGreenColor,
            ),
          ),
          widthSpacer(6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primaryTextFor(brightness),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  displayValue,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedTextFor(brightness),
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
