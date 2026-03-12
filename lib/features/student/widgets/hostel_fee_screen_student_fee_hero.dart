part of '../screens/hostel_fee_screen.dart';

class _StudentFeeHero extends StatelessWidget {
  const _StudentFeeHero({
    required this.summary,
    required this.roomLabel,
    required this.latestPayment,
    this.onOpenLatestReceipt,
  });

  final FeeSummary summary;
  final String roomLabel;
  final PaymentRecord? latestPayment;
  final VoidCallback? onOpenLatestReceipt;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF2E8B57), Color(0xFF173C32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14173C32),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      summary.billingMonth,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.86),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    heightSpacer(6),
                    Text(
                      'Rs ${_formatAmount(summary.balance)}',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                    ),
                    heightSpacer(6),
                    Text(
                      summary.isPaid
                          ? 'All hostel charges cleared'
                          : 'Due by ${_formatDate(summary.dueDate)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.84),
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 52.h,
                width: 52.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  summary.isPaid
                      ? Icons.verified_rounded
                      : Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
            ],
          ),
          heightSpacer(14),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: <Widget>[
              _HeroChip(
                icon: Icons.meeting_room_outlined,
                label: roomLabel,
              ),
              _HeroChip(
                icon: Icons.payments_outlined,
                label: 'Paid Rs ${_formatAmount(summary.paidAmount)}',
              ),
              if (latestPayment != null)
                _HeroChip(
                  icon: Icons.receipt_long_outlined,
                  label: latestPayment!.receiptId,
                  onTap: onOpenLatestReceipt,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
