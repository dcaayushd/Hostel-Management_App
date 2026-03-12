part of '../screens/hostel_fee_screen.dart';

class _PaymentHistoryTile extends StatelessWidget {
  const _PaymentHistoryTile({
    required this.payment,
    required this.onTap,
  });

  final PaymentRecord payment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.r),
          child: Ink(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: _softSurfaceColor(context),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: _borderColor(context)),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  height: 40.h,
                  width: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.kGreenColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    color: AppColors.kGreenColor,
                    size: 19.sp,
                  ),
                ),
                widthSpacer(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        payment.receiptId,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: _primaryTextColor(context),
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      heightSpacer(2),
                      Text(
                        '${payment.method.label} • ${_formatDate(payment.paidAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _mutedTextColor(context),
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Rs ${_formatAmount(payment.amount)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.kGreenColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
