part of '../screens/mess_screen.dart';

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppTopInfoStatTile(label: label, value: value);
  }
}
