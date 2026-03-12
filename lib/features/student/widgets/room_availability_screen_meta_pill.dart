part of '../screens/room_availability_screen.dart';

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color surfaceColor = brightness == Brightness.dark
        ? const Color(0xFF173127)
        : AppColors.tonalSurfaceFor(brightness);
    final Color accentColor = brightness == Brightness.dark
        ? const Color(0xFF6DC892)
        : AppColors.kGreenColor;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: Color.alphaBlend(
            AppColors.kGreenColor.withValues(
              alpha: brightness == Brightness.dark ? 0.22 : 0.10,
            ),
            AppColors.borderFor(brightness),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16.sp, color: accentColor),
          widthSpacer(8),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
