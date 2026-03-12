part of '../screens/mess_screen.dart';

class _RatingSelector extends StatelessWidget {
  const _RatingSelector({
    required this.rating,
    required this.onChanged,
  });

  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(5, (int index) {
        final int value = index + 1;
        return IconButton(
          onPressed: () => onChanged(value),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(width: 30.w, height: 30.h),
          icon: Icon(
            value <= rating ? Icons.star_rounded : Icons.star_border_rounded,
            color: const Color(0xFFB54708),
            size: 22.sp,
          ),
        );
      }),
    );
  }
}
