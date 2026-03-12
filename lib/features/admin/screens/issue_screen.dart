import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../app/app_chrome.dart';
import '../../../common/app_bar.dart';
import '../../../common/spacing.dart';
import '../../../core/models/app_user.dart';
import '../../../core/models/issue_ticket.dart';
import '../../../core/models/user_role.dart';
import '../../../core/services/hostel_repository.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_screen_background.dart';
import '../../../core/widgets/app_section_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../features/auth/widgets/custom_button.dart';
import '../../../theme/colors.dart';

class IssueScreen extends StatelessWidget {
  const IssueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final AppUser? currentUser = state.currentUser;
    final Brightness brightness = Theme.of(context).brightness;
    final Color mutedText = AppColors.mutedTextFor(brightness);
    final List<IssueTicket> issues = state.visibleIssues;
    final bool canManageIssues = currentUser?.canManageIssues ?? false;
    final bool canWorkOnIssues = currentUser?.canWorkOnIssues ?? false;
    final String screenTitle = canManageIssues
        ? 'Issue Queue'
        : canWorkOnIssues
            ? 'Assigned Issues'
            : 'My Issues';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: buildAppBar(context, screenTitle),
      body: AppScreenBackground(
        child: issues.isEmpty
            ? AppEmptyState(
                icon: Icons.report_gmailerrorred_outlined,
                title: 'No issues found',
                message: canWorkOnIssues &&
                        !(currentUser?.role.isStudent ?? false)
                    ? 'Assigned issue work will appear here when a warden or admin routes tasks to you.'
                    : 'When issues are created they will show up here for review.',
              )
            : RefreshIndicator(
                onRefresh: state.refreshData,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: appPagePadding(
                    context,
                    horizontal: 18,
                    top: 12,
                    bottomExtra: 18,
                  ),
                  itemCount: issues.length,
                  itemBuilder: (BuildContext context, int index) {
                    final IssueTicket issue = issues[index];
                    final AppUser? resident = state.findUser(issue.studentId);
                    final String roomLabel = resident?.roomId == null
                        ? 'No room assigned'
                        : state.findRoom(resident!.roomId!)?.label ??
                            'Unknown room';
                    final bool isResolved = issue.status.isResolved;
                    final AppUser? assignedStaff = issue.assignedStaffId == null
                        ? null
                        : state.findUser(issue.assignedStaffId!);
                    final bool isAssignedToCurrentUser =
                        assignedStaff?.id == currentUser?.id;

                    return AppSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      issue.category,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    heightSpacer(8),
                                    Text(
                                      resident?.fullName ?? 'Unknown resident',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    heightSpacer(4),
                                    Text(
                                      '${resident?.email ?? 'No email'} • $roomLabel',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              StatusChip(
                                label: issue.status.label,
                                color: _statusColor(issue.status),
                              ),
                            ],
                          ),
                          heightSpacer(16),
                          Text(
                            issue.comment,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          heightSpacer(12),
                          Text(
                            AppDateFormatter.short(issue.createdAt),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (assignedStaff != null) ...<Widget>[
                            heightSpacer(10),
                            Text(
                              isAssignedToCurrentUser && !canManageIssues
                                  ? 'You are assigned to this task'
                                  : 'Assigned to ${assignedStaff.fullName}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: mutedText,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                          if (canManageIssues) ...<Widget>[
                            heightSpacer(18),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _assignIssue(
                                      context,
                                      state,
                                      issue.id,
                                    ),
                                    icon: const Icon(Icons.badge_outlined),
                                    label: Text(
                                      assignedStaff == null
                                          ? 'Assign Staff'
                                          : 'Change Assignee',
                                    ),
                                  ),
                                ),
                                widthSpacer(10),
                                Expanded(
                                  child: CustomButton(
                                    buttonText: isResolved
                                        ? 'Reopen Issue'
                                        : 'Mark Resolved',
                                    onTap: () => _updateIssueStatus(
                                      context,
                                      issue.id,
                                      isResolved
                                          ? IssueStatus.open
                                          : IssueStatus.resolved,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else if (isAssignedToCurrentUser) ...<Widget>[
                            heightSpacer(18),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.softSurfaceFor(brightness),
                                      borderRadius: BorderRadius.circular(18.r),
                                      border: Border.all(
                                        color: AppColors.borderFor(brightness),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 14.w,
                                        vertical: 12.h,
                                      ),
                                      child: Text(
                                        'You are assigned to this task',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: mutedText,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                                widthSpacer(10),
                                Expanded(
                                  child: CustomButton(
                                    buttonText: isResolved
                                        ? 'Reopen Issue'
                                        : 'Mark Resolved',
                                    onTap: () => _updateIssueStatus(
                                      context,
                                      issue.id,
                                      isResolved
                                          ? IssueStatus.open
                                          : IssueStatus.resolved,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  Future<void> _assignIssue(
    BuildContext context,
    AppState state,
    String issueId,
  ) async {
    final AppState appState = context.read<AppState>();
    final String? staffId = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        final Brightness brightness = Theme.of(context).brightness;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(brightness),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Assign staff',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryTextFor(brightness),
                        fontWeight: FontWeight.w800,
                      ),
                ),
                heightSpacer(12),
                ...state.staffMembers.map(
                  (AppUser member) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(member.fullName),
                    subtitle: Text(member.jobTitle ?? member.accessLabel),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.of(context).pop(member.id);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (staffId == null) {
      return;
    }
    try {
      await appState.assignIssue(
        issueId: issueId,
        staffId: staffId,
      );
      if (!context.mounted) {
        return;
      }
      final AppUser? staff = state.findUser(staffId);
      showAppMessage(
        context,
        'Assigned to ${staff?.fullName ?? 'staff member'}.',
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
      showAppMessage(context, 'Unable to assign the issue.', isError: true);
    }
  }

  Future<void> _updateIssueStatus(
    BuildContext context,
    String issueId,
    IssueStatus status,
  ) async {
    try {
      await context.read<AppState>().updateIssueStatus(
            issueId: issueId,
            status: status,
          );
      if (!context.mounted) {
        return;
      }
      showAppMessage(
        context,
        status.isResolved ? 'Issue resolved.' : 'Issue reopened.',
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
      showAppMessage(context, 'Unable to update the issue.', isError: true);
    }
  }

  Color _statusColor(IssueStatus status) {
    switch (status) {
      case IssueStatus.open:
        return const Color(0xFFB54708);
      case IssueStatus.inProgress:
        return const Color(0xFF155EEF);
      case IssueStatus.resolved:
        return AppColors.kGreenColor;
    }
  }
}
