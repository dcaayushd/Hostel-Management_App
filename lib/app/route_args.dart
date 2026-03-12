class RoomAvailabilityRouteArgs {
  const RoomAvailabilityRouteArgs({
    required this.roomId,
    required this.blockCode,
  });

  final String roomId;
  final String blockCode;
}

class ChatRouteArgs {
  const ChatRouteArgs({
    required this.partnerId,
  });

  final String partnerId;
}

enum FeeScreenFilter {
  allResidents,
  duesOnly,
}

class FeeScreenRouteArgs {
  const FeeScreenRouteArgs({
    required this.filter,
  });

  final FeeScreenFilter filter;
}

enum GatePassScreenFilter {
  pendingOnly,
  activeOnly,
}

enum RoomChangeRequestScreenFilter {
  pendingOnly,
}

class GatePassRouteArgs {
  const GatePassRouteArgs({
    required this.filter,
  });

  final GatePassScreenFilter filter;
}

class RoomChangeRequestRouteArgs {
  const RoomChangeRequestRouteArgs({
    required this.filter,
  });

  final RoomChangeRequestScreenFilter filter;
}
