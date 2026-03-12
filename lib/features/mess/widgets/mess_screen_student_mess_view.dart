part of '../screens/mess_screen.dart';

class _StudentMessView extends StatelessWidget {
  const _StudentMessView({
    required this.state,
    required this.feedbackFormKey,
    required this.feedbackController,
    required this.selectedRating,
    required this.onRatingChanged,
    required this.onSubmitFeedback,
    required this.onToggleMeal,
  });

  final AppState state;
  final GlobalKey<FormState> feedbackFormKey;
  final TextEditingController feedbackController;
  final int selectedRating;
  final ValueChanged<int> onRatingChanged;
  final Future<void> Function() onSubmitFeedback;
  final Future<void> Function({
    required MealType mealType,
    required bool attended,
  }) onToggleMeal;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final AppUser? user = state.currentUser;
    final MessDay today = _todayDay();
    final MealAttendanceDay? attendance = user == null
        ? null
        : state.mealAttendanceFor(userId: user.id, day: today);
    final MessBillSummary? summary = state.currentMessBill;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _StudentMessHero(summary: summary),
        heightSpacer(12),
        _MenuSection(
          menu: state.messMenu,
          highlightedDay: today,
        ),
        heightSpacer(12),
        AppSectionCard(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Today\'s attendance',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primaryTextFor(brightness),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  StatusChip(
                    label: today.label,
                    color: AppColors.kGreenColor,
                  ),
                ],
              ),
              heightSpacer(4),
              Text(
                'Log the meals you took today.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedTextFor(brightness),
                    ),
              ),
              heightSpacer(12),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: <Widget>[
                  _MealToggleChip(
                    label: 'Breakfast',
                    icon: Icons.free_breakfast_outlined,
                    selected: attendance?.breakfast ?? false,
                    onTap: () {
                      onToggleMeal(
                        mealType: MealType.breakfast,
                        attended: !(attendance?.breakfast ?? false),
                      );
                    },
                  ),
                  _MealToggleChip(
                    label: 'Lunch',
                    icon: Icons.lunch_dining_outlined,
                    selected: attendance?.lunch ?? false,
                    onTap: () {
                      onToggleMeal(
                        mealType: MealType.lunch,
                        attended: !(attendance?.lunch ?? false),
                      );
                    },
                  ),
                  _MealToggleChip(
                    label: 'Dinner',
                    icon: Icons.dinner_dining_outlined,
                    selected: attendance?.dinner ?? false,
                    onTap: () {
                      onToggleMeal(
                        mealType: MealType.dinner,
                        attended: !(attendance?.dinner ?? false),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        heightSpacer(12),
        AppSectionCard(
          padding: EdgeInsets.all(12.w),
          child: Form(
            key: feedbackFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Food feedback',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryTextFor(brightness),
                        fontWeight: FontWeight.w800,
                      ),
                ),
                heightSpacer(4),
                Text(
                  'Rate the meals and leave one quick note for the mess team.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedTextFor(brightness),
                      ),
                ),
                heightSpacer(10),
                _RatingSelector(
                  rating: selectedRating,
                  onChanged: onRatingChanged,
                ),
                heightSpacer(8),
                CustomTextField(
                  controller: feedbackController,
                  inputHint: 'Share what worked well or needs improvement',
                  maxLines: 3,
                  minLines: 3,
                  inputCapitalization: TextCapitalization.sentences,
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Feedback is required';
                    }
                    return null;
                  },
                ),
                heightSpacer(8),
                CustomButton(
                  buttonText: 'Submit Feedback',
                  onTap: onSubmitFeedback,
                ),
              ],
            ),
          ),
        ),
        heightSpacer(12),
        _FeedbackSection(
          title: 'My feedback',
          feedback: state.visibleFoodFeedback,
          state: state,
        ),
      ],
    );
  }
}
