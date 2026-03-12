part of '../screens/hostel_fee_screen.dart';

class _FeeRow extends StatelessWidget {
  const _FeeRow({
    required this.label,
    this.value,
    this.valueText,
    this.isLast = false,
    this.valueColor,
  }) : assert(value != null || valueText != null);

  final String label;
  final int? value;
  final String? valueText;
  final bool isLast;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _mutedTextColor(context),
                  ),
            ),
          ),
          Text(
            valueText ?? 'Rs ${_formatAmount(value!)}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: valueColor ?? _primaryTextColor(context),
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

String _formatAmount(int value) {
  final String digits = value.toString();
  final RegExp groupPattern = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
  return digits.replaceAllMapped(groupPattern, (Match match) {
    return '${match[1]},';
  });
}

String _helperTextFor(PaymentMethod method, {bool isCollection = false}) {
  switch (method) {
    case PaymentMethod.eSewa:
      return isCollection
          ? 'Record the wallet collection only after confirming the resident completed the eSewa payment.'
          : 'The invoice will be checked first, then the eSewa payment will be completed locally.';
    case PaymentMethod.card:
      return isCollection
          ? 'Use this only after confirming the card charge was approved for the full hostel amount.'
          : 'Card authorization is validated before the hostel receipt is generated.';
    case PaymentMethod.bankTransfer:
      return isCollection
          ? 'Confirm the transfer reference before recording this collection.'
          : 'Bank transfer confirmation is checked before the payment is marked as settled.';
    case PaymentMethod.cash:
      return 'Cash collections should be recorded only after the warden receives the full monthly dues.';
  }
}

Color _primaryTextColor(BuildContext context) {
  return AppColors.primaryTextFor(Theme.of(context).brightness);
}

Color _mutedTextColor(BuildContext context) {
  return AppColors.mutedTextFor(Theme.of(context).brightness);
}

Color _surfaceColor(BuildContext context) {
  return AppColors.surfaceColor(Theme.of(context).brightness);
}

Color _softSurfaceColor(BuildContext context) {
  return AppColors.softSurfaceFor(Theme.of(context).brightness);
}

Color _borderColor(BuildContext context) {
  return AppColors.borderFor(Theme.of(context).brightness);
}

String _formatDate(DateTime? date) {
  if (date == null) {
    return 'Not set';
  }
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final String day = date.day.toString().padLeft(2, '0');
  return '$day ${months[date.month - 1]} ${date.year}';
}
