part of '../screens/mess_screen.dart';

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.feedback,
    required this.userName,
  });

  final FoodFeedback feedback;
  final String userName;

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
                  userName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryTextFor(brightness),
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              _StarBadge(rating: feedback.rating),
            ],
          ),
          heightSpacer(8),
          Text(
            feedback.comment,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedTextFor(brightness),
                  height: 1.45,
                ),
          ),
          heightSpacer(8),
          Text(
            _formatDate(feedback.submittedAt),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.mutedTextFor(brightness),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
