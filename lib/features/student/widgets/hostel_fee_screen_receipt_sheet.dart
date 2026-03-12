part of '../screens/hostel_fee_screen.dart';

class _ReceiptSheet extends StatelessWidget {
  const _ReceiptSheet({
    required this.payment,
    required this.residentName,
  });

  final PaymentRecord payment;
  final String residentName;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 20.h),
        decoration: BoxDecoration(
          color: _surfaceColor(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                height: 5.h,
                width: 44.w,
                decoration: BoxDecoration(
                  color: _borderColor(context),
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
            ),
            heightSpacer(16),
            Text(
              'Receipt',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _primaryTextColor(context),
                    fontWeight: FontWeight.w800,
                  ),
            ),
            heightSpacer(12),
            AppSectionCard(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _FeeRow(label: 'Receipt ID', valueText: payment.receiptId),
                  _FeeRow(label: 'Resident', valueText: residentName),
                  _FeeRow(
                      label: 'Billing month', valueText: payment.billingMonth),
                  _FeeRow(label: 'Method', valueText: payment.method.label),
                  _FeeRow(
                      label: 'Paid on', valueText: _formatDate(payment.paidAt)),
                  _FeeRow(
                    label: 'Amount',
                    value: payment.amount,
                    isLast: true,
                    valueColor: AppColors.kGreenColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
