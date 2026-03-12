part of '../screens/room_change_request_screen.dart';

class _RoomRequestCard extends StatelessWidget {
  const _RoomRequestCard({
    required this.request,
    this.showResidentMeta = false,
  });

  final RoomChangeRequest request;
  final bool showResidentMeta;

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final AppUser? resident = state.findUser(request.studentId);
    final HostelRoom? fromRoom = state.findRoom(request.currentRoomId);
    final HostelRoom? desiredRoom = state.findRoom(request.desiredRoomId);
    final bool canReview = state.currentUser?.canManageRoomRequests ?? false;
    final Brightness brightness = Theme.of(context).brightness;
    final Color primaryTextColor = AppColors.primaryTextFor(brightness);
    final Color mutedTextColor = AppColors.mutedTextFor(brightness);
    final Color statusColor = _statusColor(request.status);
    final String residentInitials = resident == null
        ? '?'
        : '${resident.firstName.characters.first}${resident.lastName.characters.first}'
            .toUpperCase();
    final String title = showResidentMeta
        ? resident?.fullName ?? 'Unknown resident'
        : desiredRoom?.label ?? 'Unknown destination';
    final String subtitle = showResidentMeta
        ? resident?.email ?? 'No email available'
        : desiredRoom?.roomType ?? 'Room move request';

    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 50.h,
                width: 50.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      statusColor.withValues(alpha: 0.24),
                      statusColor.withValues(alpha: 0.12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: AppColors.emphasisBorder(
                      statusColor,
                      brightness,
                      lightAlpha: 0.18,
                      darkAlpha: 0.26,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: showResidentMeta
                    ? Text(
                        residentInitials,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: primaryTextColor,
                                  fontWeight: FontWeight.w800,
                                ),
                      )
                    : Icon(
                        Icons.swap_horiz_rounded,
                        color: AppColors.iconColorFor(
                          brightness,
                          lightColor: statusColor,
                        ),
                      ),
              ),
              widthSpacer(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: primaryTextColor,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    heightSpacer(4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: mutedTextColor,
                          ),
                    ),
                  ],
                ),
              ),
              StatusChip(
                label: request.status.label,
                color: statusColor,
              ),
            ],
          ),
          heightSpacer(16),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.tonalSurfaceFor(brightness),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: AppColors.outlineFor(brightness)),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _RequestRouteStop(
                    label: 'From',
                    value: fromRoom?.label ?? 'Unknown room',
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.iconColorFor(brightness),
                  ),
                ),
                Expanded(
                  child: _RequestRouteStop(
                    label: 'To',
                    value: desiredRoom?.label ?? 'Unknown room',
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ),
          heightSpacer(12),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.softSurfaceFor(brightness),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: AppColors.borderFor(brightness)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Reason',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: mutedTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                heightSpacer(6),
                Text(
                  request.reason,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: primaryTextColor,
                      ),
                ),
              ],
            ),
          ),
          heightSpacer(12),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: <Widget>[
              AppMetaChip(
                icon: Icons.schedule_outlined,
                label: 'Requested ${AppDateFormatter.short(request.createdAt)}',
              ),
              if (request.resolvedAt != null)
                AppMetaChip(
                  icon: Icons.update_rounded,
                  label:
                      'Updated ${AppDateFormatter.short(request.resolvedAt!)}',
                  accentColor: statusColor,
                ),
              if (showResidentMeta && resident != null)
                AppMetaChip(
                  icon: Icons.mail_outline_rounded,
                  label: resident.email,
                ),
            ],
          ),
          if (canReview && request.status.isPending) ...<Widget>[
            heightSpacer(18),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _updateRequest(
                        context,
                        request.id,
                        RoomRequestStatus.rejected,
                      );
                    },
                    style: AppButtonStyles.outlined(
                      brightness,
                      color: AppColors.kDangerColor,
                    ).copyWith(
                      minimumSize: WidgetStatePropertyAll<Size>(Size(0, 52.h)),
                    ),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Reject'),
                  ),
                ),
                widthSpacer(10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      _updateRequest(
                        context,
                        request.id,
                        RoomRequestStatus.approved,
                      );
                    },
                    style: AppButtonStyles.filled(brightness).copyWith(
                      minimumSize: WidgetStatePropertyAll<Size>(Size(0, 52.h)),
                    ),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _updateRequest(
    BuildContext context,
    String requestId,
    RoomRequestStatus status,
  ) async {
    try {
      await context.read<AppState>().updateRoomRequestStatus(
            requestId: requestId,
            status: status,
          );
      if (!context.mounted) {
        return;
      }
      showAppMessage(
        context,
        status == RoomRequestStatus.approved
            ? 'Room request approved.'
            : 'Room request rejected.',
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
      showAppMessage(context, 'Unable to update the request.', isError: true);
    }
  }

  Color _statusColor(RoomRequestStatus status) {
    switch (status) {
      case RoomRequestStatus.pending:
        return AppColors.kWarningColor;
      case RoomRequestStatus.approved:
        return AppColors.kSuccessColor;
      case RoomRequestStatus.rejected:
        return AppColors.kDangerColor;
    }
  }
}

class _RequestRouteStop extends StatelessWidget {
  const _RequestRouteStop({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color primaryTextColor = AppColors.primaryTextFor(brightness);
    final Color mutedTextColor = AppColors.mutedTextFor(brightness);

    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: mutedTextColor,
                fontWeight: FontWeight.w700,
              ),
        ),
        heightSpacer(6),
        Text(
          value,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: primaryTextColor,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}
