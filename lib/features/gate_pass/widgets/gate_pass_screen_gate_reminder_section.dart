part of '../screens/gate_pass_screen.dart';

class _GateReminderSection extends StatelessWidget {
  const _GateReminderSection({
    required this.passes,
    required this.state,
  });

  final List<GatePassRequest> passes;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color primaryTextColor = AppColors.primaryTextFor(brightness);
    final Color mutedTextColor = AppColors.mutedTextFor(brightness);
    final List<GatePassRequest> outsideNow = passes
        .where((GatePassRequest item) => item.canMarkReturned)
        .toList(growable: false)
      ..sort(
        (GatePassRequest a, GatePassRequest b) =>
            a.expectedReturnAt.compareTo(b.expectedReturnAt),
      );
    final List<GatePassRequest> recentReturns = passes
        .where((GatePassRequest item) => item.returnedAt != null)
        .toList(growable: false)
      ..sort(
        (GatePassRequest a, GatePassRequest b) =>
            b.returnedAt!.compareTo(a.returnedAt!),
      );

    return AppSectionCard(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Desk reminders',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: primaryTextColor,
                  fontWeight: FontWeight.w800,
                ),
          ),
          heightSpacer(4),
          Text(
            'Keep an eye on residents who are still outside and the latest returns.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: mutedTextColor,
                ),
          ),
          heightSpacer(12),
          if (outsideNow.isEmpty && recentReturns.isEmpty)
            const AppEmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No active reminders',
              message:
                  'Checked-out passes and return confirmations will appear here.',
            )
          else ...<Widget>[
            if (outsideNow.isNotEmpty) ...<Widget>[
              Text(
                'Still outside',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: primaryTextColor,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              heightSpacer(8),
              ...outsideNow.take(3).map(
                    (GatePassRequest item) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: _GateReminderTile(
                        title: state.findUser(item.studentId)?.fullName ??
                            'Unknown',
                        subtitle:
                            '${item.destination} • return by ${_formatDateTime(item.expectedReturnAt)}',
                        badgeLabel: item.isLateNow ? 'Late' : 'Out now',
                        badgeColor: item.isLateNow
                            ? const Color(0xFFD92D20)
                            : const Color(0xFFB54708),
                        icon: item.isLateNow
                            ? Icons.warning_amber_rounded
                            : Icons.logout_rounded,
                      ),
                    ),
                  ),
            ],
            if (outsideNow.isNotEmpty && recentReturns.isNotEmpty)
              heightSpacer(4),
            if (recentReturns.isNotEmpty) ...<Widget>[
              Text(
                'Recent returns',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: primaryTextColor,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              heightSpacer(8),
              ...recentReturns.take(3).map(
                    (GatePassRequest item) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: _GateReminderTile(
                        title: state.findUser(item.studentId)?.fullName ??
                            'Unknown',
                        subtitle:
                            '${item.destination} • returned ${_formatDateTime(item.returnedAt!)}',
                        badgeLabel: item.status == GatePassStatus.late
                            ? 'Returned late'
                            : 'Returned',
                        badgeColor: item.status == GatePassStatus.late
                            ? const Color(0xFFD92D20)
                            : AppColors.kGreenColor,
                        icon: Icons.login_rounded,
                      ),
                    ),
                  ),
            ],
          ],
        ],
      ),
    );
  }
}

class _GateReminderTile extends StatelessWidget {
  const _GateReminderTile({
    required this.title,
    required this.subtitle,
    required this.badgeLabel,
    required this.badgeColor,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String badgeLabel;
  final Color badgeColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.tonalSurfaceFor(brightness),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.outlineFor(brightness)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 34.h,
            width: 34.w,
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: badgeColor,
              size: 18.sp,
            ),
          ),
          widthSpacer(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryTextFor(brightness),
                        fontWeight: FontWeight.w800,
                      ),
                ),
                heightSpacer(2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedTextFor(brightness),
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
          StatusChip(
            label: badgeLabel,
            color: badgeColor,
          ),
        ],
      ),
    );
  }
}
