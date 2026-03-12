import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common/spacing.dart';
import '../../../core/models/app_user.dart';
import '../../../core/models/hostel_room.dart';
import '../../../core/utils/app_icons.dart';
import '../../../core/widgets/app_top_info_surface.dart';

part 'home_welcome_card_parts.dart';

class HomeWelcomeCard extends StatelessWidget {
  const HomeWelcomeCard({
    super.key,
    required this.user,
    this.room,
    this.showRoomDetails = true,
    this.showContactInfo = true,
    this.onTap,
  });

  final AppUser user;
  final HostelRoom? room;
  final bool showRoomDetails;
  final bool showContactInfo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String greeting = _greetingFor(DateTime.now().hour);
    final String subtitle = user.jobTitle ?? user.accessLabel;
    final List<String> parts = <String>[
      user.firstName,
      user.lastName,
    ].where((String part) => part.trim().isNotEmpty).toList(growable: false);
    final String initials = parts
        .take(2)
        .map((String part) => part.characters.first.toUpperCase())
        .join();

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: buildTopInfoSurfaceDecoration(
          context,
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28.r),
          splashColor: Colors.white.withValues(alpha: 0.08),
          highlightColor: Colors.white.withValues(alpha: 0.04),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28.r),
            child: Padding(
              padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              greeting,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            heightSpacer(5),
                            Text(
                              user.firstName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    height: 1,
                                  ),
                            ),
                            heightSpacer(6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(999.r),
                              ),
                              child: Text(
                                subtitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _WelcomeAvatar(initials: initials),
                    ],
                  ),
                  heightSpacer(14),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: <Widget>[
                      _InfoPill(
                        icon: AppIcons.room,
                        label: showRoomDetails
                            ? room?.label ?? 'No room'
                            : 'Room hidden',
                      ),
                      _InfoPill(
                        icon: user.emailVerified
                            ? AppIcons.verified
                            : AppIcons.pendingEmail,
                        label:
                            user.emailVerified ? 'Verified' : 'Pending email',
                      ),
                      _InfoPill(
                        icon: AppIcons.phone,
                        label: showContactInfo
                            ? user.phoneNumber
                            : 'Contact hidden',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _greetingFor(int hour) {
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 17) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }
}
