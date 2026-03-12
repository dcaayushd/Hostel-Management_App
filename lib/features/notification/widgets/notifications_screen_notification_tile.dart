part of '../screens/notifications_screen.dart';

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.onTap,
  });

  final HostelNotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color primaryText = AppColors.primaryTextFor(brightness);
    final Color mutedText = AppColors.mutedTextFor(brightness);
    final HostelNotificationType displayType = item.resolvedType;
    final Color accentColor = _colorFor(displayType);
    final IconData icon = _iconFor(displayType);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.r),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 42.h,
                width: 42.w,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(icon, color: accentColor, size: 20.sp),
              ),
              widthSpacer(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: primaryText,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        widthSpacer(8),
                        if (!item.isRead)
                          Container(
                            height: 9.h,
                            width: 9.w,
                            decoration: BoxDecoration(
                              color: AppColors.kGreenColor,
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                          ),
                      ],
                    ),
                    heightSpacer(6),
                    Text(
                      item.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: mutedText,
                            height: 1.45,
                          ),
                    ),
                    heightSpacer(10),
                    Row(
                      children: <Widget>[
                        StatusChip(
                          label: displayType.label,
                          color: accentColor,
                        ),
                        widthSpacer(8),
                        Text(
                          _relativeTime(item.createdAt),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: mutedText,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _iconFor(HostelNotificationType type) {
    return AppIcons.forNotificationType(type);
  }

  static Color _colorFor(HostelNotificationType type) {
    switch (type) {
      case HostelNotificationType.fee:
        return const Color(0xFFB54708);
      case HostelNotificationType.notice:
        return const Color(0xFF0F766E);
      case HostelNotificationType.chat:
        return const Color(0xFF2F6F56);
      case HostelNotificationType.complaint:
        return const Color(0xFF3B755E);
      case HostelNotificationType.roomChange:
        return const Color(0xFF4C8E73);
      case HostelNotificationType.parcel:
        return const Color(0xFF2B6CB0);
      case HostelNotificationType.gatePass:
        return const Color(0xFFB54708);
    }
  }

  static String _relativeTime(DateTime timestamp) {
    final Duration difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) {
      return 'Just now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }
    final int weeks = (difference.inDays / 7).floor();
    return '${weeks}w ago';
  }
}
