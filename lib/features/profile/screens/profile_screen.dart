import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../app/app_chrome.dart';
import '../../../common/app_bar.dart';
import '../../../common/spacing.dart';
import '../../../core/models/app_user.dart';
import '../../../core/models/hostel_room.dart';
import '../../../core/services/hostel_repository.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/app_icons.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/widgets/app_screen_background.dart';
import '../../../core/widgets/app_section_card.dart';
import '../../../core/widgets/user_hero_card.dart';
import '../../../theme/colors.dart';

part '../widgets/profile_screen_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final AppUser? user = state.currentUser;
    final Brightness brightness = Theme.of(context).brightness;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: buildAppBar(
        context,
        'Profile',
      ),
      body: AppScreenBackground(
        topChromeHeight: 118,
        child: ListView(
          padding:
              appPagePadding(context, horizontal: 16, top: 8, bottomExtra: 18),
          children: <Widget>[
            UserHeroCard(
              user: user,
              room: state.currentRoom,
            ),
            heightSpacer(14),
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Identity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryTextFor(brightness),
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  heightSpacer(14),
                  _DetailRow(
                    icon: AppIcons.userId,
                    label: 'Hostel ID',
                    value: user.id,
                  ),
                  _DetailRow(
                    icon: AppIcons.person,
                    label: 'Username',
                    value: user.username,
                  ),
                  _DetailRow(
                    icon: AppIcons.role,
                    label: 'Role',
                    value: user.accessLabel,
                  ),
                  _DetailRow(
                    icon: AppIcons.email,
                    label: 'Email',
                    value: user.email,
                  ),
                  _DetailRow(
                    icon: user.emailVerified
                        ? AppIcons.verified
                        : AppIcons.pendingEmail,
                    label: 'Email status',
                    value: user.emailVerified ? 'Verified' : 'Pending',
                  ),
                  _DetailRow(
                    icon: AppIcons.phone,
                    label: 'Phone',
                    value: user.phoneNumber,
                    isLast: true,
                  ),
                ],
              ),
            ),
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Room Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryTextFor(brightness),
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  heightSpacer(14),
                  if (state.currentRoom case final HostelRoom room) ...<Widget>[
                    _DetailRow(
                      icon: AppIcons.block,
                      label: 'Block',
                      value: room.block,
                    ),
                    _DetailRow(
                      icon: AppIcons.room,
                      label: 'Room',
                      value: room.label,
                    ),
                    _DetailRow(
                      icon: AppIcons.roomFilled,
                      label: 'Type',
                      value: room.roomType,
                    ),
                    _DetailRow(
                      icon: AppIcons.beds,
                      label: 'Beds',
                      value: '${room.occupiedBeds}/${room.capacity} occupied',
                    ),
                    _DetailRow(
                      icon: AppIcons.availability,
                      label: 'Availability',
                      value: '${room.availableBeds} bed(s) open',
                      isLast: true,
                    ),
                  ] else
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: AppColors.softSurfaceFor(brightness).withValues(
                          alpha: 0.55,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        'No room is assigned to this account yet.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.mutedTextFor(brightness),
                              height: 1.4,
                            ),
                      ),
                    ),
                ],
              ),
            ),
            if (user.isAdmin)
              AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Admin Workspace',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primaryTextFor(brightness),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    heightSpacer(8),
                    Text(
                      state.isDemoMode
                          ? 'Remove demo residents, staff, rooms, notices, and history while keeping your admin access.'
                          : 'Reset the current workspace into a clean handoff state while keeping only your admin account.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedTextFor(brightness),
                            height: 1.45,
                          ),
                    ),
                    heightSpacer(14),
                    FilledButton.tonalIcon(
                      onPressed: () {
                        _confirmPrepareWorkspace(context);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFD92D20).withValues(alpha: 0.08),
                        foregroundColor: const Color(0xFFD92D20),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                      ),
                      icon: const Icon(AppIcons.workspace),
                      label: const Text('Start Fresh Setup'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmPrepareWorkspace(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Prepare clean workspace'),
          content: const Text(
            'This removes residents, staff, rooms, notices, payments, requests, and activity history. Your current admin account will be kept.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD92D20),
              ),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await context.read<AppState>().prepareCleanWorkspace();
      if (!context.mounted) {
        return;
      }
      showAppMessage(
        context,
        'Workspace reset. You can now add your own hostel data.',
      );
    } on HostelRepositoryException catch (error) {
      if (!context.mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      showAppMessage(
        context,
        'Unable to prepare the clean workspace.',
        isError: true,
      );
    }
  }
}
