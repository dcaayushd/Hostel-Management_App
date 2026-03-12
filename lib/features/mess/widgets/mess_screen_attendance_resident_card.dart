part of '../screens/mess_screen.dart';

class _AttendanceResidentCard extends StatelessWidget {
  const _AttendanceResidentCard({
    required this.student,
    required this.attendance,
    this.roomLabel,
  });

  final AppUser student;
  final MealAttendanceDay? attendance;
  final String? roomLabel;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.tonalSurfaceFor(brightness),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.outlineFor(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  student.fullName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryTextFor(brightness),
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              if (roomLabel != null)
                StatusChip(
                  label: roomLabel!,
                  color: const Color(0xFF0F766E),
                ),
            ],
          ),
          heightSpacer(8),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: <Widget>[
              _MealStatusPill(
                label: 'Breakfast',
                active: attendance?.breakfast ?? false,
              ),
              _MealStatusPill(
                label: 'Lunch',
                active: attendance?.lunch ?? false,
              ),
              _MealStatusPill(
                label: 'Dinner',
                active: attendance?.dinner ?? false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
