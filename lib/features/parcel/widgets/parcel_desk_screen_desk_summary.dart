part of '../screens/parcel_desk_screen.dart';

class _DeskSummary extends StatelessWidget {
  const _DeskSummary({
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
      description:
          'Track parcels, visitors, and pickup activity from the desk.',
      icon: Icons.inventory_2_outlined,
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
