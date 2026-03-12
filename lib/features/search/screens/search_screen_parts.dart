part of 'search_screen.dart';

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final NoticeProvider noticeProvider = context.watch<NoticeProvider>();
    final AppUser? user = state.currentUser;
    final Brightness brightness = Theme.of(context).brightness;
    if (user == null) {
      return const SizedBox.shrink();
    }

    final List<_SearchResult> quickActions = _quickActionsFor(user);
    final List<_SearchResult> searchResults = _query.trim().isEmpty
        ? const <_SearchResult>[]
        : _filterResults(
            _allSearchResults(
              state,
              noticeProvider.notices,
              user,
              quickActions,
            ),
            _query,
          );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: buildAppBar(context, 'Search'),
      body: AppScreenBackground(
        child: ListView(
          padding:
              appPagePadding(context, horizontal: 14, top: 8, bottomExtra: 18),
          children: <Widget>[
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Find anything quickly',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryTextFor(brightness),
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  heightSpacer(4),
                  Text(
                    'Search screens, notices, rooms, residents, issues, requests, and updates from one place.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedTextFor(brightness),
                          height: 1.45,
                        ),
                  ),
                  heightSpacer(12),
                  CustomTextField(
                    controller: _searchController,
                    inputHint: 'Search the app',
                    onChanged: (String value) {
                      setState(() {
                        _query = value;
                      });
                    },
                    prefixIcon: Icon(
                      AppIcons.search,
                      color: AppColors.mutedTextFor(brightness),
                    ),
                    suffixIcon: _query.trim().isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _query = '';
                              });
                            },
                            icon: Icon(
                              AppIcons.close,
                              color: AppColors.mutedTextFor(brightness),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            if (_query.trim().isEmpty) ...<Widget>[
              AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Quick access',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primaryTextFor(brightness),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    heightSpacer(10),
                    ...quickActions.map(
                      (_SearchResult item) => _SearchResultTile(result: item),
                    ),
                  ],
                ),
              ),
              AppSectionCard(
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: <Widget>[
                    _SearchStatChip(
                      label: '${noticeProvider.notices.length} notices',
                      icon: AppIcons.notice,
                    ),
                    _SearchStatChip(
                      label: '${state.notifications.length} alerts',
                      icon: AppIcons.notifications,
                    ),
                    _SearchStatChip(
                      label: '${state.rooms.length} rooms',
                      icon: AppIcons.room,
                    ),
                    _SearchStatChip(
                      label: '${state.visibleIssues.length} issues',
                      icon: AppIcons.issue,
                    ),
                  ],
                ),
              ),
            ] else if (searchResults.isEmpty)
              const AppSectionCard(
                child: AppEmptyState(
                  icon: AppIcons.emptySearch,
                  title: 'No matches found',
                  message:
                      'Try a different keyword like fee, room, resident, notice, or issue.',
                ),
              )
            else
              AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${searchResults.length} result${searchResults.length == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primaryTextFor(brightness),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    heightSpacer(10),
                    ...searchResults.map(
                      (_SearchResult item) => _SearchResultTile(result: item),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<_SearchResult> _quickActionsFor(AppUser user) {
    final List<_SearchResult> items = <_SearchResult>[
      const _SearchResult(
        key: 'action-notifications',
        title: 'Notifications',
        subtitle: 'Fee reminders, chats, notices, and updates',
        section: 'Quick access',
        route: AppRoutes.notifications,
        icon: AppIcons.notifications,
        accentColor: AppColors.kGreenColor,
        searchTerms: 'notifications alerts updates reminder messages inbox',
      ),
      const _SearchResult(
        key: 'action-notices',
        title: 'Notice Board',
        subtitle: 'Announcements, events, and rules',
        section: 'Quick access',
        route: AppRoutes.notices,
        icon: AppIcons.notice,
        accentColor: Color(0xFF0F766E),
        searchTerms: 'notices notice board announcements rules events',
      ),
      const _SearchResult(
        key: 'action-profile',
        title: 'Profile',
        subtitle: 'Identity and room details',
        section: 'Quick access',
        route: AppRoutes.profile,
        icon: AppIcons.profile,
        accentColor: AppColors.kDeepGreenColor,
        searchTerms: 'profile account identity room details',
      ),
      const _SearchResult(
        key: 'action-settings',
        title: 'Settings',
        subtitle: 'Theme, alerts, sync, and preferences',
        section: 'Quick access',
        route: AppRoutes.settings,
        icon: AppIcons.settings,
        accentColor: Color(0xFF3B755E),
        searchTerms: 'settings preferences theme alerts sync appearance',
      ),
    ];

    if (user.role == UserRole.student) {
      items.insertAll(2, <_SearchResult>[
        const _SearchResult(
          key: 'action-chat',
          title: 'Chat',
          subtitle: 'Conversation with staff',
          section: 'Quick access',
          route: AppRoutes.chat,
          icon: AppIcons.chat,
          accentColor: Color(0xFF2F6F56),
          searchTerms: 'chat messages staff support',
        ),
        const _SearchResult(
          key: 'action-fees',
          title: 'Fees & Payments',
          subtitle: 'Current charges and receipts',
          section: 'Quick access',
          route: AppRoutes.fees,
          icon: AppIcons.fees,
          accentColor: AppColors.kGreenColor,
          searchTerms: 'fees payments receipt billing charges dues',
        ),
        const _SearchResult(
          key: 'action-room',
          title: 'Room Availability',
          subtitle: 'Room list and bed availability',
          section: 'Quick access',
          route: AppRoutes.roomAvailability,
          icon: AppIcons.room,
          accentColor: AppColors.kDeepGreenColor,
          searchTerms: 'room availability block bed hostel room',
        ),
      ]);
    } else if (user.role == UserRole.guest) {
      items.insert(
        2,
        const _SearchResult(
          key: 'action-chat',
          title: 'Chat',
          subtitle: 'Conversation with staff',
          section: 'Quick access',
          route: AppRoutes.chat,
          icon: AppIcons.chat,
          accentColor: Color(0xFF2F6F56),
          searchTerms: 'chat messages staff support',
        ),
      );
    } else {
      items.insert(
        2,
        _SearchResult(
          key: 'action-issues',
          title: user.canManageIssues ? 'Issue Queue' : 'Assigned Issues',
          subtitle: user.canManageIssues
              ? 'Track and assign resident issues'
              : 'See tasks assigned to you and update progress',
          section: 'Quick access',
          route: AppRoutes.issues,
          icon: AppIcons.issue,
          accentColor: const Color(0xFFB54708),
          searchTerms: user.canManageIssues
              ? 'issues complaints maintenance repair queue assign'
              : 'assigned issues complaints tasks maintenance progress',
        ),
      );
      if (user.canCollectFees) {
        items.insert(
          2,
          const _SearchResult(
            key: 'action-fees',
            title: 'Fee Collection',
            subtitle: 'Resident balances, reminders, and receipts',
            section: 'Quick access',
            route: AppRoutes.fees,
            icon: AppIcons.fees,
            accentColor: AppColors.kGreenColor,
            searchTerms: 'fees collection balances receipts reminders',
          ),
        );
      }
      if (user.canViewResidents) {
        items.insertAll(4, <_SearchResult>[
          const _SearchResult(
            key: 'action-residents',
            title: 'Residents',
            subtitle: 'Resident directory and room assignments',
            section: 'Quick access',
            route: AppRoutes.residents,
            icon: AppIcons.residents,
            accentColor: Color(0xFF4C8E73),
            searchTerms: 'residents students directory assignments',
          ),
          const _SearchResult(
            key: 'action-staff',
            title: 'Staff Directory',
            subtitle: 'Staff accounts and management',
            section: 'Quick access',
            route: AppRoutes.staff,
            icon: AppIcons.staff,
            accentColor: Color(0xFF2B6CB0),
            searchTerms: 'staff directory employees workers',
          ),
        ]);
      } else if (user.canViewStaffDirectory) {
        items.insert(
          4,
          const _SearchResult(
            key: 'action-staff',
            title: 'Staff Directory',
            subtitle: 'Staff accounts and coordination',
            section: 'Quick access',
            route: AppRoutes.staff,
            icon: AppIcons.staff,
            accentColor: Color(0xFF2B6CB0),
            searchTerms: 'staff directory employees workers team',
          ),
        );
      }
      if (user.isAdmin) {
        items.insert(
          4,
          const _SearchResult(
            key: 'action-admin-catalog',
            title: 'Operations Catalog',
            subtitle: 'Manage service lists, presets, and shortcuts',
            section: 'Quick access',
            route: AppRoutes.adminCatalog,
            icon: AppIcons.adminCatalog,
            accentColor: Color(0xFF3B755E),
            searchTerms:
                'operations catalog admin categories presets shortcuts machines carriers alerts',
          ),
        );
      }
    }

    return items;
  }

  List<_SearchResult> _allSearchResults(
    AppState state,
    List<NoticeItem> notices,
    AppUser user,
    List<_SearchResult> quickActions,
  ) {
    final List<_SearchResult> results = <_SearchResult>[...quickActions];

    for (final NoticeItem notice in notices) {
      results.add(
        _SearchResult(
          key: 'notice-${notice.id}',
          title: notice.title,
          subtitle: '${normalizeNoticeCategoryLabel(notice.category)} notice',
          section: 'Notices',
          route: AppRoutes.notices,
          icon: AppIcons.forNoticeCategory(notice.category),
          accentColor: const Color(0xFF0F766E),
          searchTerms:
              '${notice.title} ${notice.message} ${normalizeNoticeCategoryLabel(notice.category)} notice',
        ),
      );
    }

    for (final HostelNotificationItem item in state.notifications) {
      results.add(
        _SearchResult(
          key: 'notification-${item.id}',
          title: item.title,
          subtitle: item.resolvedType.label,
          section: 'Notifications',
          route: AppRoutes.notifications,
          icon: AppIcons.forNotificationType(item.resolvedType),
          accentColor: AppColors.kGreenColor,
          searchTerms:
              '${item.title} ${item.message} ${item.resolvedType.label} notification',
        ),
      );
    }

    final Iterable<HostelRoom> searchableRooms = user.canManageInventory
        ? state.rooms
        : <HostelRoom>[
            if (state.currentRoom != null) state.currentRoom!,
            ...state.availableRoomsFor(includeRoomId: state.currentRoom?.id),
          ];
    for (final HostelRoom room in searchableRooms) {
      results.add(
        _SearchResult(
          key: 'room-${room.id}',
          title: room.label,
          subtitle: '${room.block} • ${room.roomType}',
          section: 'Rooms',
          route: AppRoutes.roomAvailability,
          arguments: RoomAvailabilityRouteArgs(
            roomId: room.id,
            blockCode: room.block,
          ),
          icon: AppIcons.room,
          accentColor: AppColors.kDeepGreenColor,
          searchTerms:
              '${room.label} ${room.block} ${room.roomType} room hostel ${room.capacity}',
        ),
      );
    }

    final Iterable<AppUser> people =
        user.role == UserRole.student || user.role == UserRole.guest
            ? state.staffMembers
            : user.canViewResidents
                ? <AppUser>[
                    ...state.students,
                    ...state.guests,
                    ...state.staffMembers
                  ]
                : state.staffMembers;
    final bool isResident =
        user.role == UserRole.student || user.role == UserRole.guest;
    for (final AppUser person in people) {
      results.add(
        _SearchResult(
          key: 'user-${person.id}',
          title: person.fullName,
          subtitle:
              '${person.jobTitle ?? person.accessLabel} • ${person.email}',
          section: 'People',
          route: isResident
              ? AppRoutes.chat
              : person.role == UserRole.student || person.role == UserRole.guest
                  ? AppRoutes.residents
                  : AppRoutes.staff,
          icon: person.role == UserRole.student || person.role == UserRole.guest
              ? AppIcons.profile
              : AppIcons.staff,
          accentColor: const Color(0xFF4C8E73),
          searchTerms:
              '${person.fullName} ${person.email} ${person.phoneNumber} ${person.accessLabel} ${person.jobTitle ?? ''}',
        ),
      );
    }

    for (final IssueTicket issue in state.visibleIssues) {
      results.add(
        _SearchResult(
          key: 'issue-${issue.id}',
          title: issue.category,
          subtitle: issue.status.label,
          section: 'Issues',
          route: AppRoutes.issues,
          icon: AppIcons.issue,
          accentColor: const Color(0xFFB54708),
          searchTerms:
              '${issue.category} ${issue.comment} ${issue.status.label} issue complaint',
        ),
      );
    }

    for (final RoomChangeRequest request in state.visibleRoomRequests) {
      results.add(
        _SearchResult(
          key: 'request-${request.id}',
          title: 'Room change',
          subtitle: request.status.label,
          section: 'Requests',
          route: AppRoutes.roomChangeRequests,
          icon: AppIcons.request,
          accentColor: const Color(0xFF4C8E73),
          searchTerms:
              '${request.reason} ${request.status.label} room request change ${request.desiredRoomId}',
        ),
      );
    }

    for (final LaundryBooking booking in state.visibleLaundryBookings) {
      results.add(
        _SearchResult(
          key: 'laundry-${booking.id}',
          title: booking.machineLabel,
          subtitle: booking.status.label,
          section: 'Laundry',
          route: AppRoutes.laundry,
          icon: AppIcons.laundry,
          accentColor: const Color(0xFF2B6CB0),
          searchTerms:
              '${booking.machineLabel} ${booking.slotLabel} ${booking.notes} ${booking.status.label} laundry',
        ),
      );
    }

    for (final AdminServiceShortcut shortcut in state
        .adminCatalog.serviceShortcuts
        .where((AdminServiceShortcut item) => item.roles.contains(user.role))) {
      results.add(
        _SearchResult(
          key: 'shortcut-${shortcut.route}-${shortcut.title}',
          title: shortcut.title,
          subtitle: shortcut.subtitle,
          section: 'Services',
          route: shortcut.route,
          icon: AppIcons.byKey(shortcut.iconKey),
          accentColor:
              _colorFromHex(shortcut.accentHex) ?? AppColors.kGreenColor,
          searchTerms:
              '${shortcut.title} ${shortcut.subtitle} ${shortcut.route} service shortcut',
        ),
      );
    }

    return results;
  }

  List<_SearchResult> _filterResults(
    List<_SearchResult> items,
    String query,
  ) {
    final List<String> tokens = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((String token) => token.isNotEmpty)
        .toList(growable: false);
    final Set<String> seenKeys = <String>{};
    return items.where((_SearchResult item) {
      if (!seenKeys.add(item.key)) {
        return false;
      }
      final String haystack =
          '${item.title} ${item.subtitle} ${item.section} ${item.searchTerms}'
              .toLowerCase();
      return tokens.every(haystack.contains);
    }).toList(growable: false);
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
}

class _SearchResult {
  const _SearchResult({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.section,
    required this.route,
    required this.icon,
    required this.accentColor,
    required this.searchTerms,
    this.arguments,
  });

  final String key;
  final String title;
  final String subtitle;
  final String section;
  final String route;
  final IconData icon;
  final Color accentColor;
  final String searchTerms;
  final Object? arguments;
}
