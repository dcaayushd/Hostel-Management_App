part of '../screens/gate_pass_screen.dart';

class _GateDeskProcessor extends StatelessWidget {
  const _GateDeskProcessor({
    required this.controller,
    required this.onProcess,
  });

  final TextEditingController controller;
  final Future<void> Function() onProcess;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return AppSectionCard(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Process pass code',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryTextFor(brightness),
                  fontWeight: FontWeight.w800,
                ),
          ),
          heightSpacer(4),
          Text(
            'Paste the pass code or full QR payload to record exit or return.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedTextFor(brightness),
                ),
          ),
          heightSpacer(10),
          CustomTextField(
            controller: controller,
            inputHint: 'e.g. GP-240315 or HOSTEL:GP-240315:student_12',
          ),
          heightSpacer(10),
          CustomButton(
            buttonText: 'Process',
            onTap: onProcess,
          ),
        ],
      ),
    );
  }
}
