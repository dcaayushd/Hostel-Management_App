part of 'home_welcome_card.dart';

class _WelcomeAvatar extends StatelessWidget {
  const _WelcomeAvatar({
    required this.initials,
  });

  final String initials;

  @override
  Widget build(BuildContext context) {
    return AppTopInfoAvatar(
      initials: initials,
      size: 62,
      shadow: const BoxShadow(
        color: Color(0x26173C32),
        blurRadius: 12,
        offset: Offset(0, 6),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
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
      maxWidth: 132,
    );
  }
}
