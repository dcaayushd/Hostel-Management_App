part of '../screens/hostel_fee_screen.dart';

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.method,
    required this.onTap,
  });

  final PaymentMethod method;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Ink(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: _softSurfaceColor(context),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: _borderColor(context),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 34.h,
                width: 34.w,
                decoration: BoxDecoration(
                  color: AppColors.kGreenColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(
                  _iconForMethod(method),
                  color: AppColors.kGreenColor,
                  size: 18.sp,
                ),
              ),
              heightSpacer(10),
              Text(
                method.label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: _primaryTextColor(context),
                      fontWeight: FontWeight.w800,
                    ),
              ),
              heightSpacer(2),
              Text(
                method.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _mutedTextColor(context),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForMethod(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.eSewa:
        return Icons.account_balance_wallet_outlined;
      case PaymentMethod.card:
        return Icons.credit_card_outlined;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance_outlined;
      case PaymentMethod.cash:
        return Icons.payments_outlined;
    }
  }
}
