part of '../screens/mess_screen.dart';

class _AdminMessView extends StatelessWidget {
  const _AdminMessView({
    required this.state,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onEditMenuDay,
  });

  final AppState state;
  final MessDay selectedDay;
  final ValueChanged<MessDay> onDaySelected;
  final Future<void> Function(MessMenuDay menuDay)? onEditMenuDay;

  @override
  Widget build(BuildContext context) {
    final List<AppUser> students = state.students;
    final List<MealAttendanceDay> attendance = state.visibleMealAttendance;
    final int mealsToday = attendance
        .where((MealAttendanceDay entry) => entry.day == _todayDay())
        .fold<int>(
            0, (int total, MealAttendanceDay entry) => total + entry.mealCount);
    final int residentsToday = attendance
        .where(
          (MealAttendanceDay entry) =>
              entry.day == _todayDay() && entry.mealCount > 0,
        )
        .length;
    final double averageRating = state.visibleFoodFeedback.isEmpty
        ? 0
        : state.visibleFoodFeedback
                .map((FoodFeedback item) => item.rating)
                .reduce((int a, int b) => a + b) /
            state.visibleFoodFeedback.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _AdminMessHero(
          studentsCount: students.length,
          mealsToday: mealsToday,
          residentsToday: residentsToday,
          averageRating: averageRating,
        ),
        heightSpacer(12),
        _MenuSection(
          menu: state.messMenu,
          highlightedDay: selectedDay,
          onEditMenuDay: onEditMenuDay,
        ),
        heightSpacer(12),
        _AttendanceSection(
          state: state,
          selectedDay: selectedDay,
          onDaySelected: onDaySelected,
        ),
        heightSpacer(12),
        _MessBillSection(state: state),
        heightSpacer(12),
        _FeedbackSection(
          title: 'Resident feedback',
          feedback: state.visibleFoodFeedback,
          state: state,
        ),
      ],
    );
  }
}
