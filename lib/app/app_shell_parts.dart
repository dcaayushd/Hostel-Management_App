part of 'app_shell.dart';

// Tweak these values in `app_chrome.dart` to move the floating nav or change
// how much page content can scroll around it.

class _AuthenticatedShell extends StatefulWidget {
  const _AuthenticatedShell({super.key});

  @override
  State<_AuthenticatedShell> createState() => _AuthenticatedShellState();
}

class _AuthenticatedShellState extends State<_AuthenticatedShell> {
  int _selectedIndex = 0;
  Timer? _activityRefreshTimer;
  final Set<String> _seenNotificationIds = <String>{};
  String? _notificationOwnerId;
  String? _pendingNotificationId;

  @override
  void initState() {
    super.initState();
    _activityRefreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) {
        if (!mounted) {
          return;
        }
        final AppState state = context.read<AppState>();
        if (!state.activityAutoRefreshEnabled) {
          return;
        }
        unawaited(state.refreshActivityFeed());
      },
    );
  }

  @override
  void dispose() {
    _activityRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final AppUser? user = state.currentUser;
    final ThemeData shellTheme = Theme.of(context);
    final Brightness brightness = shellTheme.brightness;
    if (user == null) {
      return const SizedBox.shrink();
    }

    final List<_RootDestination> destinations = _destinationsFor(user);
    final int resolvedIndex = _selectedIndex >= destinations.length
        ? destinations.length - 1
        : _selectedIndex;
    if (resolvedIndex != _selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _selectedIndex = resolvedIndex;
        });
      });
    }
    _primeNotificationState(user.id, state.notifications);
    _scheduleNotificationBanner(state);

    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double safeBottomInset = mediaQuery.padding.bottom;
    final double navHeight = kFloatingBottomNavHeight.h;
    final double navBottomOffset =
        safeBottomInset + kFloatingBottomNavBottomGap.h - 20.h;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.screenBackgroundGradient(brightness),
        ),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.zero,
                child: Theme(
                  data: shellTheme.copyWith(
                    scaffoldBackgroundColor: Colors.transparent,
                  ),
                  child: MediaQuery(
                    data: mediaQuery,
                    child: IndexedStack(
                      index: resolvedIndex,
                      children: destinations
                          .map((_RootDestination item) => item.screen)
                          .toList(growable: false),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: kFloatingBottomNavHorizontalInset.w,
              right: kFloatingBottomNavHorizontalInset.w,
              bottom: navBottomOffset,
              child: _FloatingBottomNavBar(
                height: navHeight,
                destinations: destinations,
                selectedIndex: resolvedIndex,
                onSelected: (int index) {
                  if (index == _selectedIndex) {
                    return;
                  }
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _primeNotificationState(
    String userId,
    List<HostelNotificationItem> notifications,
  ) {
    if (_notificationOwnerId == userId) {
      return;
    }
    _notificationOwnerId = userId;
    _pendingNotificationId = null;
    _seenNotificationIds
      ..clear()
      ..addAll(notifications.map((HostelNotificationItem item) => item.id));
  }

  void _scheduleNotificationBanner(AppState state) {
    if (!state.inAppNotificationsEnabled) {
      _seenNotificationIds.addAll(
        state.notifications.map((HostelNotificationItem item) => item.id),
      );
      return;
    }
    HostelNotificationItem? nextNotification;
    for (final HostelNotificationItem item in state.notifications) {
      if (item.isRead ||
          _seenNotificationIds.contains(item.id) ||
          _pendingNotificationId == item.id) {
        continue;
      }
      nextNotification = item;
      break;
    }
    if (nextNotification == null) {
      return;
    }

    final HostelNotificationItem notificationToShow = nextNotification;
    _pendingNotificationId = notificationToShow.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _pendingNotificationId = null;
      _seenNotificationIds.add(notificationToShow.id);
      final String bannerMessage = state.notificationPreviewsEnabled
          ? '${notificationToShow.title}: ${notificationToShow.message}'
          : notificationToShow.title;
      showAppMessage(
        context,
        bannerMessage,
        onTap: () {
          unawaited(
            openNotificationDestination(context, notificationToShow),
          );
        },
      );
    });
  }

  List<_RootDestination> _destinationsFor(AppUser user) {
    switch (user.role) {
      case UserRole.student:
        return const <_RootDestination>[
          _RootDestination(
            label: 'Home',
            icon: AppIcons.home,
            activeIcon: AppIcons.homeFilled,
            screen: HomeScreen(),
          ),
          _RootDestination(
            label: 'Search',
            icon: AppIcons.search,
            activeIcon: AppIcons.searchFilled,
            screen: SearchScreen(),
          ),
          _RootDestination(
            label: 'Notice',
            icon: AppIcons.notice,
            activeIcon: AppIcons.noticeFilled,
            screen: NoticeBoardScreen(),
          ),
          _RootDestination(
            label: 'Fees',
            icon: AppIcons.fees,
            activeIcon: AppIcons.feesFilled,
            screen: HostelFeeScreen(),
          ),
          _RootDestination(
            label: 'Settings',
            icon: AppIcons.settings,
            activeIcon: AppIcons.settingsFilled,
            screen: SettingsScreen(),
          ),
        ];
      case UserRole.guest:
        return const <_RootDestination>[
          _RootDestination(
            label: 'Home',
            icon: AppIcons.home,
            activeIcon: AppIcons.homeFilled,
            screen: HomeScreen(),
          ),
          _RootDestination(
            label: 'Search',
            icon: AppIcons.search,
            activeIcon: AppIcons.searchFilled,
            screen: SearchScreen(),
          ),
          _RootDestination(
            label: 'Notice',
            icon: AppIcons.notice,
            activeIcon: AppIcons.noticeFilled,
            screen: NoticeBoardScreen(),
          ),
          _RootDestination(
            label: 'Chat',
            icon: AppIcons.chat,
            activeIcon: AppIcons.chatFilled,
            screen: ChatScreen(),
          ),
          _RootDestination(
            label: 'Settings',
            icon: AppIcons.settings,
            activeIcon: AppIcons.settingsFilled,
            screen: SettingsScreen(),
          ),
        ];
      case UserRole.staff:
      case UserRole.admin:
        return <_RootDestination>[
          const _RootDestination(
            label: 'Home',
            icon: AppIcons.home,
            activeIcon: AppIcons.homeFilled,
            screen: HomeScreen(),
          ),
          const _RootDestination(
            label: 'Search',
            icon: AppIcons.search,
            activeIcon: AppIcons.searchFilled,
            screen: SearchScreen(),
          ),
          const _RootDestination(
            label: 'Notice',
            icon: AppIcons.notice,
            activeIcon: AppIcons.noticeFilled,
            screen: NoticeBoardScreen(),
          ),
          if (user.canCollectFees)
            const _RootDestination(
              label: 'Fees',
              icon: AppIcons.fees,
              activeIcon: AppIcons.feesFilled,
              screen: HostelFeeScreen(),
            )
          else
            const _RootDestination(
              label: 'Issues',
              icon: AppIcons.issue,
              activeIcon: AppIcons.issueFilled,
              screen: IssueScreen(),
            ),
          const _RootDestination(
            label: 'Settings',
            icon: AppIcons.settings,
            activeIcon: AppIcons.settingsFilled,
            screen: SettingsScreen(),
          ),
        ];
    }
  }
}

class _FloatingBottomNavBar extends StatelessWidget {
  const _FloatingBottomNavBar({
    required this.height,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  final double height;
  final List<_RootDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kFloatingBottomNavOuterRadius.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(
              alpha: brightness == Brightness.dark ? 0.14 : 0.06,
            ),
            blurRadius: brightness == Brightness.dark ? 18 : 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kFloatingBottomNavOuterRadius.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: height,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(kFloatingBottomNavOuterRadius.r),
              gradient: LinearGradient(
                colors: <Color>[
                  AppColors.floatingChromeGradient(brightness)
                      .colors
                      .first
                      .withValues(
                        alpha: brightness == Brightness.dark ? 0.96 : 0.90,
                      ),
                  AppColors.floatingChromeGradient(brightness)
                      .colors
                      .last
                      .withValues(
                        alpha: brightness == Brightness.dark ? 0.94 : 0.88,
                      ),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: brightness == Brightness.dark ? 0.14 : 0.10,
                ),
              ),
            ),
            child: Row(
              children: List<Widget>.generate(destinations.length, (int index) {
                final _RootDestination item = destinations[index];
                final bool selected = index == selectedIndex;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: _BottomNavItem(
                      destination: item,
                      selected: selected,
                      onTap: () => onSelected(index),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _RootDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = selected ? Colors.white : Colors.white70;
    final TextStyle labelStyle =
        Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: selected ? 0.98 : 0.72),
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  height: 1,
                ) ??
            TextStyle(
              color: Colors.white.withValues(alpha: selected ? 0.98 : 0.72),
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kFloatingBottomNavItemRadius.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kFloatingBottomNavItemRadius.r),
            color: selected
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.transparent,
          ),
          padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedScale(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                scale: selected ? 1 : 0.94,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  height: 30.h,
                  width: 30.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? AppColors.kGreenColor
                        : Colors.white.withValues(alpha: 0.04),
                  ),
                  child: Icon(
                    selected ? destination.activeIcon : destination.icon,
                    size: 17.sp,
                    color: iconColor,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                style: labelStyle,
                child: SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      destination.label,
                      maxLines: 1,
                    ),
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

class _RootDestination {
  const _RootDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.screen,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget screen;
}
