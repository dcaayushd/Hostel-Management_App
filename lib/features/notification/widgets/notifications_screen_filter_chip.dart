part of '../screens/notifications_screen.dart';

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTopInfoFilterChip(
      label: label,
      selected: selected,
      onTap: onTap,
    );
  }
}
