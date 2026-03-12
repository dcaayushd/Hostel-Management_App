part of '../screens/hostel_fee_screen.dart';

class _AdminResidentFeeTile extends StatelessWidget {
  const _AdminResidentFeeTile({
    required this.student,
    required this.summary,
    required this.roomLabel,
    required this.onSendReminder,
    required this.onCollectFee,
    required this.onOpenChat,
  });

  final AppUser student;
  final FeeSummary? summary;
  final String? roomLabel;
  final VoidCallback onSendReminder;
  final VoidCallback onCollectFee;
  final VoidCallback onOpenChat;

  @override
  Widget build(BuildContext context) {
    final FeeSummary? dues = summary;
    final bool hasUnpaidDues = dues != null && !dues.isPaid;
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: _softSurfaceColor(context),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: _borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 21.r,
                backgroundColor: AppColors.kGreenColor.withValues(alpha: 0.14),
                child: Text(
                  student.firstName.characters.first.toUpperCase(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.kGreenColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              widthSpacer(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      student.fullName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: _primaryTextColor(context),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    heightSpacer(2),
                    Text(
                      roomLabel == null
                          ? 'No room assigned'
                          : '$roomLabel • ${dues?.billingMonth ?? 'Current cycle'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _mutedTextColor(context),
                          ),
                    ),
                    heightSpacer(8),
                    if (dues != null)
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: <Widget>[
                          StatusChip(
                            label: dues.isPaid ? 'Settled' : 'Due',
                            color: dues.isPaid
                                ? AppColors.kGreenColor
                                : const Color(0xFFD97706),
                          ),
                          Text(
                            'Balance Rs ${_formatAmount(dues.balance)}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: _primaryTextColor(context),
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'No current billing summary yet',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _mutedTextColor(context),
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          heightSpacer(12),
          Column(
            children: <Widget>[
              if (hasUnpaidDues)
                Row(
                  children: <Widget>[
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onCollectFee,
                        style: _actionButtonStyle(
                          context,
                          FilledButtonTheme.of(context).style,
                        ),
                        icon: const Icon(Icons.payments_outlined),
                        label: const Text('Collect'),
                      ),
                    ),
                    widthSpacer(10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onSendReminder,
                        style: _actionButtonStyle(
                          context,
                          OutlinedButtonTheme.of(context).style,
                        ),
                        icon: const Icon(Icons.notifications_active_outlined),
                        label: const Text('Remind'),
                      ),
                    ),
                  ],
                ),
              if (hasUnpaidDues) heightSpacer(10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onOpenChat,
                  style: _actionButtonStyle(
                    context,
                    OutlinedButtonTheme.of(context).style,
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  label: const Text('Chat'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ButtonStyle _actionButtonStyle(
    BuildContext context,
    ButtonStyle? baseStyle,
  ) {
    final TextStyle textStyle =
        Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ) ??
            const TextStyle(fontWeight: FontWeight.w700);

    return (baseStyle ?? const ButtonStyle()).copyWith(
      minimumSize: WidgetStatePropertyAll<Size>(Size(0, 54.h)),
      padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
      textStyle: WidgetStatePropertyAll<TextStyle>(textStyle),
    );
  }
}
