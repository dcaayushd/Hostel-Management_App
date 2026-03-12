part of 'notifications_screen.dart';

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _showUnreadOnly = false;

  Future<void> _markAllRead() async {
    await context.read<AppState>().markAllNotificationsRead();
    if (!mounted) {
      return;
    }
    showAppMessage(context, 'Notifications marked as read.');
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final List<HostelNotificationItem> notifications = state.notifications
        .where(
          (HostelNotificationItem item) => !_showUnreadOnly || !item.isRead,
        )
        .toList(growable: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: buildAppBar(
        context,
        'Notifications',
        actions: <Widget>[
          if (state.notifications.isNotEmpty)
            TextButton(
              onPressed: state.unreadNotificationCount == 0 || state.isLoading
                  ? null
                  : _markAllRead,
              child: Text(
                'Mark all',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
        ],
      ),
      body: AppScreenBackground(
        child: RefreshIndicator(
          onRefresh: state.refreshData,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: appPagePadding(context,
                horizontal: 14, top: 8, bottomExtra: 18),
            children: <Widget>[
              AppTopInfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          height: 42.h,
                          width: 42.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.14),
                            ),
                          ),
                          child: Icon(
                            AppIcons.notificationsFilled,
                            color: Colors.white,
                            size: 21.sp,
                          ),
                        ),
                        widthSpacer(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Recent updates',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              heightSpacer(3),
                              Text(
                                'Fee reminders, messages, notice alerts, complaints, parcels, and room changes.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.78),
                                      height: 1.4,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        AppTopInfoStatusChip(
                          label: '${state.unreadNotificationCount} unread',
                          accentColor: AppColors.kGreenColor,
                        ),
                      ],
                    ),
                    heightSpacer(12),
                    Row(
                      children: <Widget>[
                        _FilterChip(
                          label: 'All',
                          selected: !_showUnreadOnly,
                          onTap: () {
                            setState(() {
                              _showUnreadOnly = false;
                            });
                          },
                        ),
                        widthSpacer(8),
                        _FilterChip(
                          label: 'Unread',
                          selected: _showUnreadOnly,
                          onTap: () {
                            setState(() {
                              _showUnreadOnly = true;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              heightSpacer(10),
              if (notifications.isEmpty)
                const AppSectionCard(
                  child: AppEmptyState(
                    icon: AppIcons.notifications,
                    title: 'No updates',
                    message: 'New reminders and alerts will appear here.',
                  ),
                )
              else
                ...notifications.map(
                  (HostelNotificationItem item) => AppSectionCard(
                    margin: EdgeInsets.only(bottom: 10.h),
                    padding: EdgeInsets.zero,
                    child: _NotificationTile(
                      item: item,
                      onTap: () {
                        unawaited(
                          openNotificationDestination(context, item),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
