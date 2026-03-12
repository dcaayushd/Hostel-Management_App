part of '../screens/mess_screen.dart';

class _FeedbackSection extends StatelessWidget {
  const _FeedbackSection({
    required this.title,
    required this.feedback,
    required this.state,
  });

  final String title;
  final List<FoodFeedback> feedback;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return AppSectionCard(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryTextFor(brightness),
                  fontWeight: FontWeight.w800,
                ),
          ),
          heightSpacer(4),
          Text(
            'Recent ratings and comments from the mess module.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedTextFor(brightness),
                ),
          ),
          heightSpacer(12),
          if (feedback.isEmpty)
            const AppEmptyState(
              icon: Icons.rate_review_outlined,
              title: 'No feedback yet',
              message:
                  'Feedback cards will appear here after the first rating.',
            )
          else
            ...feedback.take(6).map(
                  (FoodFeedback item) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: _FeedbackCard(
                      feedback: item,
                      userName:
                          state.findUser(item.userId)?.fullName ?? 'Resident',
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
