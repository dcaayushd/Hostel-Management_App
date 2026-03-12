part of '../screens/settings_screen.dart';

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({
    required this.user,
    required this.roomLabel,
    required this.showRoomDetails,
    required this.showContactInfo,
  });

  final AppUser user;
  final String? roomLabel;
  final bool showRoomDetails;
  final bool showContactInfo;

  @override
  Widget build(BuildContext context) {
    final List<String> parts = <String>[
      user.firstName,
      user.lastName,
    ].where((String part) => part.trim().isNotEmpty).toList(growable: false);
    final String initials = parts
        .take(2)
        .map((String part) => part.characters.first.toUpperCase())
        .join();

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
      decoration: buildTopInfoSurfaceDecoration(
        context,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _HeaderAvatar(initials: initials),
              widthSpacer(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Account & preferences',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    heightSpacer(4),
                    Text(
                      user.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    heightSpacer(4),
                    Text(
                      '${user.accessLabel} • ${showRoomDetails ? roomLabel ?? 'No room assigned' : 'Room hidden'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    heightSpacer(4),
                    Text(
                      showContactInfo
                          ? user.email
                          : 'Contact details hidden on cards',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.78),
                          ),
                    ),
                  ],
                ),
              ),
              widthSpacer(8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.profile);
                  },
                  borderRadius: BorderRadius.circular(20.r),
                  child: Container(
                    height: 42.h,
                    width: 42.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.16),
                      ),
                    ),
                    child: Icon(
                      AppIcons.open,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          heightSpacer(14),
          Row(
            children: <Widget>[
              Expanded(
                child: _HeaderMetaPill(
                  icon: user.emailVerified
                      ? AppIcons.verified
                      : AppIcons.pendingEmail,
                  label: user.emailVerified
                      ? 'Email verified'
                      : 'Verification pending',
                ),
              ),
              widthSpacer(8),
              Expanded(
                child: _HeaderMetaPill(
                  icon: AppIcons.phone,
                  label: showContactInfo ? user.phoneNumber : 'Contact hidden',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
