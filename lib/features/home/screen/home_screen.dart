// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../app/app_chrome.dart';
import '../../../app/route_args.dart';
import '../../../app/routes.dart';
import '../../../common/app_bar.dart';
import '../../../core/models/admin_catalog.dart';
import '../../../core/models/app_user.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/models/issue_ticket.dart';
import '../../../core/models/user_role.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/app_icons.dart';
import '../../../core/widgets/app_screen_background.dart';
import '../../../features/home/widgets/category_card.dart';
import '../../../features/home/widgets/dashboard_card_frame.dart';
import '../../../features/home/widgets/home_welcome_card.dart';
import '../../notice/providers/notice_provider.dart';
import '../../../theme/colors.dart';

part 'home_screen_parts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final int noticeCount = context.watch<NoticeProvider>().notices.length;
    final AppUser? user = state.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    final List<_MetricData> metrics = _metricsFor(state, user, noticeCount);
    final List<_DashboardAction> actions =
        _actionsFor(state, user, state.adminCatalog.serviceShortcuts);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: buildAppBar(
        context,
        'Hostel Hub',
        actions: <Widget>[
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.notifications);
            },
            icon: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                const Icon(
                  AppIcons.notifications,
                  color: Colors.white,
                ),
                if (state.notificationBadgesEnabled &&
                    state.unreadNotificationCount > 0)
                  Positioned(
                    right: -1,
                    top: -1,
                    child: Container(
                      constraints: BoxConstraints(minWidth: 16.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.kGreenColor,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        state.unreadNotificationCount > 9
                            ? '9+'
                            : state.unreadNotificationCount.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: AppScreenBackground(
        topChromeHeight: 128,
        child: RefreshIndicator(
          onRefresh: state.refreshData,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding:
                appPagePadding(context, horizontal: 0, top: 8, bottomExtra: 8),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                child: HomeWelcomeCard(
                  user: user,
                  room: state.currentRoom,
                  showRoomDetails: state.showRoomDetailsOnCards,
                  showContactInfo: state.showContactInfoOnCards,
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.profile);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 0),
                child: DashboardSectionCard(
                  title: 'Overview',
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      final int columns = constraints.maxWidth >= 980
                          ? 5
                          : constraints.maxWidth >= 720
                              ? 4
                              : constraints.maxWidth >= 380
                                  ? 3
                                  : 2;
                      final double spacing = 8.w;
                      final double totalSpacing = spacing * (columns - 1);
                      final double cardWidth =
                          (constraints.maxWidth - totalSpacing) / columns;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: 7.h,
                        children: metrics
                            .map(
                              (_MetricData metric) => SizedBox(
                                width: cardWidth,
                                height: 88.h,
                                child: _MetricCard(metric: metric),
                              ),
                            )
                            .toList(growable: false),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 0),
                child: DashboardSectionCard(
                  title: 'Services',
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      final int columns = constraints.maxWidth >= 980
                          ? 5
                          : constraints.maxWidth >= 720
                              ? 4
                              : constraints.maxWidth >= 380
                                  ? 3
                                  : 2;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: actions.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 7.w,
                          mainAxisSpacing: 7.h,
                          mainAxisExtent: 136.h,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          final _DashboardAction action = actions[index];
                          return CategoryCard(
                            category: action.title,
                            subtitle: action.subtitle,
                            countText: action.countText,
                            icon: action.icon,
                            accentColor: action.color,
                            onTap: () {
                              Navigator.of(context).pushNamed(action.route);
                            },
                          );
                        },
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

  List<_MetricData> _metricsFor(
    AppState state,
    AppUser user,
    int noticeCount,
  ) {
    final int unreadMessages = state.chatMessages
        .where(
          (ChatMessage item) => item.recipientId == user.id && !item.isRead,
        )
        .length;
    if (user.role == UserRole.student) {
      return <_MetricData>[
        _MetricData(
          title: 'Room',
          value: state.currentRoom?.label ?? '--',
          route: AppRoutes.roomAvailability,
          icon: AppIcons.room,
          color: AppColors.kDeepGreenColor,
        ),
        _MetricData(
          title: 'Fees',
          value: state.currentFeeSummary == null
              ? '--'
              : 'Rs ${_formatAmount(state.currentFeeSummary!.balance)}',
          route: AppRoutes.fees,
          icon: AppIcons.fees,
          color: AppColors.kGreenColor,
        ),
        _MetricData(
          title: 'Issues',
          value: state.openIssueCount.toString(),
          route: AppRoutes.createIssue,
          icon: AppIcons.issue,
          color: const Color(0xFF3B755E),
        ),
        _MetricData(
          title: 'Requests',
          value: state.pendingRoomRequestCount.toString(),
          route: AppRoutes.roomChangeRequests,
          icon: AppIcons.request,
          color: const Color(0xFF4C8E73),
        ),
      ];
    }
    if (user.role == UserRole.guest) {
      return <_MetricData>[
        _MetricData(
          title: 'Profile',
          value: user.id.toUpperCase(),
          route: AppRoutes.profile,
          icon: AppIcons.profile,
          color: AppColors.kDeepGreenColor,
        ),
        _MetricData(
          title: 'Alerts',
          value: state.unreadNotificationCount.toString(),
          route: AppRoutes.notifications,
          icon: AppIcons.notificationsFilled,
          color: AppColors.kGreenColor,
        ),
        _MetricData(
          title: 'Notices',
          value: noticeCount.toString(),
          route: AppRoutes.notices,
          icon: AppIcons.notice,
          color: const Color(0xFF3B755E),
        ),
        _MetricData(
          title: 'Messages',
          value: unreadMessages.toString(),
          route: AppRoutes.chat,
          icon: AppIcons.chat,
          color: const Color(0xFF4C8E73),
        ),
      ];
    }
    if (user.canManageIssues) {
      return <_MetricData>[
        _MetricData(
          title: 'Issues',
          value: state.openIssueCount.toString(),
          route: AppRoutes.issues,
          icon: AppIcons.issue,
          color: AppColors.kDeepGreenColor,
        ),
        _MetricData(
          title: 'Fees due',
          value: state.pendingFeeCount.toString(),
          route: AppRoutes.fees,
          icon: AppIcons.fees,
          color: AppColors.kGreenColor,
          routeArgs: const FeeScreenRouteArgs(
            filter: FeeScreenFilter.duesOnly,
          ),
        ),
        _MetricData(
          title: 'Gate queue',
          value: state.pendingGatePassCount.toString(),
          route: AppRoutes.gatePass,
          icon: AppIcons.gatePass,
          color: const Color(0xFFB54708),
        ),
        _MetricData(
          title: 'Requests',
          value: state.pendingRoomRequestCount.toString(),
          route: AppRoutes.roomChangeRequests,
          icon: AppIcons.request,
          color: const Color(0xFF4C8E73),
          routeArgs: const RoomChangeRequestRouteArgs(
            filter: RoomChangeRequestScreenFilter.pendingOnly,
          ),
        ),
      ];
    }
    final int activeAssignments = state.visibleIssues
        .where((IssueTicket issue) => !issue.status.isResolved)
        .length;
    return <_MetricData>[
      _MetricData(
        title: 'Assigned',
        value: activeAssignments.toString(),
        route: AppRoutes.issues,
        icon: AppIcons.issue,
        color: AppColors.kDeepGreenColor,
      ),
      _MetricData(
        title: 'Alerts',
        value: state.unreadNotificationCount.toString(),
        route: AppRoutes.notifications,
        icon: AppIcons.notificationsFilled,
        color: AppColors.kGreenColor,
      ),
      _MetricData(
        title: 'Notices',
        value: noticeCount.toString(),
        route: AppRoutes.notices,
        icon: AppIcons.notice,
        color: const Color(0xFF3B755E),
      ),
      _MetricData(
        title: 'Messages',
        value: unreadMessages.toString(),
        route: AppRoutes.chat,
        icon: AppIcons.chat,
        color: const Color(0xFF4C8E73),
      ),
    ];
  }

  List<_DashboardAction> _actionsFor(
    AppState state,
    AppUser user,
    List<AdminServiceShortcut> shortcuts,
  ) {
    late final List<_DashboardAction> baseActions;
    if (user.role == UserRole.student) {
      baseActions = <_DashboardAction>[
        _DashboardAction(
          title: 'Room',
          subtitle: 'Availability',
          icon: AppIcons.room,
          route: AppRoutes.roomAvailability,
          color: AppColors.kDeepGreenColor,
        ),
        _DashboardAction(
          title: 'Fees',
          subtitle: 'Bills',
          icon: AppIcons.fees,
          route: AppRoutes.fees,
          color: AppColors.kGreenColor,
        ),
        _DashboardAction(
          title: 'Alerts',
          subtitle: 'Updates',
          icon: AppIcons.notifications,
          route: AppRoutes.notifications,
          color: const Color(0xFF3B755E),
        ),
        _DashboardAction(
          title: 'Chat',
          subtitle: 'Support',
          icon: AppIcons.chat,
          route: AppRoutes.chat,
          color: const Color(0xFF2F6F56),
        ),
        _DashboardAction(
          title: 'Laundry',
          subtitle: 'Bookings',
          icon: AppIcons.laundry,
          route: AppRoutes.laundry,
          color: const Color(0xFF2B6CB0),
        ),
        _DashboardAction(
          title: 'Gate Pass',
          subtitle: 'Leave',
          icon: AppIcons.gatePass,
          route: AppRoutes.gatePass,
          color: const Color(0xFFB54708),
        ),
        _DashboardAction(
          title: 'Mess',
          subtitle: 'Menu & bills',
          icon: AppIcons.mess,
          route: AppRoutes.mess,
          color: const Color(0xFF0F766E),
        ),
        _DashboardAction(
          title: 'Parcels',
          subtitle: 'Desk',
          icon: AppIcons.parcel,
          route: AppRoutes.parcelDesk,
          color: const Color(0xFF2B6CB0),
        ),
        _DashboardAction(
          title: 'Notice',
          subtitle: 'Board',
          icon: AppIcons.notice,
          route: AppRoutes.notices,
          color: const Color(0xFF0F766E),
        ),
        _DashboardAction(
          title: 'Complaints',
          subtitle: 'Create issue',
          icon: AppIcons.issue,
          route: AppRoutes.createIssue,
          color: const Color(0xFF3B755E),
        ),
        _DashboardAction(
          title: 'Requests',
          subtitle: 'Room change',
          icon: AppIcons.request,
          route: AppRoutes.roomChangeRequests,
          color: const Color(0xFF4C8E73),
        ),
      ];
    } else if (user.role == UserRole.guest) {
      baseActions = <_DashboardAction>[
        _DashboardAction(
          title: 'Alerts',
          subtitle: 'Updates',
          icon: AppIcons.notifications,
          route: AppRoutes.notifications,
          color: const Color(0xFF3B755E),
        ),
        _DashboardAction(
          title: 'Notice',
          subtitle: 'Board',
          icon: AppIcons.notice,
          route: AppRoutes.notices,
          color: const Color(0xFF0F766E),
        ),
        _DashboardAction(
          title: 'Chat',
          subtitle: 'Support',
          icon: AppIcons.chat,
          route: AppRoutes.chat,
          color: const Color(0xFF2F6F56),
        ),
      ];
    } else {
      final int openAssignments = state.visibleIssues
          .where((IssueTicket issue) => !issue.status.isResolved)
          .length;
      baseActions = <_DashboardAction>[
        if (user.canViewResidents)
          _DashboardAction(
            title: 'Residents',
            subtitle: 'Directory',
            icon: AppIcons.residents,
            route: AppRoutes.residents,
            color: AppColors.kGreenColor,
            countText: state.students.length.toString(),
          ),
        if (user.canViewStaffDirectory)
          _DashboardAction(
            title: 'Staff',
            subtitle: 'Directory',
            icon: AppIcons.staff,
            route: AppRoutes.staff,
            color: AppColors.kDeepGreenColor,
            countText: state.staffMembers.length.toString(),
          ),
        if (user.canManageStaff)
          _DashboardAction(
            title: 'Create Staff',
            subtitle: 'New account',
            icon: AppIcons.addStaff,
            route: AppRoutes.createStaff,
            color: const Color(0xFF3B755E),
          ),
        _DashboardAction(
          title: user.canManageIssues ? 'Issues' : 'Assigned',
          subtitle: user.canManageIssues ? 'Issue queue' : 'Your tasks',
          icon: AppIcons.issue,
          route: AppRoutes.issues,
          color: const Color(0xFFB54708),
          countText: openAssignments.toString(),
        ),
        _DashboardAction(
          title: 'Alerts',
          subtitle: 'Updates',
          icon: AppIcons.notifications,
          route: AppRoutes.notifications,
          color: const Color(0xFF0F766E),
        ),
        _DashboardAction(
          title: 'Chat',
          subtitle: user.canViewResidents ? 'Residents' : 'Support',
          icon: AppIcons.chat,
          route: AppRoutes.chat,
          color: const Color(0xFF2F6F56),
        ),
        if (user.canManageLaundry)
          _DashboardAction(
            title: 'Laundry',
            subtitle: 'Queue',
            icon: AppIcons.laundry,
            route: AppRoutes.laundry,
            color: const Color(0xFF2B6CB0),
          ),
        if (user.canCollectFees)
          _DashboardAction(
            title: 'Fees',
            subtitle: user.canManageFeeSettings ? 'Control' : 'Collect',
            icon: AppIcons.fees,
            route: AppRoutes.fees,
            color: AppColors.kGreenColor,
          ),
        _DashboardAction(
          title: 'Notice',
          subtitle: 'Board',
          icon: AppIcons.notice,
          route: AppRoutes.notices,
          color: const Color(0xFF0F766E),
        ),
        if (user.canManageMess)
          _DashboardAction(
            title: 'Mess',
            subtitle: 'Meals',
            icon: AppIcons.mess,
            route: AppRoutes.mess,
            color: const Color(0xFF0F766E),
          ),
        if (user.canManageFrontDesk)
          _DashboardAction(
            title: 'Parcel Desk',
            subtitle: 'Parcels & visitors',
            icon: AppIcons.parcel,
            route: AppRoutes.parcelDesk,
            color: const Color(0xFF2B6CB0),
          ),
        if (user.canManageGatePass)
          _DashboardAction(
            title: 'Gate Pass',
            subtitle: 'Approvals',
            icon: AppIcons.gatePass,
            route: AppRoutes.gatePass,
            color: const Color(0xFFB54708),
          ),
        if (user.canManageRoomRequests)
          _DashboardAction(
            title: 'Requests',
            subtitle: 'Room change',
            icon: AppIcons.request,
            route: AppRoutes.roomChangeRequests,
            color: const Color(0xFF4C8E73),
          ),
        if (user.canManageInventory)
          _DashboardAction(
            title: 'Rooms',
            subtitle: 'Inventory',
            icon: AppIcons.room,
            route: AppRoutes.roomAvailability,
            color: const Color(0xFF4C8E73),
            countText: state.rooms.length.toString(),
          ),
      ];
    }
    final List<_DashboardAction> customActions = shortcuts
        .where((AdminServiceShortcut item) => item.roles.contains(user.role))
        .map(_actionFromShortcut)
        .toList(growable: false);
    return <_DashboardAction>[
      ...baseActions,
      ...customActions.where(
        (_DashboardAction action) => !baseActions.any(
          (_DashboardAction existing) =>
              existing.route == action.route &&
              existing.title == action.title &&
              existing.subtitle == action.subtitle,
        ),
      ),
    ];
  }

  _DashboardAction _actionFromShortcut(AdminServiceShortcut shortcut) {
    return _DashboardAction(
      title: shortcut.title,
      subtitle: shortcut.subtitle,
      route: shortcut.route,
      color: _colorFromHex(shortcut.accentHex) ?? AppColors.kGreenColor,
      icon: AppIcons.byKey(shortcut.iconKey),
    );
  }

  Color? _colorFromHex(String? hex) {
    if (hex == null) {
      return null;
    }
    final String sanitized = hex.replaceAll('#', '').trim();
    if (sanitized.length != 6) {
      return null;
    }
    final int? parsed = int.tryParse('FF$sanitized', radix: 16);
    return parsed == null ? null : Color(parsed);
  }

  static String _formatAmount(int value) {
    final String digits = value.toString();
    final RegExp groupPattern = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
    return digits.replaceAllMapped(groupPattern, (Match match) {
      return '${match[1]},';
    });
  }
}
