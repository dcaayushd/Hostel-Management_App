import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/constants.dart';
import '../../common/spacing.dart';
import '../models/app_user.dart';
import '../models/hostel_room.dart';
import '../utils/app_icons.dart';
import 'app_top_info_surface.dart';

part 'user_hero_card_parts.dart';

class UserHeroCard extends StatelessWidget {
  const UserHeroCard({
    super.key,
    required this.user,
    this.room,
    this.onTap,
  });

  final AppUser user;
  final HostelRoom? room;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String initials =
        '${user.firstName.characters.first}${user.lastName.characters.first}'
            .toUpperCase();
    final String title = user.jobTitle ?? user.accessLabel;

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
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _ProfilePhoto(initials: initials),
                    widthSpacer(14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            user.fullName,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  height: 1.05,
                                ),
                          ),
                          heightSpacer(8),
                          Wrap(
                            spacing: 7.w,
                            runSpacing: 7.h,
                            children: <Widget>[
                              _HeroChip(label: title),
                              _HeroChip(label: 'ID ${user.id}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                heightSpacer(14),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: <Widget>[
                    _HeroInfoChip(
                      icon: user.emailVerified
                          ? AppIcons.verified
                          : AppIcons.email,
                      label:
                          '${user.email} ${user.emailVerified ? '• verified' : '• pending'}',
                    ),
                    _HeroInfoChip(
                      icon: AppIcons.phone,
                      label: user.phoneNumber,
                    ),
                    _HeroInfoChip(
                      icon: AppIcons.room,
                      label: room?.label ?? 'No room assigned',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
