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
    final List<RoomChangeRequest> requests = pendingOnly
        ? state.visibleRoomRequests
            .where((RoomChangeRequest request) => request.status.isPending)
            .toList(growable: false)
        : state.visibleRoomRequests;
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
          if (pendingOnly)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.roomChangeRequests);
                },
                icon: const Icon(Icons.view_list_rounded),
                label: const Text('View all requests'),
              ),
            ),
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
