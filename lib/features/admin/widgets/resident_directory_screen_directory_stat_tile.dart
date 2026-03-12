part of '../screens/resident_directory_screen.dart';

class _DirectoryStatTile extends StatelessWidget {
  const _DirectoryStatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.w,
      child: AppTopInfoStatTile(
        label: label,
        value: value,
        icon: icon,
        padding: EdgeInsets.all(14.w),
        borderRadius: 20,
        showBorder: true,
      ),
    );
  }
}
