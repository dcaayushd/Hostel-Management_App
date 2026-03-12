part of '../screens/verify_email_screen.dart';

class _CompactInfoTile extends StatelessWidget {
  const _CompactInfoTile({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(brightness),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.borderFor(brightness),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedTextFor(brightness),
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primaryTextFor(brightness),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
