part of '../screens/settings_screen.dart';

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar({
    required this.initials,
  });

  final String initials;

  @override
  Widget build(BuildContext context) {
    return AppTopInfoAvatar(
      initials: initials,
      size: 58,
      textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
      gradient: const LinearGradient(
        colors: <Color>[Color(0xFF8FD1AB), Color(0xFF2E8B57)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}
