part of '../screens/hostel_fee_screen.dart';

class _PaymentReviewSheet extends StatelessWidget {
  const _PaymentReviewSheet({
    required this.residentName,
    required this.billingMonth,
    required this.amount,
    required this.method,
    required this.referenceId,
    this.roomLabel,
    this.isCollection = false,
  });

  final String residentName;
  final String billingMonth;
  final int amount;
  final PaymentMethod method;
  final String referenceId;
  final String? roomLabel;
  final bool isCollection;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 22.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              isCollection ? 'Review collection' : 'Review payment',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _primaryTextColor(context),
                    fontWeight: FontWeight.w800,
                  ),
            ),
            heightSpacer(6),
            Text(
              isCollection
                  ? 'Verify the fee summary before recording the collection.'
                  : 'Confirm the invoice before continuing to the payment step.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _mutedTextColor(context),
                    height: 1.45,
                  ),
            ),
            heightSpacer(14),
            AppSectionCard(
              padding: EdgeInsets.all(12.w),
              margin: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  _FeeRow(label: 'Resident', valueText: residentName),
                  if (roomLabel != null && roomLabel!.isNotEmpty)
                    _FeeRow(label: 'Room', valueText: roomLabel!),
                  _FeeRow(label: 'Month', valueText: billingMonth),
                  _FeeRow(label: 'Method', valueText: method.label),
                  _FeeRow(label: 'Reference', valueText: referenceId),
                  _FeeRow(
                    label: 'Amount',
                    value: amount,
                    valueColor: AppColors.kGreenColor,
                    isLast: true,
                  ),
                ],
              ),
            ),
            heightSpacer(12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: _softSurfaceColor(context),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: _borderColor(context)),
              ),
              child: Text(
                _helperTextFor(method, isCollection: isCollection),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _mutedTextColor(context),
                      height: 1.45,
                    ),
              ),
            ),
            heightSpacer(14),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                ),
                widthSpacer(10),
                Expanded(
                  child: CustomButton(
                    buttonText:
                        isCollection ? 'Confirm Collection' : 'Continue',
                    onTap: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
