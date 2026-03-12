part of '../screens/room_change_request_screen.dart';

class _AdminRoomRequestView extends StatelessWidget {
  const _AdminRoomRequestView({
    required this.state,
    required this.routeArgs,
  });

  final AppState state;
  final RoomChangeRequestRouteArgs? routeArgs;

  @override
  Widget build(BuildContext context) {
    final bool pendingOnly =
        routeArgs?.filter == RoomChangeRequestScreenFilter.pendingOnly;
    final List<RoomChangeRequest> allRequests = state.visibleRoomRequests;
    final List<RoomChangeRequest> requests = pendingOnly
        ? allRequests
            .where((RoomChangeRequest request) => request.status.isPending)
            .toList(growable: false)
        : allRequests;
    final int pendingCount = allRequests
        .where((RoomChangeRequest request) => request.status.isPending)
        .length;
    final int approvedCount = allRequests
        .where(
          (RoomChangeRequest request) =>
              request.status == RoomRequestStatus.approved,
        )
        .length;
    final int rejectedCount = allRequests
        .where(
          (RoomChangeRequest request) =>
              request.status == RoomRequestStatus.rejected,
        )
        .length;
    if (requests.isEmpty) {
      return const AppEmptyState(
        icon: Icons.swap_horiz_outlined,
        title: 'No room requests',
        message: 'Pending and processed room change requests will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: state.refreshData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding:
            appPagePadding(context, horizontal: 18, top: 12, bottomExtra: 18),
        children: <Widget>[
          AppTopInfoCard(
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
                            pendingOnly
                                ? 'Pending room requests'
                                : 'Resident move desk',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          heightSpacer(6),
                          Text(
                            pendingOnly
                                ? 'Review new move requests quickly, then jump back to the full queue when needed.'
                                : 'Monitor every resident move request from one place with live approval status.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.82),
                                ),
                          ),
                        ],
                      ),
                    ),
                    widthSpacer(10),
                    AppTopInfoStatusChip(
                      label: pendingOnly ? 'Pending only' : 'Live queue',
                    ),
                  ],
                ),
                heightSpacer(16),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double spacing = 12.w;
                    final int columns = constraints.maxWidth >= 290.w ? 3 : 2;
                    final double tileWidth =
                        (constraints.maxWidth - (spacing * (columns - 1))) /
                            columns;
                    return Wrap(
                      spacing: spacing,
                      runSpacing: 12.h,
                      children: <Widget>[
                        SizedBox(
                          width: tileWidth,
                          child: AppTopInfoStatTile(
                            label: 'Pending',
                            value: pendingCount.toString(),
                            icon: Icons.hourglass_top_rounded,
                            padding: EdgeInsets.all(14.w),
                            borderRadius: 22,
                            showBorder: true,
                          ),
                        ),
                        SizedBox(
                          width: tileWidth,
                          child: AppTopInfoStatTile(
                            label: 'Approved',
                            value: approvedCount.toString(),
                            icon: Icons.check_circle_outline_rounded,
                            padding: EdgeInsets.all(14.w),
                            borderRadius: 22,
                            showBorder: true,
                          ),
                        ),
                        SizedBox(
                          width: tileWidth,
                          child: AppTopInfoStatTile(
                            label: 'Rejected',
                            value: rejectedCount.toString(),
                            icon: Icons.block_outlined,
                            padding: EdgeInsets.all(14.w),
                            borderRadius: 22,
                            showBorder: true,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                if (pendingOnly) ...<Widget>[
                  heightSpacer(16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.roomChangeRequests);
                      },
                      icon: const Icon(Icons.view_list_rounded),
                      label: const Text('View all requests'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            pendingOnly ? 'Awaiting review' : 'All requests',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          heightSpacer(6),
          Text(
            pendingOnly
                ? 'Approve or reject requests before room assignments drift.'
                : 'Track requested moves, resident context, and final decisions.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedTextFor(Theme.of(context).brightness),
                ),
          ),
          heightSpacer(12),
          ...requests.map(
            (RoomChangeRequest request) => _RoomRequestCard(
              request: request,
              showResidentMeta: true,
            ),
          ),
        ],
      ),
    );
  }
}
