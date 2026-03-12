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
                      desiredRoom?.label ?? 'Unknown destination',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (showResidentMeta) ...<Widget>[
                      heightSpacer(8),
                      Text(
                        resident?.fullName ?? 'Unknown resident',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      heightSpacer(4),
                      Text(
                        resident?.email ?? 'No email available',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              StatusChip(
                label: request.status.label,
                color: _statusColor(request.status),
              ),
            ],
          ),
          heightSpacer(16),
          _DetailRow(
            label: 'From',
            value: fromRoom?.label ?? 'Unknown room',
          ),
          _DetailRow(
            label: 'To',
            value: desiredRoom?.label ?? 'Unknown room',
          ),
          _DetailRow(label: 'Reason', value: request.reason),
          _DetailRow(
            label: 'Requested',
            value: AppDateFormatter.short(request.createdAt),
          ),
          if (request.resolvedAt != null)
            _DetailRow(
              label: 'Updated',
              value: AppDateFormatter.short(request.resolvedAt!),
            ),
          if (canReview && request.status.isPending) ...<Widget>[
            heightSpacer(18),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _updateRequest(
                        context,
                        request.id,
                        RoomRequestStatus.rejected,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB42318),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                widthSpacer(12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      _updateRequest(
                        context,
                        request.id,
                        RoomRequestStatus.approved,
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.kGreenColor,
                    ),
                    child: const Text('Approve'),
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
        return const Color(0xFFB54708);
      case RoomRequestStatus.approved:
        return AppColors.kGreenColor;
      case RoomRequestStatus.rejected:
        return const Color(0xFFB42318);
    }
  }
}
