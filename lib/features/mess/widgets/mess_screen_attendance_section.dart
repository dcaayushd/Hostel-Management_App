part of '../screens/mess_screen.dart';

class _AttendanceSection extends StatelessWidget {
  const _AttendanceSection({
    required this.state,
    required this.selectedDay,
    required this.onDaySelected,
  });

  final AppState state;
  final MessDay selectedDay;
  final ValueChanged<MessDay> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final List<AppUser> students = List<AppUser>.from(state.students)
      ..sort((AppUser a, AppUser b) => a.fullName.compareTo(b.fullName));

    return AppSectionCard(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Meal attendance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryTextFor(brightness),
                  fontWeight: FontWeight.w800,
                ),
          ),
          heightSpacer(4),
          Text(
            'See who used the mess on each day.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedTextFor(brightness),
                ),
          ),
          heightSpacer(10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: MessDay.values.map((MessDay day) {
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: _DayChip(
                    label: day.shortLabel,
                    selected: day == selectedDay,
                    onTap: () {
                      onDaySelected(day);
                    },
                  ),
                );
              }).toList(growable: false),
            ),
          ),
          heightSpacer(12),
          if (students.isEmpty)
            const AppEmptyState(
              icon: Icons.groups_2_outlined,
              title: 'No residents',
              message:
                  'Student attendance will appear here once residents are assigned.',
            )
          else
            ...students.map(
              (AppUser student) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _AttendanceResidentCard(
                  student: student,
                  roomLabel: state.findRoom(student.roomId ?? '')?.label,
                  attendance: state.mealAttendanceFor(
                    userId: student.id,
                    day: selectedDay,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
