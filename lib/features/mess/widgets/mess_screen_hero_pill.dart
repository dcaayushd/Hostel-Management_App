part of '../screens/mess_screen.dart';

class _HeroPill extends StatelessWidget {
  const _HeroPill({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return AppTopInfoPill(label: label);
  }
}
