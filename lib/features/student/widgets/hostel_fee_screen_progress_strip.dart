part of '../screens/hostel_fee_screen.dart';

class _ProgressStrip extends StatelessWidget {
  const _ProgressStrip({
    required this.label,
    required this.value,
    required this.caption,
  });

  final String label;
  final double value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final double clampedValue = value.clamp(0, 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _mutedTextColor(context),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Text(
              caption,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _primaryTextColor(context),
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        heightSpacer(8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999.r),
          child: LinearProgressIndicator(
            minHeight: 8.h,
            value: clampedValue,
            backgroundColor: AppColors.kSoftSurfaceColor,
            color: AppColors.kGreenColor,
          ),
        ),
      ],
    );
  }
}
