import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../app/app_chrome.dart';
import '../../../app/routes.dart';
import '../../../common/app_bar.dart';
import '../../../common/spacing.dart';
import '../../../core/models/app_user.dart';
import '../../../core/services/hostel_repository.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/app_icons.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_feature_banner.dart';
import '../../../core/widgets/app_screen_background.dart';
import '../../../core/widgets/app_section_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../theme/colors.dart';

part '../widgets/staff_display_screen_widgets.dart';

class StaffDisplayScreen extends StatelessWidget {
  const StaffDisplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final AppUser? currentUser = state.currentUser;
    final List<AppUser> staffMembers = state.staffMembers;
    final bool canManageStaff = currentUser?.canManageStaff ?? false;
    final bool canViewStaff = currentUser?.canViewStaffDirectory ?? false;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: buildAppBar(
        context,
        'Staff Directory',
        actions: <Widget>[
          if (canManageStaff)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.createStaff);
              },
              icon: const Icon(
                Icons.person_add_alt_1_rounded,
                color: Colors.white,
              ),
              label: const Text(
                'Create',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: AppScreenBackground(
        child: !canViewStaff
            ? const AppEmptyState(
                icon: Icons.lock_outline,
                title: 'Access restricted',
                message: 'Only admin and staff accounts can view staff.',
              )
            : RefreshIndicator(
                onRefresh: state.refreshData,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: appPagePadding(
                    context,
                    horizontal: 18,
                    top: 12,
                    bottomExtra: 18,
                  ),
                  children: <Widget>[
                    AppFeatureBanner(
                      title: 'Team directory',
                      description: canManageStaff
                          ? 'Review admin and staff accounts, then create or remove access when needed.'
                          : 'Review the current admin and staff accounts.',
                      icon: AppIcons.staff,
                      accentColor: AppColors.kTopInfoAccentColor,
                      statusLabel: '${staffMembers.length} members',
                      stats: <AppFeatureBannerStat>[
                        AppFeatureBannerStat(
                          label: 'Admins',
                          value: staffMembers
                              .where((AppUser member) => member.isAdmin)
                              .length
                              .toString(),
                        ),
                        AppFeatureBannerStat(
                          label: 'Support',
                          value: staffMembers
                              .where(
                                  (AppUser member) => member.isSpecialistStaff)
                              .length
                              .toString(),
                        ),
                        AppFeatureBannerStat(
                          label: 'Wardens',
                          value: staffMembers
                              .where((AppUser member) => member.isWarden)
                              .length
                              .toString(),
                        ),
                      ],
                    ),
                    if (canManageStaff) ...<Widget>[
                      heightSpacer(12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(AppRoutes.createStaff);
                          },
                          icon: const Icon(Icons.person_add_alt_1_rounded),
                          label: const Text('Create Staff'),
                        ),
                      ),
                    ],
                    heightSpacer(10),
                    if (staffMembers.isEmpty)
                      const AppSectionCard(
                        child: AppEmptyState(
                          icon: Icons.groups_outlined,
                          title: 'No staff found',
                          message:
                              'Create a staff account to populate the directory.',
                        ),
                      )
                    else
                      ...staffMembers.map(
                        (AppUser member) => AppSectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  CircleAvatar(
                                    radius: 26.r,
                                    backgroundColor: const Color(0xFFE8F4EC),
                                    child: Text(
                                      '${member.firstName.characters.first}${member.lastName.characters.first}'
                                          .toUpperCase(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: AppColors.kGreenColor,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ),
                                  widthSpacer(12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          member.fullName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        heightSpacer(4),
                                        Text(
                                          member.jobTitle ?? member.accessLabel,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  StatusChip(
                                    label: member.accessLabel,
                                    color: member.isAdmin
                                        ? const Color(0xFF155EEF)
                                        : member.isWarden
                                            ? const Color(0xFFB54708)
                                            : AppColors.kGreenColor,
                                  ),
                                ],
                              ),
                              heightSpacer(18),
                              _DetailRow(
                                  label: 'Username', value: member.username),
                              _DetailRow(label: 'Email', value: member.email),
                              _DetailRow(
                                  label: 'Phone', value: member.phoneNumber),
                              if (canManageStaff &&
                                  !member.isAdmin) ...<Widget>[
                                heightSpacer(12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      _deleteStaff(context, member);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFFB42318),
                                      side: const BorderSide(
                                        color: Color(0x40B42318),
                                      ),
                                      backgroundColor: const Color(0x14B42318),
                                    ),
                                    icon: const Icon(Icons.person_remove_alt_1),
                                    label: const Text('Remove access'),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _deleteStaff(BuildContext context, AppUser member) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete staff account'),
          content: Text(
            'Remove ${member.fullName} from the staff directory and login list?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB42318),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await context.read<AppState>().deleteStaff(member.id);
      if (!context.mounted) {
        return;
      }
      showAppMessage(context, 'Staff account deleted.');
    } on HostelRepositoryException catch (error) {
      if (!context.mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      showAppMessage(context, 'Unable to delete the staff account.',
          isError: true);
    }
  }
}
