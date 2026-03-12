part of '../screens/hostel_fee_screen.dart';

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.summary,
  });

  final FeeSummary summary;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color primaryTextColor = AppColors.primaryTextFor(brightness);
    final Color mutedTextColor = AppColors.mutedTextFor(brightness);
    final String helperText;
    if (summary.isPaid) {
      helperText =
          'No reminders pending. The monthly balance is fully settled.';
    } else if (summary.lastReminderAt != null) {
      helperText =
          'Last reminder sent on ${_formatDate(summary.lastReminderAt)} for ${summary.billingMonth}.';
    } else {
      helperText =
          'No reminder has been sent yet. The current balance stays due until payment is completed.';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 42.h,
          width: 42.w,
          decoration: BoxDecoration(
            color: summary.isPaid
                ? AppColors.kGreenColor.withValues(alpha: 0.12)
                : AppColors.softSurfaceFor(brightness),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(
            summary.isPaid
                ? Icons.notifications_off_outlined
                : Icons.notifications_active_outlined,
            color: AppColors.kGreenColor,
            size: 20.sp,
          ),
        ),
        widthSpacer(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Payment Reminders',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: primaryTextColor,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  StatusChip(
                    label: summary.isPaid ? 'Settled' : 'Pending',
                    color: summary.isPaid
                        ? AppColors.kGreenColor
                        : const Color(0xFFD97706),
                  ),
                ],
              ),
              heightSpacer(6),
              Text(
                helperText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: mutedTextColor,
                      height: 1.45,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
