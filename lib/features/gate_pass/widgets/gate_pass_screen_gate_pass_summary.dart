part of '../screens/gate_pass_screen.dart';

class _GatePassSummary extends StatelessWidget {
  const _GatePassSummary({
    required this.title,
    required this.firstLabel,
    required this.firstValue,
    required this.secondLabel,
    required this.secondValue,
  });

  final String title;
  final String firstLabel;
  final String firstValue;
  final String secondLabel;
  final String secondValue;

  @override
  Widget build(BuildContext context) {
    return AppFeatureBanner(
      title: title,
      description: 'Keep approvals, departures, and returns in one place.',
      icon: Icons.qr_code_2_rounded,
      accentColor: AppColors.kTopInfoAccentColor,
      stats: <AppFeatureBannerStat>[
        AppFeatureBannerStat(
          label: firstLabel,
          value: firstValue,
        ),
        AppFeatureBannerStat(
          label: secondLabel,
          value: secondValue,
        ),
      ],
    );
  }
}
