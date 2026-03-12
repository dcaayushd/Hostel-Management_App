import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/route_args.dart';
import '../../app/routes.dart';
import '../models/app_notification.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';
import '../state/app_state.dart';

String notificationRouteFor({
  required HostelNotificationItem notification,
  required AppUser? currentUser,
}) {
  switch (notification.resolvedType) {
    case HostelNotificationType.fee:
      return AppRoutes.fees;
    case HostelNotificationType.notice:
      return AppRoutes.notices;
    case HostelNotificationType.chat:
      return AppRoutes.chat;
    case HostelNotificationType.complaint:
      return currentUser?.canWorkOnIssues ?? false
          ? AppRoutes.issues
          : AppRoutes.createIssue;
    case HostelNotificationType.roomChange:
      return AppRoutes.roomChangeRequests;
    case HostelNotificationType.parcel:
      return AppRoutes.parcelDesk;
    case HostelNotificationType.gatePass:
      return AppRoutes.gatePass;
  }
}

Object? notificationArgumentsFor({
  required HostelNotificationItem notification,
  required AppState state,
  required AppUser? currentUser,
}) {
  if (notification.resolvedType != HostelNotificationType.chat ||
      currentUser == null) {
    return null;
  }
  final Set<String> senderLabels = <String>{
    notification.message.split(':').first.trim(),
    notification.title.trim(),
  }..removeWhere(
      (String item) => item.isEmpty || item.toLowerCase() == 'new message',
    );
  if (senderLabels.isEmpty) {
    return null;
  }
  final bool isResident =
      currentUser.role.isStudent || currentUser.role.isGuest;
  final Iterable<AppUser> candidates = isResident
      ? state.staffMembers
      : <AppUser>[...state.students, ...state.guests];
  for (final AppUser candidate in candidates) {
    if (senderLabels.contains(candidate.fullName.trim()) ||
        senderLabels.any(
          (String item) =>
              candidate.fullName.trim().toLowerCase() == item.toLowerCase(),
        )) {
      return ChatRouteArgs(partnerId: candidate.id);
    }
  }
  return null;
}

Future<void> openNotificationDestination(
  BuildContext context,
  HostelNotificationItem notification,
) async {
  final AppState state = context.read<AppState>();
  final AppUser? currentUser = state.currentUser;
  if (!notification.isRead) {
    await state.markNotificationRead(notification.id);
  }
  await state.refreshData();
  if (!context.mounted) {
    return;
  }
  Navigator.of(context).pushNamed(
    notificationRouteFor(
      notification: notification,
      currentUser: currentUser,
    ),
    arguments: notificationArgumentsFor(
      notification: notification,
      state: state,
      currentUser: currentUser,
    ),
  );
}
