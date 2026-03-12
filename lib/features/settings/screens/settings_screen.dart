import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../app/app_chrome.dart';
import '../../../app/app_metadata.dart';
import '../../../app/routes.dart';
import '../../../common/app_bar.dart';
import '../../../common/spacing.dart';
import '../../../core/models/app_user.dart';
import '../../../core/models/user_role.dart';
import '../../../core/services/hostel_repository.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/app_icons.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/widgets/app_screen_background.dart';
import '../../../core/widgets/app_section_card.dart';
import '../../../core/widgets/app_top_info_surface.dart';
import '../../../theme/colors.dart';

part '../widgets/settings_screen_settings_section.dart';
part '../widgets/settings_screen_settings_header.dart';
part '../widgets/settings_screen_header_avatar.dart';
part '../widgets/settings_screen_header_meta_pill.dart';
part '../widgets/settings_screen_settings_action_tile.dart';
part '../widgets/settings_screen_settings_switch_tile.dart';
part '../widgets/settings_screen_theme_mode_selector.dart';
part '../widgets/settings_screen_about_value_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
      appBar: buildAppBar(context, 'Settings'),
      body: AppScreenBackground(
        child: ListView(
          padding:
              appPagePadding(context, horizontal: 14, top: 6, bottomExtra: 22),
          children: <Widget>[
            _SettingsHeader(
              user: user,
              roomLabel: state.currentRoom?.label,
              showRoomDetails: state.showRoomDetailsOnCards,
              showContactInfo: state.showContactInfoOnCards,
            ),
            _SettingsSection(
              title: 'Account',
              child: Column(
                children: <Widget>[
                  if (!user.emailVerified)
                    _SettingsActionTile(
                      title: 'Verify email',
                      subtitle:
                          'Complete verification to unlock the full account flow.',
                      icon: AppIcons.pendingEmail,
                      accentColor: const Color(0xFFB54708),
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.verifyEmail);
                      },
                    ),
                  _SettingsActionTile(
                    title: 'Password & recovery',
                    subtitle:
                        'Send a reset code to ${user.email} and update your password.',
                    icon: AppIcons.lock,
                    accentColor: AppColors.kDeepGreenColor,
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.forgotPassword,
                        arguments: user.email,
                      );
                    },
                  ),
                  _SettingsActionTile(
                    title: 'Room access',
                    subtitle: user.role.isGuest
                        ? 'Review your resident profile and current access status.'
                        : 'Open room details, beds, and current availability.',
                    icon: AppIcons.room,
                    accentColor: AppColors.kGreenColor,
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        user.role.isGuest
                            ? AppRoutes.profile
                            : AppRoutes.roomAvailability,
                      );
                    },
                  ),
                  if (!user.role.isGuest)
                    _SettingsActionTile(
                      title: 'Room change requests',
                      subtitle:
                          'Track and manage the current room move request flow.',
                      icon: AppIcons.request,
                      accentColor: const Color(0xFF4C8E73),
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(AppRoutes.roomChangeRequests);
                      },
                    ),
                ],
              ),
            ),
            _SettingsSection(
              title: 'Appearance',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Theme mode',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.primaryTextFor(brightness),
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  heightSpacer(6),
                  Text(
                    'Choose whether the app follows your device, stays bright, or stays dark.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedTextFor(brightness),
                          height: 1.4,
                        ),
                  ),
                  heightSpacer(12),
                  _ThemeModeSelector(
                    selectedMode: state.themeMode,
                    onChanged: (ThemeMode mode) {
                      state.setThemeMode(mode);
                    },
                  ),
                ],
              ),
            ),
            _SettingsSection(
              title: 'Notifications',
              child: Column(
                children: <Widget>[
                  _SettingsSwitchTile(
                    icon: AppIcons.notifications,
                    title: 'Allow notifications',
                    subtitle:
                        'Show in-app alerts for notices, chat, room updates, and reminders.',
                    value: state.inAppNotificationsEnabled,
                    onChanged: (bool value) {
                      state.setInAppNotificationsEnabled(value);
                    },
                  ),
                  _SettingsSwitchTile(
                    icon: AppIcons.visibility,
                    title: 'Notification previews',
                    subtitle:
                        'Show full message details in in-app banners. Turn this off to show only the title.',
                    value: state.notificationPreviewsEnabled,
                    onChanged: (bool value) {
                      state.setNotificationPreviewsEnabled(value);
                    },
                  ),
                  _SettingsSwitchTile(
                    icon: AppIcons.notice,
                    title: 'Badge counts',
                    subtitle:
                        'Display unread counts on dashboard and notification entry points.',
                    value: state.notificationBadgesEnabled,
                    onChanged: (bool value) {
                      state.setNotificationBadgesEnabled(value);
                    },
                  ),
                  _SettingsActionTile(
                    title: 'Notification center',
                    subtitle:
                        'Review fee reminders, notice updates, chats, and recent alerts.',
                    icon: AppIcons.notificationsFilled,
                    accentColor: const Color(0xFF2B6CB0),
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.notifications);
                    },
                  ),
                  _SettingsActionTile(
                    title: 'System notification permissions',
                    subtitle:
                        'Banners, lock-screen alerts, and OS-level permission are still managed outside this settings panel.',
                    icon: AppIcons.support,
                    accentColor: const Color(0xFF0F766E),
                    onTap: () {
                      _showSystemNotificationInfo(context);
                    },
                  ),
                ],
              ),
            ),
            _SettingsSection(
              title: 'Privacy',
              child: Column(
                children: <Widget>[
                  _SettingsSwitchTile(
                    icon: AppIcons.room,
                    title: 'Show room details on cards',
                    subtitle:
                        'Display your assigned room on the home and settings summary cards.',
                    value: state.showRoomDetailsOnCards,
                    onChanged: (bool value) {
                      state.setShowRoomDetailsOnCards(value);
                    },
                  ),
                  _SettingsSwitchTile(
                    icon: AppIcons.phone,
                    title: 'Show contact info on cards',
                    subtitle:
                        'Display email and phone details on the home and settings summary cards.',
                    value: state.showContactInfoOnCards,
                    onChanged: (bool value) {
                      state.setShowContactInfoOnCards(value);
                    },
                  ),
                  _SettingsActionTile(
                    title: 'Privacy summary',
                    subtitle:
                        'See what the card privacy switches change across the app.',
                    icon: AppIcons.lock,
                    accentColor: AppColors.kDeepGreenColor,
                    onTap: () {
                      _showPrivacySummary(context);
                    },
                  ),
                ],
              ),
            ),
            _SettingsSection(
              title: 'Data & Sync',
              child: Column(
                children: <Widget>[
                  _SettingsSwitchTile(
                    icon: AppIcons.refresh,
                    title: 'Background activity refresh',
                    subtitle:
                        'Keep messages and activity updated automatically while you use the app.',
                    value: state.activityAutoRefreshEnabled,
                    onChanged: (bool value) {
                      state.setActivityAutoRefreshEnabled(value);
                    },
                  ),
                  _SettingsActionTile(
                    title: 'Reset app preferences',
                    subtitle:
                        'Restore theme, privacy, notification, and sync preferences without touching backend data.',
                    icon: AppIcons.reset,
                    accentColor: const Color(0xFF3B755E),
                    onTap: () {
                      _confirmResetPreferences(context);
                    },
                  ),
                ],
              ),
            ),
            _SettingsSection(
              title: 'Help & Support',
              child: Column(
                children: <Widget>[
                  _SettingsActionTile(
                    title: 'Notice board',
                    subtitle:
                        'Check announcements, events, and resident updates in one place.',
                    icon: AppIcons.notice,
                    accentColor: const Color(0xFF0F766E),
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.notices);
                    },
                  ),
                  _SettingsActionTile(
                    title: 'Chat support',
                    subtitle:
                        'Open the hostel conversation feed and reach the support team.',
                    icon: AppIcons.chat,
                    accentColor: const Color(0xFF2F6F56),
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.chat);
                    },
                  ),
                  if (!user.role.isGuest)
                    _SettingsActionTile(
                      title: user.role.isStudent
                          ? 'Report an issue'
                          : 'Issue queue',
                      subtitle: user.role.isStudent
                          ? 'Create a maintenance complaint or hostel support issue.'
                          : 'Review and manage the current issue queue.',
                      icon: AppIcons.issue,
                      accentColor: const Color(0xFF3B755E),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          user.role.isStudent
                              ? AppRoutes.createIssue
                              : AppRoutes.issues,
                        );
                      },
                    ),
                ],
              ),
            ),
            _SettingsSection(
              title: 'About',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        height: 42.h,
                        width: 42.w,
                        decoration: BoxDecoration(
                          color: AppColors.kGreenColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(
                          AppIcons.app,
                          color: AppColors.kGreenColor,
                          size: 20.sp,
                        ),
                      ),
                      widthSpacer(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              AppMetadata.appName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: AppColors.primaryTextFor(brightness),
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            heightSpacer(4),
                            Text(
                              AppMetadata.description,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.mutedTextFor(brightness),
                                    height: 1.4,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  heightSpacer(14),
                  Row(
                    children: <Widget>[
                      const Expanded(
                        child: _AboutValueCard(
                          label: 'Version',
                          value: AppMetadata.version,
                        ),
                      ),
                      widthSpacer(10),
                      const Expanded(
                        child: _AboutValueCard(
                          label: 'Build',
                          value: AppMetadata.buildNumber,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (user.role == UserRole.admin)
              _SettingsSection(
                title: 'Admin Workspace',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _SettingsActionTile(
                      title: 'Operations catalog',
                      subtitle:
                          'Manage complaint categories, notice categories, alert presets, parcel carriers, laundry machines, and dashboard shortcuts.',
                      icon: AppIcons.adminCatalog,
                      accentColor: AppColors.kGreenColor,
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.adminCatalog);
                      },
                    ),
                    _SettingsActionTile(
                      title: 'Fee categories',
                      subtitle:
                          'Open fee control to edit monthly rates and custom fee line items.',
                      icon: AppIcons.fees,
                      accentColor: const Color(0xFF2F6F56),
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.fees);
                      },
                    ),
                    _SettingsActionTile(
                      title: 'Weekly menu',
                      subtitle:
                          'Open mess management to publish or update the weekly menu.',
                      icon: AppIcons.mess,
                      accentColor: const Color(0xFF0F766E),
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.mess);
                      },
                    ),
                    heightSpacer(4),
                    Text(
                      'Remove demo residents, staff, rooms, notices, fees, and activity history while keeping your admin account.',
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
                            const Color(0xFFD92D20).withValues(alpha: 0.10),
                        foregroundColor: const Color(0xFFD92D20),
                      ),
                      icon: const Icon(AppIcons.workspace),
                      label: const Text('Start Fresh Setup'),
                    ),
                  ],
                ),
              ),
            _SettingsSection(
              title: 'Session',
              margin: EdgeInsets.only(bottom: 0.h),
              child: FilledButton.tonalIcon(
                onPressed: state.logout,
                style: FilledButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFD92D20).withValues(alpha: 0.10),
                  foregroundColor: const Color(0xFFD92D20),
                ),
                icon: const Icon(AppIcons.logout),
                label: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmResetPreferences(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset app preferences'),
          content: const Text(
            'This restores theme, notification, privacy, and sync preferences to their default values.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    final AppState state = context.read<AppState>();
    await state.resetAppPreferences();
    if (!context.mounted) {
      return;
    }
    showAppMessage(context, 'App preferences restored to defaults.');
  }

  Future<void> _showSystemNotificationInfo(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('System notification permissions'),
          content: const Text(
            'This build controls app-side notification behavior such as in-app alerts, previews, and badge counts. Device-level banners, lock-screen delivery, and notification-center permissions still need native OS permission wiring to be fully managed here.',
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Understood'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPrivacySummary(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Privacy summary'),
          content: const Text(
            'Room and contact privacy settings affect shared summary cards such as the dashboard welcome card and the settings header. They do not remove your information from secured backend records or admin-only workflows.',
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
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
              child: const Text('Start fresh'),
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
      showAppMessage(context, 'Workspace reset. Your admin account remains.');
    } on HostelRepositoryException catch (error) {
      if (!context.mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      showAppMessage(context, 'Unable to reset the workspace.', isError: true);
    }
  }
}
