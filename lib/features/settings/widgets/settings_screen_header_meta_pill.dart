part of '../screens/settings_screen.dart';

class _HeaderMetaPill extends StatelessWidget {
  const _HeaderMetaPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppTopInfoIconPill(
      icon: icon,
      label: label,
      expand: true,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
    );
  }
}
