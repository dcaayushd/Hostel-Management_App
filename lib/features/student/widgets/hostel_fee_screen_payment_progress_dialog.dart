part of '../screens/hostel_fee_screen.dart';

class _PaymentProgressDialog extends StatelessWidget {
  const _PaymentProgressDialog({
    required this.method,
    this.isCollection = false,
  });

  final PaymentMethod method;
  final bool isCollection;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const CircularProgressIndicator(),
            heightSpacer(16),
            Text(
              isCollection ? 'Recording Collection' : 'Processing Payment',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _primaryTextColor(context),
                    fontWeight: FontWeight.w800,
                  ),
            ),
            heightSpacer(8),
            Text(
              isCollection
                  ? 'Validating ${method.label.toLowerCase()} collection and generating the receipt.'
                  : 'Validating the ${method.label.toLowerCase()} transaction and preparing the receipt.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _mutedTextColor(context),
                    height: 1.45,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
