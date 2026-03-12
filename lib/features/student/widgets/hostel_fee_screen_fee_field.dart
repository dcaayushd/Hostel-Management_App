part of '../screens/hostel_fee_screen.dart';

class _FeeField extends StatelessWidget {
  const _FeeField({
    required this.label,
    required this.controller,
  });

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _mutedTextColor(context),
                  fontWeight: FontWeight.w700,
                ),
          ),
          heightSpacer(6),
          CustomTextField(
            controller: controller,
            inputHint: 'Amount',
            inputKeyBoardType: TextInputType.number,
            validator: (String? value) =>
                AppValidators.requiredField(value, label),
          ),
        ],
      ),
    );
  }
}
