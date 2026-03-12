part of '../screens/mess_screen.dart';

class _StarBadge extends StatelessWidget {
  const _StarBadge({
    required this.rating,
  });

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFB54708).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.star_rounded,
            color: const Color(0xFFB54708),
            size: 14.sp,
          ),
          widthSpacer(4),
          Text(
            rating.toString(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(0xFFB54708),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
