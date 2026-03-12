part of '../screens/gate_pass_screen.dart';

class _InlineAction extends StatelessWidget {
  const _InlineAction({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: AppButtonStyles.outlined(
        Theme.of(context).brightness,
        color: color,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        radius: 999.r,
      ).copyWith(
        minimumSize: const WidgetStatePropertyAll<Size>(Size.zero),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
