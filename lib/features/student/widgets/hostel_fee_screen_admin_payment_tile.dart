part of '../screens/hostel_fee_screen.dart';

class _AdminPaymentTile extends StatelessWidget {
  const _AdminPaymentTile({
    required this.payment,
    required this.residentName,
    required this.onTap,
  });

  final PaymentRecord payment;
  final String residentName;
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
                  height: 38.h,
                  width: 38.w,
                  decoration: BoxDecoration(
                    color: AppColors.kGreenColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.receipt_outlined,
                    color: AppColors.kGreenColor,
                    size: 18.sp,
                  ),
                ),
                widthSpacer(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        residentName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: _primaryTextColor(context),
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      heightSpacer(2),
                      Text(
                        '${payment.receiptId} • ${payment.method.label}',
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
