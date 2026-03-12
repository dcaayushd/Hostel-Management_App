part of '../screens/mess_screen.dart';

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color:
                selected ? Colors.white : AppColors.primaryTextFor(brightness),
            fontWeight: FontWeight.w700,
          ),
      selectedColor: AppColors.kGreenColor,
      backgroundColor: AppColors.tonalSurfaceFor(brightness),
      side: BorderSide(
        color:
            selected ? AppColors.kGreenColor : AppColors.outlineFor(brightness),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
      showCheckmark: false,
    );
  }
}
