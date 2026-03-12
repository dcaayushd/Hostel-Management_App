import 'dart:convert';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_challenge.dart';
import '../models/admin_catalog.dart';
import '../models/app_user.dart';
import '../models/app_notification.dart';
import '../models/chat_message.dart';
import '../models/fee_charge_item.dart';
import '../models/fee_settings.dart';
import '../models/fee_summary.dart';
import '../models/front_desk_models.dart';
import '../models/gate_pass_models.dart';
import '../models/hostel_block.dart';
import '../models/hostel_room.dart';
import '../models/issue_ticket.dart';
import '../models/laundry_models.dart';
import '../models/mess_models.dart';
import '../models/notice_item.dart';
import '../models/payment_record.dart';
import '../models/room_change_request.dart';
import '../models/setup_status.dart';
import '../models/user_role.dart';
import 'hostel_repository.dart';

class MockHostelRepository implements HostelRepository {
  MockHostelRepository({bool seedDemoData = true}) : _demoMode = seedDemoData {
    _adminCatalog = _defaultAdminCatalog();
    if (seedDemoData) {
      _seedData();
    }
  }

  static const String _persistedAdminKey = 'mock_persisted_admin_v1';
  static const String _persistedWorkspaceKey = 'mock_workspace_state_v2';
  static const FeeChargeItem _kDefaultElectricityCharge = FeeChargeItem(
    label: 'Electricity',
    amount: 500,
  );
  bool _demoMode;
  bool _didRestorePersistedState = false;
  Future<void>? _restorePersistedStateFuture;
  String? _lastPersistedStateSnapshot;

  final List<AppUser> _users = <AppUser>[];
  final List<HostelNotificationItem> _notifications =
      <HostelNotificationItem>[];
  final List<ChatMessage> _chatMessages = <ChatMessage>[];
  final List<HostelBlock> _blocks = <HostelBlock>[];
  final List<HostelRoom> _rooms = <HostelRoom>[];
  final List<IssueTicket> _issues = <IssueTicket>[];
  final List<GatePassRequest> _gatePasses = <GatePassRequest>[];
  final List<ParcelItem> _parcels = <ParcelItem>[];
  final List<VisitorEntry> _visitorEntries = <VisitorEntry>[];
  final List<LaundryBooking> _laundryBookings = <LaundryBooking>[];
  final List<MessMenuDay> _messMenu = <MessMenuDay>[];
  final List<MealAttendanceDay> _mealAttendance = <MealAttendanceDay>[];
  final List<FoodFeedback> _foodFeedback = <FoodFeedback>[];
  final List<NoticeItem> _notices = <NoticeItem>[];
  final List<RoomChangeRequest> _roomRequests = <RoomChangeRequest>[];
  final Map<String, FeeSummary> _feeSummaries = <String, FeeSummary>{};
  final Map<String, List<PaymentRecord>> _paymentHistory =
      <String, List<PaymentRecord>>{};
  final Map<String, AuthChallenge> _authChallenges = <String, AuthChallenge>{};
  late AdminCatalog _adminCatalog;
  FeeSettings _feeSettings = const FeeSettings(
    maintenanceCharge: 1200,
    parkingCharge: 350,
    waterCharge: 550,
    singleOccupancyCharge: 6200,
    doubleSharingCharge: 5000,
    tripleSharingCharge: 4300,
    customCharges: <FeeChargeItem>[
      FeeChargeItem(label: 'Electricity', amount: 500),
      FeeChargeItem(label: 'Wi-Fi', amount: 300),
    ],
  );

  int _userCounter = 3;
  int _notificationCounter = 4;
  int _issueCounter = 2;
  int _gatePassCounter = 3;
  int _parcelCounter = 2;
  int _visitorCounter = 2;
  int _laundryCounter = 2;
  int _feedbackCounter = 2;
  int _noticeCounter = 3;
  int _requestCounter = 1;
  int _paymentCounter = 2;

  static const int _breakfastRate = 90;
  static const int _lunchRate = 140;
  static const int _dinnerRate = 130;

  @override
  Future<SetupStatus> getSetupStatus() {
    return _withDelay(
      () => SetupStatus(
        requiresBootstrap:
            !_users.any((AppUser user) => user.role == UserRole.admin),
        demoMode: _demoMode,
      ),
    );
  }

  @override
  Future<AppUser> login({
    required String identifier,
    required String password,
  }) {
    return _withDelay(() {
      final String normalizedIdentifier = identifier.trim().toLowerCase();
      final bool isPhone = _isPhoneNumber(normalizedIdentifier);
      AppUser? matchedUser;
      for (final AppUser user in _users) {
        final bool matchesIdentity = isPhone
            ? user.phoneNumber == normalizedIdentifier
            : user.email.toLowerCase() == normalizedIdentifier;
        if (matchesIdentity && user.password == password.trim()) {
          matchedUser = user;
          break;
        }
      }
      if (matchedUser == null) {
        throw const HostelRepositoryException('Invalid email or password.');
      }
      return matchedUser;
    });
  }

  @override
  Future<AppUser> bootstrapAdmin({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
  }) {
    return _withDelay(() async {
      if (_users.any((AppUser user) => user.role == UserRole.admin)) {
        throw const HostelRepositoryException(
          'An admin account is already configured.',
        );
      }
      _validatePassword(password);
      _ensureUniqueCredentials(
        email: email,
        username: username,
        phoneNumber: phoneNumber,
      );
      final AppUser user = AppUser(
        id: 'admin_1',
        username: username.trim(),
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        email: email.trim().toLowerCase(),
        password: password.trim(),
        phoneNumber: phoneNumber.trim(),
        role: UserRole.admin,
        jobTitle: 'Hostel Admin',
        emailVerified: true,
        emailVerifiedAt: DateTime.now(),
      );
      _demoMode = false;
      _users.add(user);
      await _persistAdminState();
      return user;
    });
  }

  @override
  Future<AppUser> registerStudent({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
    required String roomId,
  }) {
    return _withDelay(() {
      _validatePassword(password);
      _ensureUniqueCredentials(
        email: email,
        username: username,
        phoneNumber: phoneNumber,
      );
      final HostelRoom room = _requireRoom(roomId);
      if (!room.hasAvailability) {
        throw const HostelRepositoryException(
          'Selected room is already full.',
        );
      }

      final AppUser user = AppUser(
        id: 'student_${++_userCounter}',
        username: username.trim(),
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        email: email.trim().toLowerCase(),
        password: password.trim(),
        phoneNumber: phoneNumber.trim(),
        role: UserRole.student,
        roomId: room.id,
        emailVerified: false,
      );
      _users.add(user);
      _replaceRoom(
        room.copyWith(
          residentIds: <String>[...room.residentIds, user.id],
        ),
      );
      _feeSummaries[user.id] = _defaultFeeForRoom(room);
      return user;
    });
  }

  @override
  Future<AppUser> registerGuest({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
  }) {
    return _withDelay(() {
      _validatePassword(password);
      _ensureUniqueCredentials(
        email: email,
        username: username,
        phoneNumber: phoneNumber,
      );
      final AppUser user = AppUser(
        id: 'guest_${++_userCounter}',
        username: username.trim(),
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        email: email.trim().toLowerCase(),
        password: password.trim(),
        phoneNumber: phoneNumber.trim(),
        role: UserRole.guest,
        emailVerified: false,
      );
      _users.add(user);
      return user;
    });
  }

  @override
  Future<AuthChallenge> requestEmailVerification({
    required String email,
  }) {
    return _withDelay(() {
      final AppUser user = _requireUserByEmail(email);
      if (user.emailVerified) {
        throw const HostelRepositoryException('Email is already verified.');
      }
      final AuthChallenge challenge = _issueAuthChallenge(
        email: user.email,
        purpose: 'verify-email',
      );
      return challenge;
    });
  }

  @override
  Future<AppUser> verifyEmail({
    required String email,
    required String code,
  }) {
    return _withDelay(() async {
      final AppUser user = _requireUserByEmail(email);
      _consumeAuthChallenge(
        email: user.email,
        purpose: 'verify-email',
        code: code,
      );
      final AppUser updatedUser = user.copyWith(
        emailVerified: true,
        emailVerifiedAt: DateTime.now(),
      );
      _replaceUser(updatedUser);
      await _persistAdminStateIfNeeded(updatedUser);
      return updatedUser;
    });
  }

  @override
  Future<AuthChallenge> requestPasswordReset({
    required String email,
  }) {
    return _withDelay(() {
      final AppUser user = _requireUserByEmail(email);
      return _issueAuthChallenge(
        email: user.email,
        purpose: 'password-reset',
      );
    });
  }

  @override
  Future<AppUser> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return _withDelay(() async {
      _validatePassword(newPassword);
      final AppUser user = _requireUserByEmail(email);
      _consumeAuthChallenge(
        email: user.email,
        purpose: 'password-reset',
        code: code,
      );
      final AppUser updatedUser = user.copyWith(
        password: newPassword.trim(),
      );
      _replaceUser(updatedUser);
      await _persistAdminStateIfNeeded(updatedUser);
      return updatedUser;
    });
  }

  @override
  Future<AppUser> getUser(String userId) {
    return _withDelay(() => _requireUser(userId));
  }

  @override
  Future<List<AppUser>> getStudents() {
    return _withDelay(
      () => _users
          .where((AppUser user) => user.role == UserRole.student)
          .toList(growable: false),
    );
  }

  @override
  Future<List<AppUser>> getGuests() {
    return _withDelay(
      () => _users
          .where((AppUser user) => user.role == UserRole.guest)
          .toList(growable: false),
    );
  }

  @override
  Future<List<AppUser>> getStaffMembers() {
    return _withDelay(
      () => _users
          .where(
            (AppUser user) =>
                user.role == UserRole.staff || user.role == UserRole.admin,
          )
          .toList(growable: false),
    );
  }

  @override
  Future<List<ChatMessage>> getChatMessages(String userId) {
    return _withDelay(() {
      final AppUser currentUser = _requireUser(userId);
      final Iterable<ChatMessage> filtered = currentUser.role.isStudent ||
              currentUser.role.isGuest
          ? _chatMessages
              .where((ChatMessage message) => message.involves(userId))
          : _chatMessages.where((ChatMessage message) {
              final AppUser? sender = _findUserOrNull(message.senderId);
              final AppUser? recipient = _findUserOrNull(message.recipientId);
              return (sender?.role.isStudent ?? false) ||
                  (sender?.role.isGuest ?? false) ||
                  (recipient?.role.isGuest ?? false) ||
                  (recipient?.role.isStudent ?? false);
            });
      final List<ChatMessage> messages = filtered.toList(growable: false)
        ..sort((ChatMessage a, ChatMessage b) => a.sentAt.compareTo(b.sentAt));
      return messages;
    });
  }

  @override
  Future<ChatMessage> sendChatMessage({
    required String senderId,
    required String recipientId,
    required String message,
  }) {
    return _withDelay(() {
      final AppUser sender = _requireUser(senderId);
      final AppUser recipient = _requireUser(recipientId);
      final ChatMessage chatMessage = ChatMessage(
        id: 'chat_${DateTime.now().microsecondsSinceEpoch}',
        senderId: sender.id,
        recipientId: recipient.id,
        message: message.trim(),
        sentAt: DateTime.now(),
      );
      _chatMessages.add(chatMessage);
      _pushNotification(
        userId: recipient.id,
        title: 'New message',
        message: '${sender.fullName}: ${chatMessage.message}',
        type: HostelNotificationType.chat,
      );
      return chatMessage;
    });
  }

  @override
  Future<void> markChatThreadRead({
    required String userId,
    required String partnerId,
  }) {
    return _withDelay(() {
      for (int index = 0; index < _chatMessages.length; index += 1) {
        final ChatMessage current = _chatMessages[index];
        if (current.recipientId == userId &&
            current.senderId == partnerId &&
            !current.isRead) {
          _chatMessages[index] = current.copyWith(readAt: DateTime.now());
        }
      }
    });
  }

  @override
  Future<List<HostelNotificationItem>> getNotifications(String userId) {
    return _withDelay(() {
      final List<HostelNotificationItem> items = _notifications
          .where((HostelNotificationItem item) => item.userId == userId)
          .toList(growable: false);
      items.sort(
        (HostelNotificationItem a, HostelNotificationItem b) =>
            b.createdAt.compareTo(a.createdAt),
      );
      return items;
    });
  }

  @override
  Future<HostelNotificationItem> markNotificationRead(String notificationId) {
    return _withDelay(() {
      final int index = _notifications.indexWhere(
        (HostelNotificationItem item) => item.id == notificationId,
      );
      if (index == -1) {
        throw const HostelRepositoryException('Notification not found.');
      }
      final HostelNotificationItem updated = _notifications[index].copyWith(
        readAt: DateTime.now(),
      );
      _notifications[index] = updated;
      return updated;
    });
  }

  @override
  Future<void> markAllNotificationsRead(String userId) {
    return _withDelay(() {
      for (int index = 0; index < _notifications.length; index += 1) {
        final HostelNotificationItem item = _notifications[index];
        if (item.userId != userId || item.isRead) {
          continue;
        }
        _notifications[index] = item.copyWith(readAt: DateTime.now());
      }
    });
  }

  @override
  Future<List<HostelBlock>> getBlocks() {
    return _withDelay(() {
      final List<HostelBlock> blocks = List<HostelBlock>.from(_blocks);
      blocks.sort((HostelBlock a, HostelBlock b) => a.code.compareTo(b.code));
      return blocks;
    });
  }

  @override
  Future<HostelBlock> createBlock({
    required String code,
    required String name,
    String? description,
  }) {
    return _withDelay(() {
      final String normalizedCode = code.trim().toUpperCase();
      if (normalizedCode.isEmpty) {
        throw const HostelRepositoryException('Block code is required.');
      }
      final bool exists = _blocks.any(
        (HostelBlock block) => block.code == normalizedCode,
      );
      if (exists) {
        throw const HostelRepositoryException('That block already exists.');
      }
      final HostelBlock block = HostelBlock(
        code: normalizedCode,
        name: name.trim().isEmpty ? 'Block $normalizedCode' : name.trim(),
        description:
            description?.trim().isEmpty ?? true ? null : description!.trim(),
      );
      _blocks.add(block);
      return block;
    });
  }

  @override
  Future<List<HostelRoom>> getRooms() {
    return _withDelay(() {
      final List<HostelRoom> rooms = List<HostelRoom>.from(_rooms);
      rooms.sort((HostelRoom a, HostelRoom b) {
        final int blockCompare = a.block.compareTo(b.block);
        if (blockCompare != 0) {
          return blockCompare;
        }
        return a.number.compareTo(b.number);
      });
      return rooms;
    });
  }

  @override
  Future<HostelRoom> createRoom({
    required String block,
    required String number,
    required int capacity,
    required String roomType,
  }) {
    return _withDelay(() {
      final String normalizedBlock = block.trim().toUpperCase();
      final String normalizedNumber = number.trim().toUpperCase();
      if (normalizedNumber.isEmpty) {
        throw const HostelRepositoryException('Room number is required.');
      }
      if (capacity < 1) {
        throw const HostelRepositoryException(
          'Room capacity must be at least 1.',
        );
      }
      _ensureBlockExists(normalizedBlock);
      final bool exists = _rooms.any(
        (HostelRoom room) =>
            room.block == normalizedBlock && room.number == normalizedNumber,
      );
      if (exists) {
        throw const HostelRepositoryException(
          'That room already exists in the selected block.',
        );
      }
      final HostelRoom room = HostelRoom(
        id: _buildRoomId(normalizedBlock, normalizedNumber),
        block: normalizedBlock,
        number: normalizedNumber,
        capacity: capacity,
        roomType: roomType.trim(),
        residentIds: const <String>[],
      );
      _rooms.add(room);
      return room;
    });
  }

  @override
  Future<AppUser> assignResidentRoom({
    required String userId,
    required String roomId,
  }) {
    return _withDelay(() {
      final AppUser student = _requireUser(userId);
      if (!student.role.isStudent) {
        throw const HostelRepositoryException(
          'Only student residents can be assigned to rooms.',
        );
      }

      final HostelRoom desiredRoom = _requireRoom(roomId);
      final bool roomChanged = student.roomId != desiredRoom.id;
      if (roomChanged && !desiredRoom.hasAvailability) {
        throw const HostelRepositoryException(
          'Selected room is already full.',
        );
      }

      if (roomChanged && student.roomId != null) {
        final HostelRoom currentRoom = _requireRoom(student.roomId!);
        _replaceRoom(
          currentRoom.copyWith(
            residentIds: currentRoom.residentIds
                .where((String residentId) => residentId != student.id)
                .toList(growable: false),
          ),
        );
      }

      if (roomChanged || !desiredRoom.residentIds.contains(student.id)) {
        _replaceRoom(
          desiredRoom.copyWith(
            residentIds: <String>[
              ...desiredRoom.residentIds
                  .where((String residentId) => residentId != student.id),
              student.id,
            ],
          ),
        );
      }

      final AppUser updatedStudent = student.copyWith(roomId: desiredRoom.id);
      _replaceUser(updatedStudent);
      _feeSummaries[student.id] = _defaultFeeForRoom(
        desiredRoom,
        existing: _feeSummaries[student.id],
      );
      if (roomChanged) {
        _resolvePendingRoomRequestsForResident(
          studentId: student.id,
          assignedRoomId: desiredRoom.id,
        );
      }
      _pushNotification(
        userId: student.id,
        title: roomChanged ? 'Room assignment updated' : 'Room assignment set',
        message: 'Your room assignment is now ${desiredRoom.label}.',
        type: HostelNotificationType.roomChange,
      );
      return updatedStudent;
    });
  }

  @override
  Future<List<IssueTicket>> getIssues() {
    return _withDelay(() {
      final List<IssueTicket> issues = List<IssueTicket>.from(_issues);
      issues.sort(
        (IssueTicket a, IssueTicket b) => b.createdAt.compareTo(a.createdAt),
      );
      return issues;
    });
  }

  @override
  Future<List<GatePassRequest>> getGatePasses() {
    return _withDelay(() {
      final List<GatePassRequest> requests =
          List<GatePassRequest>.from(_gatePasses);
      requests.sort(
        (GatePassRequest a, GatePassRequest b) =>
            b.createdAt.compareTo(a.createdAt),
      );
      return requests;
    });
  }

  @override
  Future<GatePassRequest> createGatePass({
    required String studentId,
    required String destination,
    required String reason,
    required String emergencyContact,
    required DateTime departureAt,
    required DateTime expectedReturnAt,
  }) {
    return _withDelay(() {
      final AppUser student = _requireUser(studentId);
      if (!student.role.isStudent) {
        throw const HostelRepositoryException(
          'Gate passes can only be requested for student accounts.',
        );
      }
      if (!expectedReturnAt.isAfter(departureAt)) {
        throw const HostelRepositoryException(
          'Return time must be after departure time.',
        );
      }

      final GatePassRequest request = GatePassRequest(
        id: 'gatepass_${++_gatePassCounter}',
        studentId: studentId,
        destination: destination.trim(),
        reason: reason.trim(),
        emergencyContact: emergencyContact.trim(),
        passCode: _passCodeFor(DateTime.now(), _gatePassCounter),
        status: GatePassStatus.pending,
        departureAt: departureAt,
        expectedReturnAt: expectedReturnAt,
        createdAt: DateTime.now(),
      );
      _gatePasses.add(request);
      _pushNotification(
        userId: studentId,
        title: 'Gate pass submitted',
        message: 'Your leave request for ${request.destination} is pending.',
        type: HostelNotificationType.gatePass,
      );
      return request;
    });
  }

  @override
  Future<GatePassRequest> reviewGatePass({
    required String gatePassId,
    required GatePassStatus status,
  }) {
    return _withDelay(() {
      if (status != GatePassStatus.approved &&
          status != GatePassStatus.rejected) {
        throw const HostelRepositoryException(
          'Gate pass review must be approved or rejected.',
        );
      }
      final int index = _gatePasses
          .indexWhere((GatePassRequest item) => item.id == gatePassId);
      if (index == -1) {
        throw const HostelRepositoryException('Gate pass not found.');
      }
      final GatePassRequest current = _gatePasses[index];
      if (!current.status.isPending) {
        throw const HostelRepositoryException(
          'Only pending gate passes can be reviewed.',
        );
      }
      final GatePassRequest updated = current.copyWith(
        status: status,
        reviewedAt: DateTime.now(),
      );
      _gatePasses[index] = updated;
      _pushNotification(
        userId: updated.studentId,
        title: 'Gate pass ${status.label.toLowerCase()}',
        message:
            'Your gate pass for ${updated.destination} was ${status.label.toLowerCase()}.',
        type: HostelNotificationType.gatePass,
      );
      return updated;
    });
  }

  @override
  Future<GatePassRequest> markGatePassDeparture(String gatePassId) {
    return _withDelay(() {
      final int index = _gatePasses
          .indexWhere((GatePassRequest item) => item.id == gatePassId);
      if (index == -1) {
        throw const HostelRepositoryException('Gate pass not found.');
      }
      final GatePassRequest current = _gatePasses[index];
      if (!current.canCheckOut) {
        throw const HostelRepositoryException(
          'Only approved gate passes can be checked out.',
        );
      }
      final GatePassRequest updated = current.copyWith(
        status: GatePassStatus.checkedOut,
        checkedOutAt: DateTime.now(),
      );
      _gatePasses[index] = updated;
      _pushNotification(
        userId: updated.studentId,
        title: 'Checked out',
        message: 'Gate exit recorded for ${updated.destination}.',
        type: HostelNotificationType.gatePass,
      );
      return updated;
    });
  }

  @override
  Future<GatePassRequest> markGatePassReturn(String gatePassId) {
    return _withDelay(() {
      final int index = _gatePasses
          .indexWhere((GatePassRequest item) => item.id == gatePassId);
      if (index == -1) {
        throw const HostelRepositoryException('Gate pass not found.');
      }
      final GatePassRequest current = _gatePasses[index];
      if (!current.canMarkReturned) {
        throw const HostelRepositoryException(
          'Only checked out gate passes can be closed.',
        );
      }
      final DateTime now = DateTime.now();
      final GatePassRequest updated = current.copyWith(
        status: now.isAfter(current.expectedReturnAt)
            ? GatePassStatus.late
            : GatePassStatus.returned,
        returnedAt: now,
      );
      _gatePasses[index] = updated;
      _pushNotification(
        userId: updated.studentId,
        title: updated.status == GatePassStatus.late
            ? 'Late entry recorded'
            : 'Return logged',
        message: updated.status == GatePassStatus.late
            ? 'Your return was marked after the approved time.'
            : 'Your gate pass was closed successfully.',
        type: HostelNotificationType.gatePass,
      );
      return updated;
    });
  }

  @override
  Future<List<ParcelItem>> getParcels() {
    return _withDelay(() {
      final List<ParcelItem> parcels = List<ParcelItem>.from(_parcels);
      parcels.sort((ParcelItem a, ParcelItem b) {
        final bool pendingCompare = a.status.isPending != b.status.isPending;
        if (pendingCompare) {
          return a.status.isPending ? -1 : 1;
        }
        return b.createdAt.compareTo(a.createdAt);
      });
      return parcels;
    });
  }

  @override
  Future<ParcelItem> createParcel({
    required String userId,
    required String carrier,
    required String trackingCode,
    required String note,
  }) {
    return _withDelay(() {
      final AppUser user = _requireUser(userId);
      if (!user.role.isStudent) {
        throw const HostelRepositoryException(
          'Parcels can only be recorded for student accounts.',
        );
      }
      final DateTime now = DateTime.now();
      final ParcelItem parcel = ParcelItem(
        id: 'parcel_${++_parcelCounter}',
        userId: userId,
        carrier: carrier.trim(),
        trackingCode: trackingCode.trim(),
        note: note.trim(),
        status: ParcelStatus.awaitingPickup,
        createdAt: now,
        notifiedAt: now,
      );
      _parcels.add(parcel);
      _pushNotification(
        userId: userId,
        title: 'Parcel arrived',
        message: '${parcel.carrier} delivery is ready at the desk.',
        type: HostelNotificationType.parcel,
      );
      return parcel;
    });
  }

  @override
  Future<ParcelItem> markParcelCollected(String parcelId) {
    return _withDelay(() {
      final int index =
          _parcels.indexWhere((ParcelItem item) => item.id == parcelId);
      if (index == -1) {
        throw const HostelRepositoryException('Parcel not found.');
      }
      final ParcelItem updated = _parcels[index].copyWith(
        status: ParcelStatus.collected,
        collectedAt: DateTime.now(),
      );
      _parcels[index] = updated;
      _pushNotification(
        userId: updated.userId,
        title: 'Parcel collected',
        message: 'Your ${updated.carrier} parcel was marked as collected.',
        type: HostelNotificationType.parcel,
      );
      return updated;
    });
  }

  @override
  Future<List<VisitorEntry>> getVisitorEntries() {
    return _withDelay(() {
      final List<VisitorEntry> visitors =
          List<VisitorEntry>.from(_visitorEntries);
      visitors.sort((VisitorEntry a, VisitorEntry b) {
        if (a.isActive != b.isActive) {
          return a.isActive ? -1 : 1;
        }
        return b.checkedInAt.compareTo(a.checkedInAt);
      });
      return visitors;
    });
  }

  @override
  Future<VisitorEntry> createVisitorEntry({
    required String studentId,
    required String visitorName,
    required String relation,
    required String note,
  }) {
    return _withDelay(() {
      final AppUser student = _requireUser(studentId);
      if (!student.role.isStudent) {
        throw const HostelRepositoryException(
          'Visitors can only be logged for student accounts.',
        );
      }
      final VisitorEntry entry = VisitorEntry(
        id: 'visitor_${++_visitorCounter}',
        studentId: studentId,
        visitorName: visitorName.trim(),
        relation: relation.trim(),
        note: note.trim(),
        checkedInAt: DateTime.now(),
      );
      _visitorEntries.add(entry);
      return entry;
    });
  }

  @override
  Future<VisitorEntry> checkOutVisitor(String visitorId) {
    return _withDelay(() {
      final int index = _visitorEntries
          .indexWhere((VisitorEntry entry) => entry.id == visitorId);
      if (index == -1) {
        throw const HostelRepositoryException('Visitor entry not found.');
      }
      final VisitorEntry updated = _visitorEntries[index].copyWith(
        checkedOutAt: DateTime.now(),
      );
      _visitorEntries[index] = updated;
      return updated;
    });
  }

  @override
  Future<List<LaundryBooking>> getLaundryBookings() {
    return _withDelay(() {
      final List<LaundryBooking> bookings =
          List<LaundryBooking>.from(_laundryBookings);
      bookings.sort(
        (LaundryBooking a, LaundryBooking b) =>
            a.scheduledAt.compareTo(b.scheduledAt),
      );
      return bookings;
    });
  }

  @override
  Future<LaundryBooking> createLaundryBooking({
    required String userId,
    required DateTime scheduledAt,
    required String slotLabel,
    required String machineLabel,
    required String notes,
  }) {
    return _withDelay(() {
      final AppUser user = _requireUser(userId);
      if (!user.role.isStudent) {
        throw const HostelRepositoryException(
          'Laundry bookings are available only for student accounts.',
        );
      }
      final String normalizedMachine = machineLabel.trim();
      if (!_adminCatalog.laundryMachines.contains(normalizedMachine)) {
        throw const HostelRepositoryException(
            'Select a valid laundry machine.');
      }

      final bool conflict = _laundryBookings.any(
        (LaundryBooking booking) =>
            booking.status == LaundryBookingStatus.scheduled &&
            booking.machineLabel == normalizedMachine &&
            booking.slotLabel == slotLabel.trim() &&
            booking.scheduledAt.year == scheduledAt.year &&
            booking.scheduledAt.month == scheduledAt.month &&
            booking.scheduledAt.day == scheduledAt.day,
      );
      if (conflict) {
        throw const HostelRepositoryException(
          'That machine is already booked for the selected slot.',
        );
      }

      final LaundryBooking booking = LaundryBooking(
        id: 'laundry_${++_laundryCounter}',
        userId: userId,
        machineLabel: normalizedMachine,
        slotLabel: slotLabel.trim(),
        scheduledAt: scheduledAt,
        notes: notes.trim(),
        status: LaundryBookingStatus.scheduled,
        createdAt: DateTime.now(),
      );
      _laundryBookings.add(booking);
      return booking;
    });
  }

  @override
  Future<LaundryBooking> updateLaundryBookingStatus({
    required String bookingId,
    required LaundryBookingStatus status,
  }) {
    return _withDelay(() {
      final int index = _laundryBookings
          .indexWhere((LaundryBooking booking) => booking.id == bookingId);
      if (index == -1) {
        throw const HostelRepositoryException('Laundry booking not found.');
      }
      final LaundryBooking current = _laundryBookings[index];
      final LaundryBooking updated = current.copyWith(
        status: status,
        completedAt:
            status == LaundryBookingStatus.scheduled ? null : DateTime.now(),
        clearCompletedAt: status == LaundryBookingStatus.scheduled,
      );
      _laundryBookings[index] = updated;
      return updated;
    });
  }

  @override
  Future<List<MessMenuDay>> getMessMenu() {
    return _withDelay(() {
      final List<MessMenuDay> menu = List<MessMenuDay>.from(_messMenu);
      menu.sort((MessMenuDay a, MessMenuDay b) => a.day.index - b.day.index);
      return menu;
    });
  }

  @override
  Future<MessMenuDay> updateMessMenuDay({
    required MessDay day,
    required String breakfast,
    required String lunch,
    required String dinner,
  }) {
    return _withDelay(() {
      final int index =
          _messMenu.indexWhere((MessMenuDay item) => item.day == day);
      final MessMenuDay updated = MessMenuDay(
        day: day,
        breakfast: breakfast.trim(),
        lunch: lunch.trim(),
        dinner: dinner.trim(),
      );
      if (index == -1) {
        _messMenu.add(updated);
      } else {
        _messMenu[index] = updated;
      }
      return updated;
    });
  }

  @override
  Future<List<MealAttendanceDay>> getMealAttendance() {
    return _withDelay(() {
      final List<MealAttendanceDay> attendance = List<MealAttendanceDay>.from(
        _mealAttendance,
      );
      attendance.sort((MealAttendanceDay a, MealAttendanceDay b) {
        final int dateCompare = b.date.compareTo(a.date);
        if (dateCompare != 0) {
          return dateCompare;
        }
        return a.userId.compareTo(b.userId);
      });
      return attendance;
    });
  }

  @override
  Future<MealAttendanceDay> markMealAttendance({
    required String userId,
    required MessDay day,
    required MealType mealType,
    required bool attended,
  }) {
    return _withDelay(() {
      final AppUser user = _requireUser(userId);
      if (!user.role.isStudent) {
        throw const HostelRepositoryException(
          'Only students can update meal attendance.',
        );
      }

      final int index = _mealAttendance.indexWhere(
        (MealAttendanceDay entry) => entry.userId == userId && entry.day == day,
      );
      final MealAttendanceDay current = index == -1
          ? MealAttendanceDay(
              id: 'attendance_${userId}_${day.name}',
              userId: userId,
              day: day,
              date: _dateForDay(day),
              breakfast: false,
              lunch: false,
              dinner: false,
            )
          : _mealAttendance[index];

      late final MealAttendanceDay updated;
      switch (mealType) {
        case MealType.breakfast:
          updated = current.copyWith(breakfast: attended);
          break;
        case MealType.lunch:
          updated = current.copyWith(lunch: attended);
          break;
        case MealType.dinner:
          updated = current.copyWith(dinner: attended);
          break;
      }

      if (index == -1) {
        _mealAttendance.add(updated);
      } else {
        _mealAttendance[index] = updated;
      }
      return updated;
    });
  }

  @override
  Future<List<FoodFeedback>> getFoodFeedback() {
    return _withDelay(() {
      final List<FoodFeedback> feedback =
          List<FoodFeedback>.from(_foodFeedback);
      feedback.sort(
        (FoodFeedback a, FoodFeedback b) =>
            b.submittedAt.compareTo(a.submittedAt),
      );
      return feedback;
    });
  }

  @override
  Future<FoodFeedback> submitFoodFeedback({
    required String userId,
    required int rating,
    required String comment,
  }) {
    return _withDelay(() {
      final AppUser user = _requireUser(userId);
      if (!user.role.isStudent) {
        throw const HostelRepositoryException(
          'Only students can submit mess feedback.',
        );
      }
      if (rating < 1 || rating > 5) {
        throw const HostelRepositoryException(
            'Ratings must be between 1 and 5.');
      }
      final FoodFeedback feedback = FoodFeedback(
        id: 'feedback_${++_feedbackCounter}',
        userId: userId,
        rating: rating,
        comment: comment.trim(),
        submittedAt: DateTime.now(),
      );
      _foodFeedback.add(feedback);
      return feedback;
    });
  }

  @override
  Future<MessBillSummary> getMessBill(String userId) {
    return _withDelay(() {
      final DateTime now = DateTime.now();
      int breakfastCount = 0;
      int lunchCount = 0;
      int dinnerCount = 0;
      for (final MealAttendanceDay entry in _mealAttendance) {
        if (entry.userId != userId ||
            entry.date.year != now.year ||
            entry.date.month != now.month) {
          continue;
        }
        if (entry.breakfast) {
          breakfastCount += 1;
        }
        if (entry.lunch) {
          lunchCount += 1;
        }
        if (entry.dinner) {
          dinnerCount += 1;
        }
      }
      return MessBillSummary(
        monthLabel: _billingMonthLabel(),
        breakfastCount: breakfastCount,
        lunchCount: lunchCount,
        dinnerCount: dinnerCount,
        breakfastRate: _breakfastRate,
        lunchRate: _lunchRate,
        dinnerRate: _dinnerRate,
      );
    });
  }

  @override
  Future<List<NoticeItem>> getNotices() {
    return _withDelay(() {
      final List<NoticeItem> notices = List<NoticeItem>.from(_notices);
      notices.sort((NoticeItem a, NoticeItem b) {
        if (a.isPinned != b.isPinned) {
          return a.isPinned ? -1 : 1;
        }
        return b.postedAt.compareTo(a.postedAt);
      });
      return notices;
    });
  }

  @override
  Future<NoticeItem> createNotice({
    required String title,
    required String message,
    required String category,
    bool isPinned = false,
  }) {
    return _withDelay(() {
      final String normalizedCategory = category.trim();
      if (!_adminCatalog.noticeCategories.contains(normalizedCategory)) {
        throw const HostelRepositoryException(
            'Select a valid notice category.');
      }
      final NoticeItem notice = NoticeItem(
        id: 'notice_${++_noticeCounter}',
        title: title.trim(),
        message: message.trim(),
        category: normalizedCategory,
        postedAt: DateTime.now(),
        isPinned: isPinned,
      );
      _notices.add(notice);
      _broadcastNotification(
        title: notice.title,
        message: notice.message,
        type: HostelNotificationType.notice,
      );
      return notice;
    });
  }

  @override
  Future<IssueTicket> createIssue({
    required String studentId,
    required String category,
    required String comment,
  }) {
    return _withDelay(() {
      final AppUser student = _requireUser(studentId);
      if (!student.role.isStudent) {
        throw const HostelRepositoryException(
          'Only students can create issues.',
        );
      }
      final String normalizedCategory = category.trim();
      if (!_adminCatalog.issueCategories.contains(normalizedCategory)) {
        throw const HostelRepositoryException('Select a valid issue category.');
      }
      final IssueTicket issue = IssueTicket(
        id: 'issue_${++_issueCounter}',
        studentId: studentId,
        category: normalizedCategory,
        comment: comment.trim(),
        status: IssueStatus.open,
        createdAt: DateTime.now(),
      );
      _issues.add(issue);
      _pushNotification(
        userId: studentId,
        title: 'Complaint submitted',
        message: 'Your ${issue.category.toLowerCase()} issue is now in review.',
        type: HostelNotificationType.complaint,
      );
      return issue;
    });
  }

  @override
  Future<IssueTicket> updateIssueStatus({
    required String issueId,
    required IssueStatus status,
  }) {
    return _withDelay(() {
      final int index = _issues.indexWhere(
        (IssueTicket issue) => issue.id == issueId,
      );
      if (index == -1) {
        throw const HostelRepositoryException('Issue not found.');
      }
      final IssueTicket updatedIssue = _issues[index].copyWith(status: status);
      _issues[index] = updatedIssue;
      _pushNotification(
        userId: updatedIssue.studentId,
        title: 'Complaint updated',
        message: 'Issue status changed to ${updatedIssue.status.label}.',
        type: HostelNotificationType.complaint,
      );
      return updatedIssue;
    });
  }

  @override
  Future<IssueTicket> assignIssue({
    required String issueId,
    required String staffId,
  }) {
    return _withDelay(() {
      final int issueIndex = _issues.indexWhere(
        (IssueTicket issue) => issue.id == issueId,
      );
      if (issueIndex == -1) {
        throw const HostelRepositoryException('Issue not found.');
      }
      final AppUser staff = _requireUser(staffId);
      if (!staff.role.isStaff && staff.role != UserRole.admin) {
        throw const HostelRepositoryException(
          'Select a valid staff member for assignment.',
        );
      }
      final IssueTicket updatedIssue = _issues[issueIndex].copyWith(
        assignedStaffId: staffId,
        status: _issues[issueIndex].status == IssueStatus.open
            ? IssueStatus.inProgress
            : null,
      );
      _issues[issueIndex] = updatedIssue;
      _pushNotification(
        userId: updatedIssue.studentId,
        title: 'Complaint assigned',
        message: 'Your complaint is assigned to ${staff.fullName}.',
        type: HostelNotificationType.complaint,
      );
      _pushNotification(
        userId: staff.id,
        title: 'Issue assigned',
        message:
            'You have been assigned the ${updatedIssue.category.toLowerCase()} issue from ${_requireUser(updatedIssue.studentId).fullName}.',
        type: HostelNotificationType.complaint,
      );
      return updatedIssue;
    });
  }

  @override
  Future<AppUser> createStaff({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
    required String jobTitle,
  }) {
    return _withDelay(() {
      _validatePassword(password);
      _ensureUniqueCredentials(
        email: email,
        username: username,
        phoneNumber: phoneNumber,
      );
      final AppUser staff = AppUser(
        id: 'staff_${++_userCounter}',
        username: username.trim(),
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        email: email.trim().toLowerCase(),
        password: password.trim(),
        phoneNumber: phoneNumber.trim(),
        role: UserRole.staff,
        jobTitle: jobTitle.trim(),
        emailVerified: true,
        emailVerifiedAt: DateTime.now(),
      );
      _users.add(staff);
      return staff;
    });
  }

  @override
  Future<void> deleteStaff(String staffId) {
    return _withDelay(() {
      final int index = _users.indexWhere((AppUser user) => user.id == staffId);
      if (index == -1) {
        throw const HostelRepositoryException('Staff member not found.');
      }
      if (_users[index].role == UserRole.admin) {
        throw const HostelRepositoryException('Admins cannot be deleted.');
      }
      _users.removeAt(index);
    });
  }

  @override
  Future<void> prepareCleanWorkspace({
    required String adminId,
  }) {
    return _withDelay(() async {
      final AppUser admin = _requireUser(adminId);
      if (admin.role != UserRole.admin) {
        throw const HostelRepositoryException(
          'Only admin accounts can prepare a clean workspace.',
        );
      }

      _users
        ..clear()
        ..add(
          admin.copyWith(
            roomId: null,
            jobTitle: admin.jobTitle ?? 'Hostel Admin',
            clearRoomId: true,
          ),
        );
      _notifications.clear();
      _chatMessages.clear();
      _blocks.clear();
      _rooms.clear();
      _issues.clear();
      _gatePasses.clear();
      _parcels.clear();
      _visitorEntries.clear();
      _laundryBookings.clear();
      _messMenu.clear();
      _mealAttendance.clear();
      _foodFeedback.clear();
      _notices.clear();
      _roomRequests.clear();
      _feeSummaries.clear();
      _paymentHistory.clear();
      _authChallenges.clear();
      _feeSettings = const FeeSettings(
        maintenanceCharge: 1200,
        parkingCharge: 350,
        waterCharge: 550,
        singleOccupancyCharge: 6200,
        doubleSharingCharge: 5000,
        tripleSharingCharge: 4300,
        customCharges: <FeeChargeItem>[
          FeeChargeItem(label: 'Electricity', amount: 500),
          FeeChargeItem(label: 'Wi-Fi', amount: 300),
        ],
      );
      _adminCatalog = _defaultAdminCatalog();
      _messMenu.addAll(_blankMessMenu());
      _userCounter = 0;
      _notificationCounter = 0;
      _issueCounter = 0;
      _gatePassCounter = 0;
      _parcelCounter = 0;
      _visitorCounter = 0;
      _laundryCounter = 0;
      _feedbackCounter = 0;
      _noticeCounter = 0;
      _requestCounter = 0;
      _paymentCounter = 0;
      _demoMode = false;
      await _persistAdminState();
    });
  }

  @override
  Future<List<RoomChangeRequest>> getRoomChangeRequests() {
    return _withDelay(() {
      final List<RoomChangeRequest> requests =
          List<RoomChangeRequest>.from(_roomRequests);
      requests.sort(
        (RoomChangeRequest a, RoomChangeRequest b) =>
            b.createdAt.compareTo(a.createdAt),
      );
      return requests;
    });
  }

  @override
  Future<RoomChangeRequest> createRoomChangeRequest({
    required String studentId,
    required String desiredRoomId,
    required String reason,
  }) {
    return _withDelay(() {
      final AppUser student = _requireUser(studentId);
      final String? currentRoomId = student.roomId;
      if (!student.role.isStudent || currentRoomId == null) {
        throw const HostelRepositoryException(
          'Only assigned students can create room requests.',
        );
      }

      if (currentRoomId == desiredRoomId) {
        throw const HostelRepositoryException(
          'Choose a room different from your current room.',
        );
      }

      final HostelRoom desiredRoom = _requireRoom(desiredRoomId);
      if (!desiredRoom.hasAvailability) {
        throw const HostelRepositoryException(
          'Desired room is not available.',
        );
      }

      for (final RoomChangeRequest request in _roomRequests) {
        if (request.studentId == studentId && request.status.isPending) {
          throw const HostelRepositoryException(
            'You already have a pending room change request.',
          );
        }
      }

      final RoomChangeRequest request = RoomChangeRequest(
        id: 'request_${++_requestCounter}',
        studentId: studentId,
        currentRoomId: currentRoomId,
        desiredRoomId: desiredRoomId,
        reason: reason.trim(),
        status: RoomRequestStatus.pending,
        createdAt: DateTime.now(),
      );
      _roomRequests.add(request);
      return request;
    });
  }

  @override
  Future<RoomChangeRequest> updateRoomChangeRequestStatus({
    required String requestId,
    required RoomRequestStatus status,
  }) {
    return _withDelay(() {
      final int index = _roomRequests.indexWhere(
        (RoomChangeRequest request) => request.id == requestId,
      );
      if (index == -1) {
        throw const HostelRepositoryException('Request not found.');
      }

      final RoomChangeRequest current = _roomRequests[index];
      if (!current.status.isPending) {
        if (current.status == status) {
          return current;
        }
        throw const HostelRepositoryException(
          'Only pending requests can be updated.',
        );
      }

      if (status == RoomRequestStatus.approved) {
        final AppUser student = _requireUser(current.studentId);
        final String? currentRoomId = student.roomId;
        if (currentRoomId == null) {
          throw const HostelRepositoryException(
            'Student is not assigned to a room.',
          );
        }

        final HostelRoom currentRoom = _requireRoom(currentRoomId);
        final HostelRoom desiredRoom = _requireRoom(current.desiredRoomId);
        if (!desiredRoom.hasAvailability) {
          throw const HostelRepositoryException(
            'Desired room is no longer available.',
          );
        }

        _replaceRoom(
          currentRoom.copyWith(
            residentIds: currentRoom.residentIds
                .where((String residentId) => residentId != student.id)
                .toList(growable: false),
          ),
        );
        _replaceRoom(
          desiredRoom.copyWith(
            residentIds: <String>[...desiredRoom.residentIds, student.id],
          ),
        );

        final AppUser updatedStudent = student.copyWith(roomId: desiredRoom.id);
        _replaceUser(updatedStudent);
        _feeSummaries[student.id] = _defaultFeeForRoom(
          desiredRoom,
          existing: _feeSummaries[student.id],
        );
      }

      final RoomChangeRequest updatedRequest = current.copyWith(
        status: status,
        resolvedAt: DateTime.now(),
      );
      _roomRequests[index] = updatedRequest;
      _pushNotification(
        userId: updatedRequest.studentId,
        title: 'Room request ${status.label.toLowerCase()}',
        message: 'Your room change request was ${status.label.toLowerCase()}.',
        type: HostelNotificationType.roomChange,
      );
      return updatedRequest;
    });
  }

  @override
  Future<FeeSummary> getFeeSummary(String userId) {
    return _withDelay(() {
      return _resolvedFeeSummaryForUser(userId);
    });
  }

  @override
  Future<List<PaymentRecord>> getPaymentHistory(String userId) {
    return _withDelay(() {
      final List<PaymentRecord> records = List<PaymentRecord>.from(
        _paymentHistory[userId] ?? const <PaymentRecord>[],
      );
      records.sort(
        (PaymentRecord a, PaymentRecord b) => b.paidAt.compareTo(a.paidAt),
      );
      return records;
    });
  }

  @override
  Future<PaymentRecord> payFee({
    required String userId,
    required PaymentMethod method,
  }) {
    return _withDelay(() {
      final AppUser user = _requireUser(userId);
      if (!user.role.isStudent) {
        throw const HostelRepositoryException(
          'Only students can complete hostel payments.',
        );
      }

      final FeeSummary summary = _resolvedFeeSummaryForUser(userId);
      if (summary.balance <= 0) {
        throw const HostelRepositoryException('No pending fee balance found.');
      }

      final DateTime paidAt = DateTime.now();
      final PaymentRecord record = PaymentRecord(
        id: 'payment_${++_paymentCounter}',
        userId: userId,
        amount: summary.balance,
        method: method,
        status: PaymentStatus.paid,
        receiptId: _receiptIdFor(paidAt),
        billingMonth: summary.billingMonth,
        paidAt: paidAt,
      );

      _paymentHistory[userId] = <PaymentRecord>[
        record,
        ...?_paymentHistory[userId],
      ];
      _feeSummaries[userId] = summary.copyWith(
        paidAmount: summary.total,
      );
      return record;
    });
  }

  @override
  Future<FeeSummary> sendFeeReminder(String userId) {
    return _withDelay(() {
      final AppUser user = _requireUser(userId);
      if (!user.role.isStudent) {
        throw const HostelRepositoryException(
          'Fee reminders are available only for student accounts.',
        );
      }

      final FeeSummary summary = _resolvedFeeSummaryForUser(userId);
      if (summary.isPaid) {
        throw const HostelRepositoryException(
          'This resident has no pending hostel fees.',
        );
      }

      final FeeSummary updated = summary.copyWith(
        lastReminderAt: DateTime.now(),
      );
      _feeSummaries[userId] = updated;
      _pushNotification(
        userId: userId,
        title: 'Fee reminder',
        message: 'Hostel fees for ${updated.billingMonth} are still pending.',
        type: HostelNotificationType.fee,
      );
      return updated;
    });
  }

  @override
  Future<FeeSettings> getFeeSettings() {
    return _withDelay(() => _feeSettings);
  }

  @override
  Future<FeeSettings> updateFeeSettings({
    required int maintenanceCharge,
    required int parkingCharge,
    required int waterCharge,
    required int singleOccupancyCharge,
    required int doubleSharingCharge,
    required int tripleSharingCharge,
    required List<FeeChargeItem> customCharges,
  }) {
    return _withDelay(() {
      final List<FeeChargeItem> normalizedCustomCharges =
          _withRequiredFeeCharges(customCharges);
      _feeSettings = FeeSettings(
        maintenanceCharge: maintenanceCharge,
        parkingCharge: parkingCharge,
        waterCharge: waterCharge,
        singleOccupancyCharge: singleOccupancyCharge,
        doubleSharingCharge: doubleSharingCharge,
        tripleSharingCharge: tripleSharingCharge,
        customCharges: normalizedCustomCharges,
      );
      _recalculateAllFees();
      return _feeSettings;
    });
  }

  @override
  Future<AdminCatalog> getCatalog() {
    return _withDelay(() => _adminCatalog);
  }

  @override
  Future<AdminCatalog> getAdminCatalog() {
    return _withDelay(() => _adminCatalog);
  }

  @override
  Future<AdminCatalog> updateAdminCatalog(AdminCatalog catalog) {
    return _withDelay(() {
      _adminCatalog = catalog;
      return _adminCatalog;
    });
  }

  Future<T> _withDelay<T>(FutureOr<T> Function() operation) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    await _ensurePersistedStateLoaded();
    final T result = await operation();
    await _persistWorkspaceStateIfChanged();
    return result;
  }

  Future<void> _ensurePersistedStateLoaded() async {
    if (_didRestorePersistedState) {
      return;
    }
    _restorePersistedStateFuture ??= _restorePersistedState();
    await _restorePersistedStateFuture;
  }

  Future<void> _restorePersistedState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? rawWorkspace = prefs.getString(_persistedWorkspaceKey);
    if (rawWorkspace != null) {
      try {
        final Map<String, dynamic> json =
            jsonDecode(rawWorkspace) as Map<String, dynamic>;
        _restoreWorkspaceFromJson(json);
        _syncFeeState();
        _lastPersistedStateSnapshot = _encodedWorkspaceSnapshot();
        _didRestorePersistedState = true;
        return;
      } catch (_) {
        await prefs.remove(_persistedWorkspaceKey);
      }
    }

    final String? rawAdmin = prefs.getString(_persistedAdminKey);
    if (rawAdmin == null) {
      _lastPersistedStateSnapshot = _encodedWorkspaceSnapshot();
      _didRestorePersistedState = true;
      return;
    }

    try {
      final Map<String, dynamic> json =
          jsonDecode(rawAdmin) as Map<String, dynamic>;
      final AppUser restoredAdmin = _appUserFromJson(json);
      if (!_users.any((AppUser user) => user.id == restoredAdmin.id)) {
        _users.add(restoredAdmin);
        _userCounter = _updatedCounterValue(
          current: _userCounter,
          identifier: restoredAdmin.id,
        );
      }
      _demoMode = false;
      _lastPersistedStateSnapshot = _encodedWorkspaceSnapshot();
      await prefs.setString(
        _persistedWorkspaceKey,
        _lastPersistedStateSnapshot!,
      );
    } catch (_) {
      await prefs.remove(_persistedAdminKey);
    } finally {
      _syncFeeState();
      _lastPersistedStateSnapshot ??= _encodedWorkspaceSnapshot();
      _didRestorePersistedState = true;
    }
  }

  Future<void> _persistWorkspaceStateIfChanged() async {
    final String snapshot = _encodedWorkspaceSnapshot();
    if (snapshot == _lastPersistedStateSnapshot) {
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_persistedWorkspaceKey, snapshot);
    _lastPersistedStateSnapshot = snapshot;
  }

  Future<void> _persistAdminStateIfNeeded(AppUser user) async {
    if (user.role != UserRole.admin) {
      return;
    }
    await _persistAdminState();
  }

  Future<void> _persistAdminState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final AppUser? admin = _users
        .where((AppUser user) {
          return user.role == UserRole.admin;
        })
        .cast<AppUser?>()
        .firstWhere(
          (AppUser? user) => user != null,
          orElse: () => null,
        );

    if (admin == null) {
      await prefs.remove(_persistedAdminKey);
      return;
    }

    await prefs.setString(
      _persistedAdminKey,
      jsonEncode(_appUserToJson(admin)),
    );
  }

  Map<String, dynamic> _appUserToJson(AppUser user) {
    return <String, dynamic>{
      'id': user.id,
      'username': user.username,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'email': user.email,
      'password': user.password,
      'phoneNumber': user.phoneNumber,
      'role': user.role.name,
      'roomId': user.roomId,
      'jobTitle': user.jobTitle,
      'emailVerified': user.emailVerified,
      'emailVerifiedAt': user.emailVerifiedAt?.toIso8601String(),
    };
  }

  AppUser _appUserFromJson(Map<String, dynamic> json) {
    final String roleName = json['role'] as String? ?? UserRole.admin.name;
    final UserRole role = UserRole.values.firstWhere(
      (UserRole item) => item.name == roleName,
      orElse: () => UserRole.admin,
    );
    final String? emailVerifiedAtRaw = json['emailVerifiedAt'] as String?;
    return AppUser(
      id: json['id'] as String? ?? 'admin_1',
      username: json['username'] as String? ?? 'admin',
      firstName: json['firstName'] as String? ?? 'Admin',
      lastName: json['lastName'] as String? ?? 'User',
      email: json['email'] as String? ?? 'admin@hostelhub.edu',
      password: json['password'] as String? ?? 'Admin@123',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      role: role,
      roomId: json['roomId'] as String?,
      jobTitle: json['jobTitle'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? true,
      emailVerifiedAt: emailVerifiedAtRaw == null
          ? null
          : DateTime.tryParse(emailVerifiedAtRaw),
    );
  }

  String _encodedWorkspaceSnapshot() {
    return jsonEncode(_workspaceSnapshotToJson());
  }

  Map<String, dynamic> _workspaceSnapshotToJson() {
    return <String, dynamic>{
      'demoMode': _demoMode,
      'users': _users
          .map((AppUser user) => _appUserToJson(user))
          .toList(growable: false),
      'notifications': _notifications
          .map(
            (HostelNotificationItem item) => _notificationToJson(item),
          )
          .toList(growable: false),
      'chatMessages': _chatMessages
          .map((ChatMessage message) => _chatMessageToJson(message))
          .toList(growable: false),
      'blocks': _blocks
          .map((HostelBlock block) => _blockToJson(block))
          .toList(growable: false),
      'rooms': _rooms
          .map((HostelRoom room) => _roomToJson(room))
          .toList(growable: false),
      'issues': _issues
          .map((IssueTicket issue) => _issueToJson(issue))
          .toList(growable: false),
      'gatePasses': _gatePasses
          .map((GatePassRequest request) => _gatePassToJson(request))
          .toList(growable: false),
      'parcels': _parcels
          .map((ParcelItem parcel) => _parcelToJson(parcel))
          .toList(growable: false),
      'visitorEntries': _visitorEntries
          .map((VisitorEntry entry) => _visitorEntryToJson(entry))
          .toList(growable: false),
      'laundryBookings': _laundryBookings
          .map((LaundryBooking booking) => _laundryBookingToJson(booking))
          .toList(growable: false),
      'messMenu': _messMenu
          .map((MessMenuDay day) => _messMenuDayToJson(day))
          .toList(growable: false),
      'mealAttendance': _mealAttendance
          .map((MealAttendanceDay day) => _mealAttendanceToJson(day))
          .toList(growable: false),
      'foodFeedback': _foodFeedback
          .map((FoodFeedback feedback) => _foodFeedbackToJson(feedback))
          .toList(growable: false),
      'notices': _notices
          .map((NoticeItem notice) => _noticeToJson(notice))
          .toList(growable: false),
      'roomRequests': _roomRequests
          .map((RoomChangeRequest request) => _roomRequestToJson(request))
          .toList(growable: false),
      'feeSummaries': _feeSummaries.map(
        (String key, FeeSummary value) =>
            MapEntry<String, dynamic>(key, _feeSummaryToJson(value)),
      ),
      'paymentHistory': _paymentHistory.map(
        (String key, List<PaymentRecord> value) => MapEntry<String, dynamic>(
          key,
          value
              .map((PaymentRecord record) => _paymentRecordToJson(record))
              .toList(growable: false),
        ),
      ),
      'authChallenges': _authChallenges.map(
        (String key, AuthChallenge value) =>
            MapEntry<String, dynamic>(key, _authChallengeToJson(value)),
      ),
      'adminCatalog': _adminCatalog.toJson(),
      'feeSettings': _feeSettingsToJson(_feeSettings),
      'counters': <String, int>{
        'user': _userCounter,
        'notification': _notificationCounter,
        'issue': _issueCounter,
        'gatePass': _gatePassCounter,
        'parcel': _parcelCounter,
        'visitor': _visitorCounter,
        'laundry': _laundryCounter,
        'feedback': _feedbackCounter,
        'notice': _noticeCounter,
        'request': _requestCounter,
        'payment': _paymentCounter,
      },
    };
  }

  void _restoreWorkspaceFromJson(Map<String, dynamic> json) {
    _users
      ..clear()
      ..addAll(_decodeList(json['users'], _appUserFromJson));
    _notifications
      ..clear()
      ..addAll(_decodeList(json['notifications'], _notificationFromJson));
    _chatMessages
      ..clear()
      ..addAll(_decodeList(json['chatMessages'], _chatMessageFromJson));
    _blocks
      ..clear()
      ..addAll(_decodeList(json['blocks'], _blockFromJson));
    _rooms
      ..clear()
      ..addAll(_decodeList(json['rooms'], _roomFromJson));
    _issues
      ..clear()
      ..addAll(_decodeList(json['issues'], _issueFromJson));
    _gatePasses
      ..clear()
      ..addAll(_decodeList(json['gatePasses'], _gatePassFromJson));
    _parcels
      ..clear()
      ..addAll(_decodeList(json['parcels'], _parcelFromJson));
    _visitorEntries
      ..clear()
      ..addAll(_decodeList(json['visitorEntries'], _visitorEntryFromJson));
    _laundryBookings
      ..clear()
      ..addAll(_decodeList(json['laundryBookings'], _laundryBookingFromJson));
    _messMenu
      ..clear()
      ..addAll(_decodeList(json['messMenu'], _messMenuDayFromJson));
    _mealAttendance
      ..clear()
      ..addAll(_decodeList(json['mealAttendance'], _mealAttendanceFromJson));
    _foodFeedback
      ..clear()
      ..addAll(_decodeList(json['foodFeedback'], _foodFeedbackFromJson));
    _notices
      ..clear()
      ..addAll(_decodeList(json['notices'], _noticeFromJson));
    _roomRequests
      ..clear()
      ..addAll(_decodeList(json['roomRequests'], _roomRequestFromJson));
    _feeSummaries
      ..clear()
      ..addAll(_decodeMap(json['feeSummaries'], _feeSummaryFromJson));
    _paymentHistory
      ..clear()
      ..addAll(
        _decodeNestedListMap(
          json['paymentHistory'],
          _paymentRecordFromJson,
        ),
      );
    _authChallenges
      ..clear()
      ..addAll(_decodeMap(json['authChallenges'], _authChallengeFromJson));

    final Map<String, dynamic> adminCatalogJson =
        _asJsonMap(json['adminCatalog']);
    if (adminCatalogJson.isNotEmpty) {
      _adminCatalog = AdminCatalog.fromJson(adminCatalogJson);
    }

    final Map<String, dynamic> feeSettingsJson =
        _asJsonMap(json['feeSettings']);
    if (feeSettingsJson.isNotEmpty) {
      _feeSettings = _feeSettingsFromJson(feeSettingsJson);
    }
    _demoMode = json['demoMode'] as bool? ?? _demoMode;

    final Map<String, dynamic> counters = _asJsonMap(json['counters']);
    _userCounter = (counters['user'] as num?)?.toInt() ?? _userCounter;
    _notificationCounter =
        (counters['notification'] as num?)?.toInt() ?? _notificationCounter;
    _issueCounter = (counters['issue'] as num?)?.toInt() ?? _issueCounter;
    _gatePassCounter =
        (counters['gatePass'] as num?)?.toInt() ?? _gatePassCounter;
    _parcelCounter = (counters['parcel'] as num?)?.toInt() ?? _parcelCounter;
    _visitorCounter = (counters['visitor'] as num?)?.toInt() ?? _visitorCounter;
    _laundryCounter = (counters['laundry'] as num?)?.toInt() ?? _laundryCounter;
    _feedbackCounter =
        (counters['feedback'] as num?)?.toInt() ?? _feedbackCounter;
    _noticeCounter = (counters['notice'] as num?)?.toInt() ?? _noticeCounter;
    _requestCounter = (counters['request'] as num?)?.toInt() ?? _requestCounter;
    _paymentCounter = (counters['payment'] as num?)?.toInt() ?? _paymentCounter;
  }

  List<T> _decodeList<T>(
    dynamic raw,
    T Function(Map<String, dynamic> json) decoder,
  ) {
    if (raw is! List<dynamic>) {
      return <T>[];
    }
    return raw
        .map((dynamic item) => decoder(_asJsonMap(item)))
        .toList(growable: true);
  }

  Map<String, T> _decodeMap<T>(
    dynamic raw,
    T Function(Map<String, dynamic> json) decoder,
  ) {
    final Map<String, dynamic> json = _asJsonMap(raw);
    return json.map(
      (String key, dynamic value) =>
          MapEntry<String, T>(key, decoder(_asJsonMap(value))),
    );
  }

  Map<String, List<T>> _decodeNestedListMap<T>(
    dynamic raw,
    T Function(Map<String, dynamic> json) decoder,
  ) {
    final Map<String, dynamic> json = _asJsonMap(raw);
    return json.map((String key, dynamic value) {
      if (value is! List<dynamic>) {
        return MapEntry<String, List<T>>(key, <T>[]);
      }
      return MapEntry<String, List<T>>(
        key,
        value
            .map((dynamic item) => decoder(_asJsonMap(item)))
            .toList(growable: true),
      );
    });
  }

  Map<String, dynamic> _asJsonMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return raw.map(
        (dynamic key, dynamic value) => MapEntry(key.toString(), value),
      );
    }
    return <String, dynamic>{};
  }

  String? _stringOrNull(dynamic raw) {
    return raw is String ? raw : null;
  }

  DateTime? _dateTimeOrNull(dynamic raw) {
    final String? value = _stringOrNull(raw);
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  Map<String, dynamic> _notificationToJson(HostelNotificationItem item) {
    return <String, dynamic>{
      'id': item.id,
      'userId': item.userId,
      'title': item.title,
      'message': item.message,
      'type': item.type.name,
      'createdAt': item.createdAt.toIso8601String(),
      'readAt': item.readAt?.toIso8601String(),
    };
  }

  HostelNotificationItem _notificationFromJson(Map<String, dynamic> json) {
    return HostelNotificationItem(
      id: _stringOrNull(json['id']) ?? '',
      userId: _stringOrNull(json['userId']) ?? '',
      title: _stringOrNull(json['title']) ?? '',
      message: _stringOrNull(json['message']) ?? '',
      type: HostelNotificationType.values.byName(
        _stringOrNull(json['type']) ?? HostelNotificationType.notice.name,
      ),
      createdAt: _dateTimeOrNull(json['createdAt']) ?? DateTime.now(),
      readAt: _dateTimeOrNull(json['readAt']),
    );
  }

  Map<String, dynamic> _chatMessageToJson(ChatMessage message) {
    return <String, dynamic>{
      'id': message.id,
      'senderId': message.senderId,
      'recipientId': message.recipientId,
      'message': message.message,
      'sentAt': message.sentAt.toIso8601String(),
      'readAt': message.readAt?.toIso8601String(),
    };
  }

  ChatMessage _chatMessageFromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: _stringOrNull(json['id']) ?? '',
      senderId: _stringOrNull(json['senderId']) ?? '',
      recipientId: _stringOrNull(json['recipientId']) ?? '',
      message: _stringOrNull(json['message']) ?? '',
      sentAt: _dateTimeOrNull(json['sentAt']) ?? DateTime.now(),
      readAt: _dateTimeOrNull(json['readAt']),
    );
  }

  Map<String, dynamic> _blockToJson(HostelBlock block) {
    return <String, dynamic>{
      'code': block.code,
      'name': block.name,
      'description': block.description,
    };
  }

  HostelBlock _blockFromJson(Map<String, dynamic> json) {
    return HostelBlock(
      code: _stringOrNull(json['code']) ?? '',
      name: _stringOrNull(json['name']) ?? '',
      description: _stringOrNull(json['description']),
    );
  }

  Map<String, dynamic> _roomToJson(HostelRoom room) {
    return <String, dynamic>{
      'id': room.id,
      'block': room.block,
      'number': room.number,
      'capacity': room.capacity,
      'roomType': room.roomType,
      'residentIds': room.residentIds,
    };
  }

  HostelRoom _roomFromJson(Map<String, dynamic> json) {
    return HostelRoom(
      id: _stringOrNull(json['id']) ?? '',
      block: _stringOrNull(json['block']) ?? '',
      number: _stringOrNull(json['number']) ?? '',
      capacity: (json['capacity'] as num?)?.toInt() ?? 1,
      roomType: _stringOrNull(json['roomType']) ?? 'Double Sharing',
      residentIds: ((json['residentIds'] as List<dynamic>?) ?? <dynamic>[])
          .whereType<String>()
          .toList(growable: true),
    );
  }

  Map<String, dynamic> _issueToJson(IssueTicket issue) {
    return <String, dynamic>{
      'id': issue.id,
      'studentId': issue.studentId,
      'category': issue.category,
      'comment': issue.comment,
      'status': issue.status.name,
      'createdAt': issue.createdAt.toIso8601String(),
      'assignedStaffId': issue.assignedStaffId,
    };
  }

  IssueTicket _issueFromJson(Map<String, dynamic> json) {
    return IssueTicket(
      id: _stringOrNull(json['id']) ?? '',
      studentId: _stringOrNull(json['studentId']) ?? '',
      category: _stringOrNull(json['category']) ?? '',
      comment: _stringOrNull(json['comment']) ?? '',
      status: IssueStatus.values.byName(
        _stringOrNull(json['status']) ?? IssueStatus.open.name,
      ),
      createdAt: _dateTimeOrNull(json['createdAt']) ?? DateTime.now(),
      assignedStaffId: _stringOrNull(json['assignedStaffId']),
    );
  }

  Map<String, dynamic> _gatePassToJson(GatePassRequest request) {
    return <String, dynamic>{
      'id': request.id,
      'studentId': request.studentId,
      'destination': request.destination,
      'reason': request.reason,
      'emergencyContact': request.emergencyContact,
      'passCode': request.passCode,
      'status': request.status.name,
      'departureAt': request.departureAt.toIso8601String(),
      'expectedReturnAt': request.expectedReturnAt.toIso8601String(),
      'createdAt': request.createdAt.toIso8601String(),
      'reviewedAt': request.reviewedAt?.toIso8601String(),
      'checkedOutAt': request.checkedOutAt?.toIso8601String(),
      'returnedAt': request.returnedAt?.toIso8601String(),
    };
  }

  GatePassRequest _gatePassFromJson(Map<String, dynamic> json) {
    return GatePassRequest(
      id: _stringOrNull(json['id']) ?? '',
      studentId: _stringOrNull(json['studentId']) ?? '',
      destination: _stringOrNull(json['destination']) ?? '',
      reason: _stringOrNull(json['reason']) ?? '',
      emergencyContact: _stringOrNull(json['emergencyContact']) ?? '',
      passCode: _stringOrNull(json['passCode']) ?? '',
      status: GatePassStatus.values.byName(
        _stringOrNull(json['status']) ?? GatePassStatus.pending.name,
      ),
      departureAt: _dateTimeOrNull(json['departureAt']) ?? DateTime.now(),
      expectedReturnAt:
          _dateTimeOrNull(json['expectedReturnAt']) ?? DateTime.now(),
      createdAt: _dateTimeOrNull(json['createdAt']) ?? DateTime.now(),
      reviewedAt: _dateTimeOrNull(json['reviewedAt']),
      checkedOutAt: _dateTimeOrNull(json['checkedOutAt']),
      returnedAt: _dateTimeOrNull(json['returnedAt']),
    );
  }

  Map<String, dynamic> _parcelToJson(ParcelItem parcel) {
    return <String, dynamic>{
      'id': parcel.id,
      'userId': parcel.userId,
      'carrier': parcel.carrier,
      'trackingCode': parcel.trackingCode,
      'note': parcel.note,
      'status': parcel.status.name,
      'createdAt': parcel.createdAt.toIso8601String(),
      'notifiedAt': parcel.notifiedAt?.toIso8601String(),
      'collectedAt': parcel.collectedAt?.toIso8601String(),
    };
  }

  ParcelItem _parcelFromJson(Map<String, dynamic> json) {
    return ParcelItem(
      id: _stringOrNull(json['id']) ?? '',
      userId: _stringOrNull(json['userId']) ?? '',
      carrier: _stringOrNull(json['carrier']) ?? '',
      trackingCode: _stringOrNull(json['trackingCode']) ?? '',
      note: _stringOrNull(json['note']) ?? '',
      status: ParcelStatus.values.byName(
        _stringOrNull(json['status']) ?? ParcelStatus.awaitingPickup.name,
      ),
      createdAt: _dateTimeOrNull(json['createdAt']) ?? DateTime.now(),
      notifiedAt: _dateTimeOrNull(json['notifiedAt']),
      collectedAt: _dateTimeOrNull(json['collectedAt']),
    );
  }

  Map<String, dynamic> _visitorEntryToJson(VisitorEntry entry) {
    return <String, dynamic>{
      'id': entry.id,
      'studentId': entry.studentId,
      'visitorName': entry.visitorName,
      'relation': entry.relation,
      'note': entry.note,
      'checkedInAt': entry.checkedInAt.toIso8601String(),
      'checkedOutAt': entry.checkedOutAt?.toIso8601String(),
    };
  }

  VisitorEntry _visitorEntryFromJson(Map<String, dynamic> json) {
    return VisitorEntry(
      id: _stringOrNull(json['id']) ?? '',
      studentId: _stringOrNull(json['studentId']) ?? '',
      visitorName: _stringOrNull(json['visitorName']) ?? '',
      relation: _stringOrNull(json['relation']) ?? '',
      note: _stringOrNull(json['note']) ?? '',
      checkedInAt: _dateTimeOrNull(json['checkedInAt']) ?? DateTime.now(),
      checkedOutAt: _dateTimeOrNull(json['checkedOutAt']),
    );
  }

  Map<String, dynamic> _laundryBookingToJson(LaundryBooking booking) {
    return <String, dynamic>{
      'id': booking.id,
      'userId': booking.userId,
      'machineLabel': booking.machineLabel,
      'slotLabel': booking.slotLabel,
      'scheduledAt': booking.scheduledAt.toIso8601String(),
      'notes': booking.notes,
      'status': booking.status.name,
      'createdAt': booking.createdAt.toIso8601String(),
      'completedAt': booking.completedAt?.toIso8601String(),
    };
  }

  LaundryBooking _laundryBookingFromJson(Map<String, dynamic> json) {
    return LaundryBooking(
      id: _stringOrNull(json['id']) ?? '',
      userId: _stringOrNull(json['userId']) ?? '',
      machineLabel: _stringOrNull(json['machineLabel']) ?? '',
      slotLabel: _stringOrNull(json['slotLabel']) ?? '',
      scheduledAt: _dateTimeOrNull(json['scheduledAt']) ?? DateTime.now(),
      notes: _stringOrNull(json['notes']) ?? '',
      status: LaundryBookingStatus.values.byName(
        _stringOrNull(json['status']) ?? LaundryBookingStatus.scheduled.name,
      ),
      createdAt: _dateTimeOrNull(json['createdAt']) ?? DateTime.now(),
      completedAt: _dateTimeOrNull(json['completedAt']),
    );
  }

  Map<String, dynamic> _messMenuDayToJson(MessMenuDay day) {
    return <String, dynamic>{
      'day': day.day.name,
      'breakfast': day.breakfast,
      'lunch': day.lunch,
      'dinner': day.dinner,
    };
  }

  MessMenuDay _messMenuDayFromJson(Map<String, dynamic> json) {
    return MessMenuDay(
      day: MessDay.values.byName(
        _stringOrNull(json['day']) ?? MessDay.monday.name,
      ),
      breakfast: _stringOrNull(json['breakfast']) ?? '',
      lunch: _stringOrNull(json['lunch']) ?? '',
      dinner: _stringOrNull(json['dinner']) ?? '',
    );
  }

  Map<String, dynamic> _mealAttendanceToJson(MealAttendanceDay day) {
    return <String, dynamic>{
      'id': day.id,
      'userId': day.userId,
      'day': day.day.name,
      'date': day.date.toIso8601String(),
      'breakfast': day.breakfast,
      'lunch': day.lunch,
      'dinner': day.dinner,
    };
  }

  MealAttendanceDay _mealAttendanceFromJson(Map<String, dynamic> json) {
    return MealAttendanceDay(
      id: _stringOrNull(json['id']) ?? '',
      userId: _stringOrNull(json['userId']) ?? '',
      day: MessDay.values.byName(
        _stringOrNull(json['day']) ?? MessDay.monday.name,
      ),
      date: _dateTimeOrNull(json['date']) ?? DateTime.now(),
      breakfast: json['breakfast'] as bool? ?? false,
      lunch: json['lunch'] as bool? ?? false,
      dinner: json['dinner'] as bool? ?? false,
    );
  }

  Map<String, dynamic> _foodFeedbackToJson(FoodFeedback feedback) {
    return <String, dynamic>{
      'id': feedback.id,
      'userId': feedback.userId,
      'rating': feedback.rating,
      'comment': feedback.comment,
      'submittedAt': feedback.submittedAt.toIso8601String(),
    };
  }

  FoodFeedback _foodFeedbackFromJson(Map<String, dynamic> json) {
    return FoodFeedback(
      id: _stringOrNull(json['id']) ?? '',
      userId: _stringOrNull(json['userId']) ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: _stringOrNull(json['comment']) ?? '',
      submittedAt: _dateTimeOrNull(json['submittedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _noticeToJson(NoticeItem notice) {
    return <String, dynamic>{
      'id': notice.id,
      'title': notice.title,
      'message': notice.message,
      'category': notice.category,
      'postedAt': notice.postedAt.toIso8601String(),
      'isPinned': notice.isPinned,
    };
  }

  NoticeItem _noticeFromJson(Map<String, dynamic> json) {
    return NoticeItem(
      id: _stringOrNull(json['id']) ?? '',
      title: _stringOrNull(json['title']) ?? '',
      message: _stringOrNull(json['message']) ?? '',
      category: _stringOrNull(json['category']) ?? '',
      postedAt: _dateTimeOrNull(json['postedAt']) ?? DateTime.now(),
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }

  Map<String, dynamic> _roomRequestToJson(RoomChangeRequest request) {
    return <String, dynamic>{
      'id': request.id,
      'studentId': request.studentId,
      'currentRoomId': request.currentRoomId,
      'desiredRoomId': request.desiredRoomId,
      'reason': request.reason,
      'status': request.status.name,
      'createdAt': request.createdAt.toIso8601String(),
      'resolvedAt': request.resolvedAt?.toIso8601String(),
    };
  }

  RoomChangeRequest _roomRequestFromJson(Map<String, dynamic> json) {
    return RoomChangeRequest(
      id: _stringOrNull(json['id']) ?? '',
      studentId: _stringOrNull(json['studentId']) ?? '',
      currentRoomId: _stringOrNull(json['currentRoomId']) ?? '',
      desiredRoomId: _stringOrNull(json['desiredRoomId']) ?? '',
      reason: _stringOrNull(json['reason']) ?? '',
      status: RoomRequestStatus.values.byName(
        _stringOrNull(json['status']) ?? RoomRequestStatus.pending.name,
      ),
      createdAt: _dateTimeOrNull(json['createdAt']) ?? DateTime.now(),
      resolvedAt: _dateTimeOrNull(json['resolvedAt']),
    );
  }

  Map<String, dynamic> _feeSummaryToJson(FeeSummary summary) {
    return <String, dynamic>{
      'maintenanceCharge': summary.maintenanceCharge,
      'parkingCharge': summary.parkingCharge,
      'waterCharge': summary.waterCharge,
      'roomCharge': summary.roomCharge,
      'additionalCharges': summary.additionalCharges
          .map((FeeChargeItem item) => item.toJson())
          .toList(growable: false),
      'billingMonth': summary.billingMonth,
      'paidAmount': summary.paidAmount,
      'dueDate': summary.dueDate?.toIso8601String(),
      'lastReminderAt': summary.lastReminderAt?.toIso8601String(),
    };
  }

  FeeSummary _feeSummaryFromJson(Map<String, dynamic> json) {
    final List<dynamic> rawAdditionalCharges =
        json['additionalCharges'] as List<dynamic>? ?? <dynamic>[];
    return FeeSummary(
      maintenanceCharge: (json['maintenanceCharge'] as num?)?.toInt() ?? 0,
      parkingCharge: (json['parkingCharge'] as num?)?.toInt() ?? 0,
      waterCharge: (json['waterCharge'] as num?)?.toInt() ?? 0,
      roomCharge: (json['roomCharge'] as num?)?.toInt() ?? 0,
      additionalCharges: rawAdditionalCharges
          .map((dynamic item) => FeeChargeItem.fromJson(_asJsonMap(item)))
          .toList(growable: false),
      billingMonth: _stringOrNull(json['billingMonth']) ?? 'Current cycle',
      paidAmount: (json['paidAmount'] as num?)?.toInt() ?? 0,
      dueDate: _dateTimeOrNull(json['dueDate']),
      lastReminderAt: _dateTimeOrNull(json['lastReminderAt']),
    );
  }

  Map<String, dynamic> _paymentRecordToJson(PaymentRecord record) {
    return <String, dynamic>{
      'id': record.id,
      'userId': record.userId,
      'amount': record.amount,
      'method': record.method.name,
      'status': record.status.name,
      'receiptId': record.receiptId,
      'billingMonth': record.billingMonth,
      'paidAt': record.paidAt.toIso8601String(),
    };
  }

  PaymentRecord _paymentRecordFromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: _stringOrNull(json['id']) ?? '',
      userId: _stringOrNull(json['userId']) ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      method: PaymentMethod.values.byName(
        _stringOrNull(json['method']) ?? PaymentMethod.cash.name,
      ),
      status: PaymentStatus.values.byName(
        _stringOrNull(json['status']) ?? PaymentStatus.paid.name,
      ),
      receiptId: _stringOrNull(json['receiptId']) ?? '',
      billingMonth: _stringOrNull(json['billingMonth']) ?? 'Current cycle',
      paidAt: _dateTimeOrNull(json['paidAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _authChallengeToJson(AuthChallenge challenge) {
    return <String, dynamic>{
      'email': challenge.email,
      'code': challenge.code,
      'expiresAt': challenge.expiresAt.toIso8601String(),
      'deliveryMethod': challenge.deliveryMethod.name,
    };
  }

  AuthChallenge _authChallengeFromJson(Map<String, dynamic> json) {
    return AuthChallenge(
      email: _stringOrNull(json['email']) ?? '',
      code: _stringOrNull(json['code']) ?? '',
      expiresAt: _dateTimeOrNull(json['expiresAt']) ?? DateTime.now(),
      deliveryMethod: AuthChallengeDeliveryMethod.values.byName(
        _stringOrNull(json['deliveryMethod']) ?? 'local',
      ),
    );
  }

  Map<String, dynamic> _feeSettingsToJson(FeeSettings settings) {
    return <String, dynamic>{
      'maintenanceCharge': settings.maintenanceCharge,
      'parkingCharge': settings.parkingCharge,
      'waterCharge': settings.waterCharge,
      'singleOccupancyCharge': settings.singleOccupancyCharge,
      'doubleSharingCharge': settings.doubleSharingCharge,
      'tripleSharingCharge': settings.tripleSharingCharge,
      'customCharges': settings.customCharges
          .map((FeeChargeItem item) => item.toJson())
          .toList(growable: false),
    };
  }

  FeeSettings _feeSettingsFromJson(Map<String, dynamic> json) {
    final List<dynamic> rawCustomCharges =
        json['customCharges'] as List<dynamic>? ?? <dynamic>[];
    return FeeSettings(
      maintenanceCharge: (json['maintenanceCharge'] as num?)?.toInt() ?? 1200,
      parkingCharge: (json['parkingCharge'] as num?)?.toInt() ?? 350,
      waterCharge: (json['waterCharge'] as num?)?.toInt() ?? 550,
      singleOccupancyCharge:
          (json['singleOccupancyCharge'] as num?)?.toInt() ?? 6200,
      doubleSharingCharge:
          (json['doubleSharingCharge'] as num?)?.toInt() ?? 5000,
      tripleSharingCharge:
          (json['tripleSharingCharge'] as num?)?.toInt() ?? 4300,
      customCharges: _withRequiredFeeCharges(
        rawCustomCharges.map(
          (dynamic item) => FeeChargeItem.fromJson(_asJsonMap(item)),
        ),
      ),
    );
  }

  List<FeeChargeItem> _withRequiredFeeCharges(
    Iterable<FeeChargeItem> items,
  ) {
    final List<FeeChargeItem> normalized = <FeeChargeItem>[];
    final Set<String> seen = <String>{};
    bool hasElectricity = false;
    for (final FeeChargeItem item in items) {
      final String trimmedLabel = item.label.trim();
      if (trimmedLabel.isEmpty) {
        continue;
      }
      final String lowered = trimmedLabel.toLowerCase();
      if (!seen.add(lowered)) {
        continue;
      }
      if (lowered == _kDefaultElectricityCharge.label.toLowerCase()) {
        hasElectricity = true;
        normalized.add(item.copyWith(label: _kDefaultElectricityCharge.label));
        continue;
      }
      normalized.add(item.copyWith(label: trimmedLabel));
    }
    if (!hasElectricity) {
      normalized.insert(0, _kDefaultElectricityCharge);
    }
    return List<FeeChargeItem>.unmodifiable(normalized);
  }

  int _updatedCounterValue({
    required int current,
    required String identifier,
  }) {
    final RegExpMatch? match = RegExp(r'_(\d+)$').firstMatch(identifier);
    final int? suffix = match == null ? null : int.tryParse(match.group(1)!);
    if (suffix == null || suffix < current) {
      return current;
    }
    return suffix;
  }

  void _pushNotification({
    required String userId,
    required String title,
    required String message,
    required HostelNotificationType type,
  }) {
    _notifications.add(
      HostelNotificationItem(
        id: 'notification_${++_notificationCounter}',
        userId: userId,
        title: title,
        message: message,
        type: type,
        createdAt: DateTime.now(),
      ),
    );
  }

  void _broadcastNotification({
    required String title,
    required String message,
    required HostelNotificationType type,
  }) {
    for (final AppUser user in _users) {
      _pushNotification(
        userId: user.id,
        title: title,
        message: message,
        type: type,
      );
    }
  }

  void _seedData() {
    _blocks.addAll(
      const <HostelBlock>[
        HostelBlock(
          code: 'A',
          name: 'Academic Block',
          description: 'Quieter rooms close to classrooms and the library.',
        ),
        HostelBlock(
          code: 'B',
          name: 'Garden Block',
          description: 'Larger resident wing near the courtyard.',
        ),
        HostelBlock(
          code: 'C',
          name: 'City View',
          description: 'Balanced mid-rise wing for senior residents.',
        ),
        HostelBlock(
          code: 'D',
          name: 'Riverfront',
          description: 'Three-bed rooms with longer study hours.',
        ),
        HostelBlock(
          code: 'E',
          name: 'Summit Block',
          description: 'Newest section for overflow capacity.',
        ),
      ],
    );

    _rooms.addAll(
      <HostelRoom>[
        const HostelRoom(
          id: 'room_a101',
          block: 'A',
          number: '101',
          capacity: 2,
          roomType: 'Double Sharing',
          residentIds: <String>['student_2'],
        ),
        const HostelRoom(
          id: 'room_a102',
          block: 'A',
          number: '102',
          capacity: 2,
          roomType: 'Double Sharing',
          residentIds: <String>[],
        ),
        const HostelRoom(
          id: 'room_a201',
          block: 'A',
          number: '201',
          capacity: 3,
          roomType: 'Triple Sharing',
          residentIds: <String>[],
        ),
        const HostelRoom(
          id: 'room_b413',
          block: 'B',
          number: '413',
          capacity: 2,
          roomType: 'Double Sharing',
          residentIds: <String>['student_1'],
        ),
        const HostelRoom(
          id: 'room_b415',
          block: 'B',
          number: '415',
          capacity: 2,
          roomType: 'Double Sharing',
          residentIds: <String>['student_3'],
        ),
        const HostelRoom(
          id: 'room_b420',
          block: 'B',
          number: '420',
          capacity: 1,
          roomType: 'Single Occupancy',
          residentIds: <String>[],
        ),
      ],
    );
    _rooms.addAll(_generatedSeedRooms());

    _users.addAll(
      <AppUser>[
        AppUser(
          id: 'admin_1',
          username: 'admin',
          firstName: 'Hostel',
          lastName: 'Admin',
          email: 'admin@hostelhub.edu',
          password: 'Admin@123',
          phoneNumber: '9800000000',
          role: UserRole.admin,
          jobTitle: 'Operations Lead',
          emailVerified: true,
          emailVerifiedAt: DateTime.utc(2026, 1, 3),
        ),
        AppUser(
          id: 'staff_1',
          username: 'warden',
          firstName: 'Mangal',
          lastName: 'Karki',
          email: 'mangal.karki@hostelhub.edu',
          password: 'Warden@123',
          phoneNumber: '9804532792',
          role: UserRole.staff,
          jobTitle: 'Hostel Warden',
          emailVerified: true,
          emailVerifiedAt: DateTime.utc(2026, 1, 5),
        ),
        AppUser(
          id: 'staff_2',
          username: 'support',
          firstName: 'Rohit',
          lastName: 'Shah',
          email: 'rohit.shah@hostelhub.edu',
          password: 'Support@123',
          phoneNumber: '9804555555',
          role: UserRole.staff,
          jobTitle: 'Maintenance Supervisor',
          emailVerified: true,
          emailVerifiedAt: DateTime.utc(2026, 1, 5),
        ),
        AppUser(
          id: 'guest_1',
          username: 'guestdemo',
          firstName: 'Guest',
          lastName: 'Demo',
          email: 'guest.demo@hostelhub.edu',
          password: 'Guest@123',
          phoneNumber: '9803333333',
          role: UserRole.guest,
          emailVerified: true,
          emailVerifiedAt: DateTime.utc(2026, 1, 6),
        ),
        AppUser(
          id: 'student_1',
          username: 'aayush',
          firstName: 'Aayush',
          lastName: 'DC',
          email: 'aayush.dc@hostelhub.edu',
          password: 'Student@123',
          phoneNumber: '9876543210',
          role: UserRole.student,
          roomId: 'room_b413',
          emailVerified: true,
          emailVerifiedAt: DateTime.utc(2026, 1, 7),
        ),
        AppUser(
          id: 'student_2',
          username: 'shyam',
          firstName: 'Shyam',
          lastName: 'Thapa',
          email: 'shyam.thapa@hostelhub.edu',
          password: 'Student@123',
          phoneNumber: '9811111111',
          role: UserRole.student,
          roomId: 'room_a101',
          emailVerified: true,
          emailVerifiedAt: DateTime.utc(2026, 1, 8),
        ),
        AppUser(
          id: 'student_3',
          username: 'aarjila',
          firstName: 'Aarjila',
          lastName: 'Jirel',
          email: 'aarjila.jirel@hostelhub.edu',
          password: 'Student@123',
          phoneNumber: '9822222222',
          role: UserRole.student,
          roomId: 'room_b415',
          emailVerified: true,
          emailVerifiedAt: DateTime.utc(2026, 1, 8),
        ),
      ],
    );
    _seedAdditionalStudents();

    _issues.addAll(
      <IssueTicket>[
        IssueTicket(
          id: 'issue_1',
          studentId: 'student_1',
          category: 'Bathroom',
          comment: 'Tap leakage near the washbasin.',
          status: IssueStatus.open,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          assignedStaffId: 'staff_1',
        ),
        IssueTicket(
          id: 'issue_2',
          studentId: 'student_2',
          category: 'Electricity',
          comment: 'Tube light keeps flickering after 10 PM.',
          status: IssueStatus.resolved,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ],
    );

    final DateTime now = DateTime.now();
    _gatePasses.addAll(
      <GatePassRequest>[
        GatePassRequest(
          id: 'gatepass_1',
          studentId: 'student_1',
          destination: 'Pulchowk',
          reason: 'Family dinner',
          emergencyContact: '9801112200',
          passCode: _passCodeFor(now.subtract(const Duration(hours: 5)), 1),
          status: GatePassStatus.checkedOut,
          departureAt: now.subtract(const Duration(hours: 6)),
          expectedReturnAt: now.subtract(const Duration(hours: 2)),
          createdAt: now.subtract(const Duration(hours: 8)),
          reviewedAt: now.subtract(const Duration(hours: 7)),
          checkedOutAt: now.subtract(const Duration(hours: 6)),
        ),
        GatePassRequest(
          id: 'gatepass_2',
          studentId: 'student_2',
          destination: 'Library research center',
          reason: 'Project submission',
          emergencyContact: '9811113333',
          passCode: _passCodeFor(now.add(const Duration(days: 1)), 2),
          status: GatePassStatus.pending,
          departureAt: now.add(const Duration(days: 1, hours: 2)),
          expectedReturnAt: now.add(const Duration(days: 1, hours: 8)),
          createdAt: now.subtract(const Duration(hours: 3)),
        ),
        GatePassRequest(
          id: 'gatepass_3',
          studentId: 'student_3',
          destination: 'Jawalakhel',
          reason: 'Medical appointment',
          emergencyContact: '9822224444',
          passCode: _passCodeFor(now.subtract(const Duration(days: 1)), 3),
          status: GatePassStatus.returned,
          departureAt: now.subtract(const Duration(days: 1, hours: 7)),
          expectedReturnAt: now.subtract(const Duration(days: 1, hours: 2)),
          createdAt: now.subtract(const Duration(days: 1, hours: 9)),
          reviewedAt: now.subtract(const Duration(days: 1, hours: 8)),
          checkedOutAt: now.subtract(const Duration(days: 1, hours: 7)),
          returnedAt: now.subtract(const Duration(days: 1, hours: 3)),
        ),
      ],
    );

    _parcels.addAll(
      <ParcelItem>[
        ParcelItem(
          id: 'parcel_1',
          userId: 'student_1',
          carrier: 'DHL',
          trackingCode: 'DHL-2026-340',
          note: 'Books from home',
          status: ParcelStatus.awaitingPickup,
          createdAt: now.subtract(const Duration(days: 1)),
          notifiedAt: now.subtract(const Duration(days: 1)),
        ),
        ParcelItem(
          id: 'parcel_2',
          userId: 'student_2',
          carrier: 'Nepal Post',
          trackingCode: 'NP-9921',
          note: 'Documents envelope',
          status: ParcelStatus.collected,
          createdAt: now.subtract(const Duration(days: 4)),
          notifiedAt: now.subtract(const Duration(days: 4)),
          collectedAt: now.subtract(const Duration(days: 3)),
        ),
      ],
    );

    _visitorEntries.addAll(
      <VisitorEntry>[
        VisitorEntry(
          id: 'visitor_1',
          studentId: 'student_1',
          visitorName: 'Suresh DC',
          relation: 'Brother',
          note: 'Weekend visit',
          checkedInAt: now.subtract(const Duration(hours: 2)),
        ),
        VisitorEntry(
          id: 'visitor_2',
          studentId: 'student_3',
          visitorName: 'Mina Thapa',
          relation: 'Mother',
          note: 'Picked up documents',
          checkedInAt: now.subtract(const Duration(days: 2, hours: 1)),
          checkedOutAt: now.subtract(const Duration(days: 2)),
        ),
      ],
    );

    _laundryBookings.addAll(
      <LaundryBooking>[
        LaundryBooking(
          id: 'laundry_1',
          userId: 'student_1',
          machineLabel: 'Machine A',
          slotLabel: '07:00 - 08:00',
          scheduledAt: DateTime(now.year, now.month, now.day, 7),
          notes: 'Bedsheets',
          status: LaundryBookingStatus.scheduled,
          createdAt: now.subtract(const Duration(hours: 10)),
        ),
        LaundryBooking(
          id: 'laundry_2',
          userId: 'student_2',
          machineLabel: 'Machine B',
          slotLabel: '18:00 - 19:00',
          scheduledAt: DateTime(now.year, now.month, now.day, 18),
          notes: 'Weekend clothes',
          status: LaundryBookingStatus.completed,
          createdAt: now.subtract(const Duration(days: 1, hours: 4)),
          completedAt: now.subtract(const Duration(days: 1, hours: 2)),
        ),
      ],
    );

    _notifications.addAll(
      <HostelNotificationItem>[
        HostelNotificationItem(
          id: 'notification_1',
          userId: 'student_1',
          title: 'Fee reminder',
          message: 'Hostel fees for ${_billingMonthLabel()} are still pending.',
          type: HostelNotificationType.fee,
          createdAt: now.subtract(const Duration(hours: 6)),
        ),
        HostelNotificationItem(
          id: 'notification_2',
          userId: 'student_1',
          title: 'Parcel arrived',
          message: 'DHL delivery is ready at the desk.',
          type: HostelNotificationType.parcel,
          createdAt: now.subtract(const Duration(days: 1)),
          readAt: now.subtract(const Duration(hours: 12)),
        ),
        HostelNotificationItem(
          id: 'notification_3',
          userId: 'student_2',
          title: 'Study hall closes at 10 PM',
          message:
              'The study hall will close one hour early on Wednesday for maintenance.',
          type: HostelNotificationType.notice,
          createdAt: now.subtract(const Duration(hours: 8)),
        ),
        HostelNotificationItem(
          id: 'notification_4',
          userId: 'admin_1',
          title: 'Resident issue updated',
          message: 'A bathroom complaint is still open in Block B.',
          type: HostelNotificationType.complaint,
          createdAt: now.subtract(const Duration(hours: 4)),
        ),
      ],
    );

    _chatMessages.addAll(
      <ChatMessage>[
        ChatMessage(
          id: 'chat_1',
          senderId: 'student_1',
          recipientId: 'staff_1',
          message: 'I need approval for an early morning gate pass tomorrow.',
          sentAt: now.subtract(const Duration(hours: 5)),
          readAt: now.subtract(const Duration(hours: 4, minutes: 30)),
        ),
        ChatMessage(
          id: 'chat_2',
          senderId: 'staff_1',
          recipientId: 'student_1',
          message: 'Submit the request before 9 PM and I will review it.',
          sentAt: now.subtract(const Duration(hours: 4, minutes: 20)),
        ),
        ChatMessage(
          id: 'chat_3',
          senderId: 'student_2',
          recipientId: 'admin_1',
          message: 'Can the notice board include upcoming maintenance windows?',
          sentAt: now.subtract(const Duration(days: 1, hours: 2)),
          readAt: now.subtract(const Duration(days: 1)),
        ),
      ],
    );

    _messMenu.addAll(
      const <MessMenuDay>[
        MessMenuDay(
          day: MessDay.monday,
          breakfast: 'Poha & tea',
          lunch: 'Dal bhat, aloo fry',
          dinner: 'Roti, paneer curry',
        ),
        MessMenuDay(
          day: MessDay.tuesday,
          breakfast: 'Boiled eggs & bread',
          lunch: 'Veg pulao, raita',
          dinner: 'Rice, chicken curry',
        ),
        MessMenuDay(
          day: MessDay.wednesday,
          breakfast: 'Upma & banana',
          lunch: 'Dal bhat, mixed veg',
          dinner: 'Roti, chow mein',
        ),
        MessMenuDay(
          day: MessDay.thursday,
          breakfast: 'Paratha & curd',
          lunch: 'Rice, rajma masala',
          dinner: 'Khichdi, pickle',
        ),
        MessMenuDay(
          day: MessDay.friday,
          breakfast: 'Pancake & fruit',
          lunch: 'Dal bhat, fish curry',
          dinner: 'Roti, mushroom curry',
        ),
        MessMenuDay(
          day: MessDay.saturday,
          breakfast: 'Chana & tea',
          lunch: 'Fried rice, momo',
          dinner: 'Rice, mutton curry',
        ),
        MessMenuDay(
          day: MessDay.sunday,
          breakfast: 'Puri tarkari',
          lunch: 'Biryani, salad',
          dinner: 'Roti, dal makhani',
        ),
      ],
    );

    _mealAttendance.addAll(
      <MealAttendanceDay>[
        MealAttendanceDay(
          id: 'attendance_student_1_${_todayDay().name}',
          userId: 'student_1',
          day: _todayDay(),
          date: _dateForDay(_todayDay()),
          breakfast: true,
          lunch: true,
          dinner: false,
        ),
        MealAttendanceDay(
          id: 'attendance_student_2_${_todayDay().name}',
          userId: 'student_2',
          day: _todayDay(),
          date: _dateForDay(_todayDay()),
          breakfast: true,
          lunch: false,
          dinner: false,
        ),
        MealAttendanceDay(
          id: 'attendance_student_3_${_previousDay(_todayDay()).name}',
          userId: 'student_3',
          day: _previousDay(_todayDay()),
          date: _dateForDay(_previousDay(_todayDay())),
          breakfast: true,
          lunch: true,
          dinner: true,
        ),
      ],
    );

    _foodFeedback.addAll(
      <FoodFeedback>[
        FoodFeedback(
          id: 'feedback_1',
          userId: 'student_1',
          rating: 4,
          comment: 'Lunch portion was solid and the dal tasted fresh.',
          submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        FoodFeedback(
          id: 'feedback_2',
          userId: 'student_2',
          rating: 3,
          comment: 'Dinner was okay, but the soup could be hotter.',
          submittedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ],
    );

    _notices.addAll(
      <NoticeItem>[
        NoticeItem(
          id: 'notice_1',
          title: 'Study hall closes at 10 PM',
          message:
              'The study hall will close one hour early on Wednesday for maintenance.',
          category: 'Announcement',
          postedAt: DateTime.now().subtract(const Duration(hours: 8)),
          isPinned: true,
        ),
        NoticeItem(
          id: 'notice_2',
          title: 'Saturday movie night',
          message:
              'Join the common room screening at 7:30 PM. Seats are first come, first served.',
          category: 'Event',
          postedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        NoticeItem(
          id: 'notice_3',
          title: 'Quiet hours after 10 PM',
          message:
              'Keep corridor noise low and avoid speaker use after 10 PM in all blocks.',
          category: 'Rule',
          postedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ],
    );

    _roomRequests.add(
      RoomChangeRequest(
        id: 'request_1',
        studentId: 'student_1',
        currentRoomId: 'room_b413',
        desiredRoomId: 'room_e301',
        reason: 'Need a quieter room closer to the study hall.',
        status: RoomRequestStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    );

    _feeSummaries.addAll(
      <String, FeeSummary>{
        'student_1': _defaultFeeForRoom(_requireRoom('room_b413')),
        'student_2': _defaultFeeForRoom(_requireRoom('room_a101')),
        'student_3': _defaultFeeForRoom(_requireRoom('room_b415')),
      },
    );
    for (final AppUser user
        in _users.where((AppUser user) => user.role.isStudent)) {
      final String? roomId = user.roomId;
      if (roomId == null || _feeSummaries.containsKey(user.id)) {
        continue;
      }
      _feeSummaries[user.id] = _defaultFeeForRoom(_requireRoom(roomId));
    }
    _seedPaymentActivity();
  }

  void _ensureUniqueCredentials({
    required String email,
    required String username,
    required String phoneNumber,
  }) {
    final String normalizedEmail = email.trim().toLowerCase();
    final String normalizedUsername = username.trim().toLowerCase();
    final String normalizedPhone = phoneNumber.trim();
    _validateEmail(normalizedEmail);
    if (!_isPhoneNumber(normalizedPhone)) {
      throw const HostelRepositoryException(
        'Enter a valid 10 digit phone number.',
      );
    }
    for (final AppUser user in _users) {
      if (user.email.toLowerCase() == normalizedEmail) {
        throw const HostelRepositoryException(
          'That email address is already in use.',
        );
      }
      if (user.username.toLowerCase() == normalizedUsername) {
        throw const HostelRepositoryException(
          'That username is already in use.',
        );
      }
      if (user.phoneNumber == normalizedPhone) {
        throw const HostelRepositoryException(
          'That phone number is already in use.',
        );
      }
    }
  }

  AppUser _requireUserByEmail(String email) {
    final String normalizedEmail = email.trim().toLowerCase();
    for (final AppUser user in _users) {
      if (user.email.toLowerCase() == normalizedEmail) {
        return user;
      }
    }
    throw const HostelRepositoryException('Account not found for this email.');
  }

  AppUser _requireUser(String userId) {
    for (final AppUser user in _users) {
      if (user.id == userId) {
        return user;
      }
    }
    throw const HostelRepositoryException('User not found.');
  }

  AppUser? _findUserOrNull(String userId) {
    for (final AppUser user in _users) {
      if (user.id == userId) {
        return user;
      }
    }
    return null;
  }

  HostelRoom _requireRoom(String roomId) {
    for (final HostelRoom room in _rooms) {
      if (room.id == roomId) {
        return room;
      }
    }
    throw const HostelRepositoryException('Room not found.');
  }

  void _ensureBlockExists(String blockCode) {
    final bool exists =
        _blocks.any((HostelBlock block) => block.code == blockCode);
    if (!exists) {
      throw const HostelRepositoryException('Block not found.');
    }
  }

  void _replaceRoom(HostelRoom room) {
    final int index = _rooms.indexWhere(
      (HostelRoom existingRoom) => existingRoom.id == room.id,
    );
    if (index != -1) {
      _rooms[index] = room;
    }
  }

  void _replaceUser(AppUser user) {
    final int index = _users.indexWhere(
      (AppUser existingUser) => existingUser.id == user.id,
    );
    if (index != -1) {
      _users[index] = user;
    }
  }

  void _resolvePendingRoomRequestsForResident({
    required String studentId,
    required String assignedRoomId,
  }) {
    final DateTime resolvedAt = DateTime.now();
    for (int index = 0; index < _roomRequests.length; index += 1) {
      final RoomChangeRequest request = _roomRequests[index];
      if (request.studentId != studentId || !request.status.isPending) {
        continue;
      }
      _roomRequests[index] = request.copyWith(
        status: request.desiredRoomId == assignedRoomId
            ? RoomRequestStatus.approved
            : RoomRequestStatus.rejected,
        resolvedAt: resolvedAt,
      );
    }
  }

  FeeSummary _defaultFeeForRoom(
    HostelRoom room, {
    FeeSummary? existing,
  }) {
    final String billingMonth = _billingMonthLabel();
    final bool isCurrentBillingMonth =
        existing != null && existing.billingMonth == billingMonth;
    final int baseRoomCharge;
    if (room.roomType == 'Single Occupancy') {
      baseRoomCharge = _feeSettings.singleOccupancyCharge;
    } else if (room.roomType == 'Triple Sharing') {
      baseRoomCharge = _feeSettings.tripleSharingCharge;
    } else {
      baseRoomCharge = _feeSettings.doubleSharingCharge;
    }
    return FeeSummary(
      maintenanceCharge: _feeSettings.maintenanceCharge,
      parkingCharge: _feeSettings.parkingCharge,
      waterCharge: _feeSettings.waterCharge,
      roomCharge: baseRoomCharge,
      additionalCharges: _feeSettings.customCharges,
      billingMonth: billingMonth,
      paidAmount: _clampPaidAmount(
        isCurrentBillingMonth ? existing.paidAmount : 0,
        _feeSettings.maintenanceCharge +
            _feeSettings.parkingCharge +
            _feeSettings.waterCharge +
            baseRoomCharge +
            _feeSettings.customCharges.fold<int>(
              0,
              (int sum, FeeChargeItem item) => sum + item.amount,
            ),
      ),
      dueDate: isCurrentBillingMonth ? existing.dueDate : _defaultDueDate(),
      lastReminderAt: isCurrentBillingMonth ? existing.lastReminderAt : null,
    );
  }

  FeeSummary _defaultFeeForFallback({
    FeeSummary? existing,
  }) {
    final String billingMonth = _billingMonthLabel();
    final bool isCurrentBillingMonth =
        existing != null && existing.billingMonth == billingMonth;
    final int total = _feeSettings.maintenanceCharge +
        _feeSettings.parkingCharge +
        _feeSettings.waterCharge +
        _feeSettings.doubleSharingCharge +
        _feeSettings.customCharges.fold<int>(
          0,
          (int sum, FeeChargeItem item) => sum + item.amount,
        );
    return FeeSummary(
      maintenanceCharge: _feeSettings.maintenanceCharge,
      parkingCharge: _feeSettings.parkingCharge,
      waterCharge: _feeSettings.waterCharge,
      roomCharge: _feeSettings.doubleSharingCharge,
      additionalCharges: _feeSettings.customCharges,
      billingMonth: billingMonth,
      paidAmount: _clampPaidAmount(
        isCurrentBillingMonth ? existing.paidAmount : 0,
        total,
      ),
      dueDate: isCurrentBillingMonth ? existing.dueDate : _defaultDueDate(),
      lastReminderAt: isCurrentBillingMonth ? existing.lastReminderAt : null,
    );
  }

  FeeSummary _resolvedFeeSummaryForUser(String userId) {
    final AppUser user = _requireUser(userId);
    final FeeSummary? existing = _feeSummaries[userId];
    final FeeSummary next = user.roomId == null
        ? _defaultFeeForFallback(existing: existing)
        : _defaultFeeForRoom(
            _requireRoom(user.roomId!),
            existing: existing,
          );
    _feeSummaries[userId] = next;
    return next;
  }

  void _recalculateAllFees() {
    for (final AppUser user
        in _users.where((AppUser user) => user.role.isStudent)) {
      _resolvedFeeSummaryForUser(user.id);
    }
  }

  void _syncFeeState() {
    _feeSettings = _feeSettings.copyWith(
      customCharges: _withRequiredFeeCharges(_feeSettings.customCharges),
    );
    _recalculateAllFees();
  }

  void _seedPaymentActivity() {
    final DateTime now = DateTime.now();
    final FeeSummary? residentOne = _feeSummaries['student_1'];
    final FeeSummary? residentTwo = _feeSummaries['student_2'];
    if (residentOne != null) {
      _feeSummaries['student_1'] = residentOne.copyWith(
        paidAmount: 2000,
        lastReminderAt: now.subtract(const Duration(days: 2)),
      );
      _paymentHistory['student_1'] = <PaymentRecord>[
        PaymentRecord(
          id: 'payment_1',
          userId: 'student_1',
          amount: 2000,
          method: PaymentMethod.eSewa,
          status: PaymentStatus.paid,
          receiptId: _receiptIdFor(
            now.subtract(const Duration(days: 5)),
            sequence: 1,
          ),
          billingMonth: residentOne.billingMonth,
          paidAt: now.subtract(const Duration(days: 5)),
        ),
      ];
    }
    if (residentTwo != null) {
      _feeSummaries['student_2'] = residentTwo.copyWith(
        paidAmount: residentTwo.total,
      );
      _paymentHistory['student_2'] = <PaymentRecord>[
        PaymentRecord(
          id: 'payment_2',
          userId: 'student_2',
          amount: residentTwo.total,
          method: PaymentMethod.bankTransfer,
          status: PaymentStatus.paid,
          receiptId: _receiptIdFor(
            now.subtract(const Duration(days: 3)),
            sequence: 2,
          ),
          billingMonth: residentTwo.billingMonth,
          paidAt: now.subtract(const Duration(days: 3)),
        ),
      ];
    }
    _paymentHistory.putIfAbsent('student_3', () => <PaymentRecord>[]);
  }

  List<MessMenuDay> _blankMessMenu() {
    return const <MessMenuDay>[
      MessMenuDay(day: MessDay.monday, breakfast: '', lunch: '', dinner: ''),
      MessMenuDay(day: MessDay.tuesday, breakfast: '', lunch: '', dinner: ''),
      MessMenuDay(day: MessDay.wednesday, breakfast: '', lunch: '', dinner: ''),
      MessMenuDay(day: MessDay.thursday, breakfast: '', lunch: '', dinner: ''),
      MessMenuDay(day: MessDay.friday, breakfast: '', lunch: '', dinner: ''),
      MessMenuDay(day: MessDay.saturday, breakfast: '', lunch: '', dinner: ''),
      MessMenuDay(day: MessDay.sunday, breakfast: '', lunch: '', dinner: ''),
    ];
  }

  AdminCatalog _defaultAdminCatalog() {
    return const AdminCatalog(
      issueCategories: <String>[
        'Bathroom',
        'Bedroom',
        'Electricity',
        'Furniture',
        'Mess Food',
        'Water',
      ],
      noticeCategories: <String>[
        'Announcement',
        'Event',
        'Rule',
      ],
      laundryMachines: <String>[
        'Machine A',
        'Machine B',
        'Machine C',
      ],
      parcelCarriers: <String>[
        'DHL',
        'FedEx',
        'Nepal Post',
      ],
      alertPresets: <AdminAlertPreset>[
        AdminAlertPreset(
          title: 'Urgent maintenance',
          category: 'Announcement',
          message: 'A facility maintenance update needs immediate attention.',
        ),
        AdminAlertPreset(
          title: 'Mess update',
          category: 'Event',
          message: 'There is an important change in today\'s mess service.',
        ),
      ],
      serviceShortcuts: <AdminServiceShortcut>[],
    );
  }

  List<HostelRoom> _generatedSeedRooms() {
    const List<String> blocks = <String>['C', 'D', 'E'];
    final List<HostelRoom> rooms = <HostelRoom>[];
    for (final String block in blocks) {
      for (int floor = 1; floor <= 3; floor += 1) {
        for (int roomNumber = 1; roomNumber <= 4; roomNumber += 1) {
          final String number = '${floor}0$roomNumber';
          rooms.add(
            HostelRoom(
              id: 'room_${block.toLowerCase()}$number',
              block: block,
              number: number,
              capacity: 3,
              roomType: 'Triple Sharing',
              residentIds: const <String>[],
            ),
          );
        }
      }
    }
    return rooms;
  }

  void _seedAdditionalStudents() {
    const List<String> firstNames = <String>[
      'Sujan',
      'Nishan',
      'Prakash',
      'Kiran',
      'Suman',
      'Amit',
      'Ritesh',
      'Nabin',
      'Bikash',
      'Sabin',
      'Puja',
      'Asmita',
      'Anusha',
      'Srijana',
      'Nikita',
      'Rachana',
      'Bibek',
      'Sagar',
      'Roshan',
      'Ankit',
    ];
    const List<String> lastNames = <String>[
      'Shrestha',
      'Tamang',
      'Basnet',
      'Khadka',
      'Gurung',
      'Acharya',
      'Bista',
      'Rai',
      'Maharjan',
      'Adhikari',
    ];

    final List<HostelRoom> updatedRooms = List<HostelRoom>.from(_rooms);
    int nextRoomIndex = 0;

    HostelRoom assignableRoom() {
      while (nextRoomIndex < updatedRooms.length &&
          !updatedRooms[nextRoomIndex].hasAvailability) {
        nextRoomIndex += 1;
      }
      if (nextRoomIndex >= updatedRooms.length) {
        throw const HostelRepositoryException('Seed inventory is full.');
      }
      return updatedRooms[nextRoomIndex];
    }

    for (int index = 4; index <= 108; index += 1) {
      final String firstName = firstNames[(index - 4) % firstNames.length];
      final String lastName =
          lastNames[((index - 4) ~/ firstNames.length) % lastNames.length];
      final String userId = 'student_$index';
      final HostelRoom room = assignableRoom();
      final AppUser user = AppUser(
        id: userId,
        username: '${firstName.toLowerCase()}${lastName.toLowerCase()}$index',
        firstName: firstName,
        lastName: lastName,
        email:
            '${firstName.toLowerCase()}.${lastName.toLowerCase()}$index@hostelhub.edu',
        password: 'Student@123',
        phoneNumber: '98${(30000000 + index).toString().padLeft(8, '0')}',
        role: UserRole.student,
        roomId: room.id,
        emailVerified: true,
        emailVerifiedAt: DateTime(2026, 1, 10),
      );
      _users.add(user);
      final int roomIndex = updatedRooms.indexWhere(
        (HostelRoom current) => current.id == room.id,
      );
      updatedRooms[roomIndex] = room.copyWith(
        residentIds: <String>[...room.residentIds, userId],
      );
    }

    _rooms
      ..clear()
      ..addAll(updatedRooms);
    _userCounter = 108;
  }

  AuthChallenge _issueAuthChallenge({
    required String email,
    required String purpose,
  }) {
    final DateTime now = DateTime.now();
    final String code =
        ((now.microsecondsSinceEpoch % 900000) + 100000).toString();
    final AuthChallenge challenge = AuthChallenge(
      email: email.trim().toLowerCase(),
      code: code,
      expiresAt: now.add(const Duration(minutes: 15)),
      deliveryMethod: AuthChallengeDeliveryMethod.local,
    );
    _authChallenges[_challengeKey(email: email, purpose: purpose)] = challenge;
    return challenge;
  }

  void _consumeAuthChallenge({
    required String email,
    required String purpose,
    required String code,
  }) {
    final String key = _challengeKey(email: email, purpose: purpose);
    final AuthChallenge? challenge = _authChallenges[key];
    if (challenge == null) {
      throw const HostelRepositoryException(
          'Request a fresh verification code.');
    }
    if (challenge.isExpired) {
      _authChallenges.remove(key);
      throw const HostelRepositoryException(
          'The verification code has expired.');
    }
    if (challenge.code != code.trim()) {
      throw const HostelRepositoryException(
          'The verification code is invalid.');
    }
    _authChallenges.remove(key);
  }

  String _challengeKey({
    required String email,
    required String purpose,
  }) {
    return '${purpose.toLowerCase()}:${email.trim().toLowerCase()}';
  }

  void _validateEmail(String email) {
    final RegExp emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(email.trim().toLowerCase())) {
      throw const HostelRepositoryException('Enter a valid email address.');
    }
  }

  void _validatePassword(String password) {
    if (password.trim().length < 8) {
      throw const HostelRepositoryException(
        'Password must be at least 8 characters.',
      );
    }
  }

  bool _isPhoneNumber(String value) {
    final RegExp phonePattern = RegExp(r'^\d{10}$');
    return phonePattern.hasMatch(value.trim());
  }

  int _clampPaidAmount(int paidAmount, int total) {
    if (paidAmount < 0) {
      return 0;
    }
    if (paidAmount > total) {
      return total;
    }
    return paidAmount;
  }

  DateTime _defaultDueDate() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, 12);
  }

  String _billingMonthLabel([DateTime? date]) {
    const List<String> months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final DateTime resolved = date ?? DateTime.now();
    return '${months[resolved.month - 1]} ${resolved.year}';
  }

  String _receiptIdFor(DateTime date, {int? sequence}) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    final int suffix = sequence ?? _paymentCounter;
    return 'RCT-${date.year}$month$day-${suffix.toString().padLeft(3, '0')}';
  }

  String _passCodeFor(DateTime date, int sequence) {
    final String year = (date.year % 100).toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return 'GP-$year$month$day-${sequence.toString().padLeft(3, '0')}';
  }

  String _buildRoomId(String block, String number) {
    final String sanitizedNumber =
        number.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
    return 'room_${block.toLowerCase()}$sanitizedNumber';
  }

  DateTime _dateForDay(MessDay day) {
    final DateTime now = DateTime.now();
    final DateTime monday = now.subtract(Duration(days: now.weekday - 1));
    return DateTime(
      monday.year,
      monday.month,
      monday.day + day.index,
    );
  }

  MessDay _todayDay() {
    return MessDay.values[DateTime.now().weekday - 1];
  }

  MessDay _previousDay(MessDay day) {
    return MessDay.values[(day.index + 6) % MessDay.values.length];
  }
}
