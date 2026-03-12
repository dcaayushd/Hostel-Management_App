part of '../screens/notice_board_screen.dart';

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.notice,
  });

  final NoticeItem notice;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color primaryText = AppColors.primaryTextFor(brightness);
    final Color mutedText = AppColors.mutedTextFor(brightness);
    final Color accent = _colorForCategory(notice.category);
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 38.h,
                width: 38.w,
                decoration: BoxDecoration(
                  color: AppColors.iconSurfaceFor(
                    brightness,
                    lightColor: accent,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _iconForCategory(notice.category),
                  color: AppColors.iconColorFor(
                    brightness,
                    lightColor: accent,
                  ),
                  size: 19.sp,
                ),
              ),
              widthSpacer(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: <Widget>[
                        StatusChip(
                          label: normalizeNoticeCategoryLabel(notice.category),
                          color: accent,
                        ),
                        if (notice.isPinned)
                          const StatusChip(
                            label: 'Pinned',
                            color: Color(0xFFB54708),
                          ),
                      ],
                    ),
                    heightSpacer(8),
                    Text(
                      notice.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: primaryText,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          heightSpacer(10),
          Text(
            notice.message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: mutedText,
                  height: 1.5,
                ),
          ),
          heightSpacer(10),
          Text(
            _formatDate(notice.postedAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: mutedText,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  Color _colorForCategory(String category) {
    final String normalized = category.trim().toLowerCase();
    if (normalized.contains('event') || normalized.contains('program')) {
      return const Color(0xFF0F766E);
    }
    if (normalized.contains('rule') ||
        normalized.contains('policy') ||
        normalized.contains('guideline')) {
      return const Color(0xFFB54708);
    }
    if (normalized.contains('alert') ||
        normalized.contains('urgent') ||
        normalized.contains('emergency')) {
      return const Color(0xFFD92D20);
    }
    return AppColors.kGreenColor;
  }

  IconData _iconForCategory(String category) {
    return AppIcons.forNoticeCategory(category);
  }
}
