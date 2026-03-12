import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;

import '../config/app_environment.dart';
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
import '../services/hostel_repository.dart';
import '../services/session_store.dart';

class AppState extends ChangeNotifier {
  AppState(
    this._repository, {
    SessionStore? sessionStore,
  }) : _sessionStore = sessionStore ?? const SharedPreferencesSessionStore();

  final HostelRepository _repository;
  final SessionStore _sessionStore;

  bool _isLoading = false;
  ThemeMode _themeMode = ThemeMode.system;
  bool _inAppNotificationsEnabled = true;
  bool _notificationPreviewsEnabled = true;
  bool _notificationBadgesEnabled = true;
  bool _activityAutoRefreshEnabled = true;
  bool _showRoomDetailsOnCards = true;
  bool _showContactInfoOnCards = true;
  String? _backendBaseUrlOverride;
  AppUser? _currentUser;
  AdminCatalog _adminCatalog = defaultAdminCatalog;
  FeeSettings? _feeSettings;
  FeeSummary? _currentFeeSummary;
  MessBillSummary? _currentMessBill;
  final Map<String, FeeSummary> _studentFeeSummaries = <String, FeeSummary>{};
  final Map<String, MessBillSummary> _messBillsByUser =
      <String, MessBillSummary>{};
  final Map<String, List<PaymentRecord>> _paymentHistoryByUser =
      <String, List<PaymentRecord>>{};
  AuthChallenge? _emailVerificationChallenge;
  AuthChallenge? _passwordResetChallenge;
  SetupStatus _setupStatus = const SetupStatus(
    requiresBootstrap: false,
    demoMode: false,
  );
  String? _lastError;

  List<AppUser> _students = <AppUser>[];
  List<AppUser> _guests = <AppUser>[];
  List<AppUser> _staffMembers = <AppUser>[];
  List<ChatMessage> _chatMessages = <ChatMessage>[];
  List<HostelNotificationItem> _notifications = <HostelNotificationItem>[];
  List<HostelBlock> _blocks = <HostelBlock>[];
  List<HostelRoom> _rooms = <HostelRoom>[];
  List<IssueTicket> _issues = <IssueTicket>[];
  List<GatePassRequest> _gatePasses = <GatePassRequest>[];
  List<ParcelItem> _parcels = <ParcelItem>[];
  List<VisitorEntry> _visitorEntries = <VisitorEntry>[];
  List<LaundryBooking> _laundryBookings = <LaundryBooking>[];
  List<MessMenuDay> _messMenu = <MessMenuDay>[];
  List<MealAttendanceDay> _mealAttendance = <MealAttendanceDay>[];
  List<FoodFeedback> _foodFeedback = <FoodFeedback>[];
  List<NoticeItem> _notices = <NoticeItem>[];
  List<RoomChangeRequest> _roomRequests = <RoomChangeRequest>[];

  bool get isLoading => _isLoading;

  ThemeMode get themeMode => _themeMode;

  bool get inAppNotificationsEnabled => _inAppNotificationsEnabled;

  bool get notificationPreviewsEnabled => _notificationPreviewsEnabled;

  bool get notificationBadgesEnabled => _notificationBadgesEnabled;

  bool get activityAutoRefreshEnabled => _activityAutoRefreshEnabled;

  bool get showRoomDetailsOnCards => _showRoomDetailsOnCards;

  bool get showContactInfoOnCards => _showContactInfoOnCards;

  String? get backendBaseUrlOverride => _backendBaseUrlOverride;

  String? get activeBackendBaseUrl => AppEnvironment.resolvePythonApiBaseUrl(
        storedBaseUrl: _backendBaseUrlOverride,
      );

  bool get backendBaseUrlLockedByBuild => AppEnvironment.hasExplicitApiBaseUrl;

  AppUser? get currentUser => _currentUser;

  AdminCatalog get adminCatalog => _adminCatalog;

  bool get isAuthenticated => _currentUser != null;

  String? get lastError => _lastError;

  AuthChallenge? get emailVerificationChallenge => _emailVerificationChallenge;

  AuthChallenge? get passwordResetChallenge => _passwordResetChallenge;

  bool get requiresEmailVerification =>
      _currentUser != null && !_currentUser!.emailVerified;

  bool get requiresAdminBootstrap =>
      _setupStatus.requiresBootstrap && _currentUser == null;

  bool get isDemoMode => _setupStatus.demoMode;

  List<AppUser> get students => List<AppUser>.unmodifiable(_students);

  List<AppUser> get guests => List<AppUser>.unmodifiable(_guests);

  List<AppUser> get staffMembers => List<AppUser>.unmodifiable(_staffMembers);

  List<HostelNotificationItem> get notifications =>
      List<HostelNotificationItem>.unmodifiable(_notifications);

  List<ChatMessage> get chatMessages =>
      List<ChatMessage>.unmodifiable(_chatMessages);

  List<HostelBlock> get blocks => List<HostelBlock>.unmodifiable(_blocks);

  List<HostelRoom> get rooms => List<HostelRoom>.unmodifiable(_rooms);

  List<GatePassRequest> get visibleGatePasses {
    final AppUser? user = _currentUser;
    if (user == null) {
      return const <GatePassRequest>[];
    }
    if (user.canManageGatePass) {
      return List<GatePassRequest>.unmodifiable(_gatePasses);
    }
    return List<GatePassRequest>.unmodifiable(
      _gatePasses.where((GatePassRequest item) => item.studentId == user.id),
    );
  }

  List<ParcelItem> get visibleParcels {
    final AppUser? user = _currentUser;
    if (user == null) {
      return const <ParcelItem>[];
    }
    if (user.canManageFrontDesk) {
      return List<ParcelItem>.unmodifiable(_parcels);
    }
    return List<ParcelItem>.unmodifiable(
      _parcels.where((ParcelItem item) => item.userId == user.id),
    );
  }

  List<VisitorEntry> get visibleVisitorEntries {
    final AppUser? user = _currentUser;
    if (user == null) {
      return const <VisitorEntry>[];
    }
    if (user.canManageFrontDesk) {
      return List<VisitorEntry>.unmodifiable(_visitorEntries);
    }
    return List<VisitorEntry>.unmodifiable(
      _visitorEntries.where((VisitorEntry entry) => entry.studentId == user.id),
    );
  }

  List<LaundryBooking> get visibleLaundryBookings {
    final AppUser? user = _currentUser;
    if (user == null) {
      return const <LaundryBooking>[];
    }
    if (user.canManageLaundry) {
      return List<LaundryBooking>.unmodifiable(_laundryBookings);
    }
    return List<LaundryBooking>.unmodifiable(
      _laundryBookings
          .where((LaundryBooking booking) => booking.userId == user.id),
    );
  }

  List<MessMenuDay> get messMenu => List<MessMenuDay>.unmodifiable(_messMenu);

  List<MealAttendanceDay> get visibleMealAttendance {
    final AppUser? user = _currentUser;
    if (user == null) {
      return const <MealAttendanceDay>[];
    }
    if (user.canManageMess) {
      return List<MealAttendanceDay>.unmodifiable(_mealAttendance);
    }
    return List<MealAttendanceDay>.unmodifiable(
      _mealAttendance
          .where((MealAttendanceDay entry) => entry.userId == user.id),
    );
  }

  List<FoodFeedback> get visibleFoodFeedback {
    final AppUser? user = _currentUser;
    if (user == null) {
      return const <FoodFeedback>[];
    }
    if (user.canManageMess) {
      return List<FoodFeedback>.unmodifiable(_foodFeedback);
    }
    return List<FoodFeedback>.unmodifiable(
      _foodFeedback
          .where((FoodFeedback feedback) => feedback.userId == user.id),
    );
  }

  List<NoticeItem> get notices => List<NoticeItem>.unmodifiable(_notices);

  List<IssueTicket> get visibleIssues {
    final AppUser? user = _currentUser;
    if (user == null) {
      return const <IssueTicket>[];
    }
    if (user.canManageIssues) {
      return List<IssueTicket>.unmodifiable(_issues);
    }
    if (user.role == UserRole.staff) {
      return List<IssueTicket>.unmodifiable(
        _issues.where((IssueTicket issue) => issue.assignedStaffId == user.id),
      );
    }
    return List<IssueTicket>.unmodifiable(
      _issues.where((IssueTicket issue) => issue.studentId == user.id),
    );
  }

  List<RoomChangeRequest> get visibleRoomRequests {
    final AppUser? user = _currentUser;
    if (user == null) {
      return const <RoomChangeRequest>[];
    }
    if (user.canManageRoomRequests) {
      return List<RoomChangeRequest>.unmodifiable(_roomRequests);
    }
    return List<RoomChangeRequest>.unmodifiable(
      _roomRequests
          .where((RoomChangeRequest request) => request.studentId == user.id),
    );
  }

  FeeSummary? get currentFeeSummary => _currentFeeSummary;

  MessBillSummary? get currentMessBill => _currentMessBill;

  FeeSettings? get feeSettings => _feeSettings;

  List<PaymentRecord> get currentPaymentHistory {
    final String? userId = _currentUser?.id;
    if (userId == null) {
      return const <PaymentRecord>[];
    }
    return paymentHistoryFor(userId);
  }

  int get unreadNotificationCount {
    return _notifications
        .where((HostelNotificationItem item) => !item.isRead)
        .length;
  }

  int get unreadChatCount {
    final String? userId = _currentUser?.id;
    if (userId == null) {
      return 0;
    }
    return _chatMessages
        .where(
          (ChatMessage item) => item.recipientId == userId && !item.isRead,
        )
        .length;
  }

  FeeSummary? feeSummaryFor(String userId) {
    if (_currentUser?.id == userId && _currentFeeSummary != null) {
      return _currentFeeSummary;
    }
    return _studentFeeSummaries[userId];
  }

  List<PaymentRecord> paymentHistoryFor(String userId) {
    final List<PaymentRecord>? history = _paymentHistoryByUser[userId];
    if (history == null) {
      return const <PaymentRecord>[];
    }
    return List<PaymentRecord>.unmodifiable(history);
  }

  List<PaymentRecord> get recentPayments {
    final List<PaymentRecord> payments = _paymentHistoryByUser.values
        .expand((List<PaymentRecord> records) => records)
        .toList(growable: false);
    payments.sort(
      (PaymentRecord a, PaymentRecord b) => b.paidAt.compareTo(a.paidAt),
    );
    return payments;
  }

  MessBillSummary? messBillFor(String userId) {
    if (_currentUser?.id == userId && _currentMessBill != null) {
      return _currentMessBill;
    }
    return _messBillsByUser[userId];
  }

  MealAttendanceDay? mealAttendanceFor({
    required String userId,
    required MessDay day,
  }) {
    for (final MealAttendanceDay entry in _mealAttendance) {
      if (entry.userId == userId && entry.day == day) {
        return entry;
      }
    }
    return null;
  }

  HostelRoom? get currentRoom {
    final String? roomId = _currentUser?.roomId;
    if (roomId == null) {
      return null;
    }
    for (final HostelRoom room in _rooms) {
      if (room.id == roomId) {
        return room;
      }
    }
    return null;
  }

  List<HostelRoom> get occupiedRooms => _rooms
      .where((HostelRoom room) => room.occupiedBeds > 0)
      .toList(growable: false);

  int get openIssueCount {
    return visibleIssues
        .where((IssueTicket issue) => !issue.status.isResolved)
        .length;
  }

  int get pendingRoomRequestCount {
    return visibleRoomRequests
        .where((RoomChangeRequest request) => request.status.isPending)
        .length;
  }

  int get pendingGatePassCount {
    return visibleGatePasses
        .where((GatePassRequest request) => request.status.isPending)
        .length;
  }

  int get activeLateEntryCount {
    return visibleGatePasses
        .where((GatePassRequest request) => request.isLateNow)
        .length;
  }

  int get activeGatePassCount {
    return visibleGatePasses
        .where(
          (GatePassRequest request) =>
              request.status.isPending ||
              request.status.isApproved ||
              request.status.isCheckedOut ||
              request.isLateNow,
        )
        .length;
  }

  int get availableRoomCount {
    return _rooms.where((HostelRoom room) => room.hasAvailability).length;
  }

  int get pendingFeeCount {
    return _students.where((AppUser student) {
      final FeeSummary? summary = feeSummaryFor(student.id);
      return summary != null && !summary.isPaid && summary.balance > 0;
    }).length;
  }

  int get pendingParcelCount {
    return visibleParcels
        .where((ParcelItem item) => item.status.isPending)
        .length;
  }

  int get activeVisitorCount {
    return visibleVisitorEntries
        .where((VisitorEntry entry) => entry.isActive)
        .length;
  }

  int get frontDeskAttentionCount {
    return pendingParcelCount + activeVisitorCount;
  }

  int get activeLaundryCount {
    return visibleLaundryBookings
        .where((LaundryBooking booking) => booking.isActive)
        .length;
  }

  List<HostelRoom> availableRoomsFor({
    String? block,
    String? includeRoomId,
  }) {
    return _dedupeRooms(
      _rooms.where((HostelRoom room) {
        final bool matchesBlock = block == null || room.block == block;
        final bool isCurrentRoom =
            includeRoomId != null && room.id == includeRoomId;
        return matchesBlock && (room.hasAvailability || isCurrentRoom);
      }).toList(growable: false),
    );
  }

  HostelBlock? findBlock(String code) {
    for (final HostelBlock block in _blocks) {
      if (block.code == code) {
        return block;
      }
    }
    return null;
  }

  AppUser? findUser(String userId) {
    for (final AppUser user in <AppUser>[
      ..._staffMembers,
      ..._students,
      ..._guests,
    ]) {
      if (user.id == userId) {
        return user;
      }
    }
    return null;
  }

  HostelRoom? findRoom(String roomId) {
    for (final HostelRoom room in _rooms) {
      if (room.id == roomId) {
        return room;
      }
    }
    return null;
  }

  List<HostelBlock> _dedupeBlocks(Iterable<HostelBlock> blocks) {
    final Set<String> seenCodes = <String>{};
    final List<HostelBlock> uniqueBlocks = <HostelBlock>[];
    for (final HostelBlock block in blocks) {
      if (seenCodes.add(block.code)) {
        uniqueBlocks.add(block);
      }
    }
    return uniqueBlocks;
  }

  List<HostelRoom> _dedupeRooms(Iterable<HostelRoom> rooms) {
    final Set<String> seenIds = <String>{};
    final List<HostelRoom> uniqueRooms = <HostelRoom>[];
    for (final HostelRoom room in rooms) {
      if (seenIds.add(room.id)) {
        uniqueRooms.add(room);
      }
    }
    return uniqueRooms;
  }

  Future<void> initialize() async {
    try {
      _themeMode = _themeModeFromName(await _sessionStore.readThemeMode());
      _inAppNotificationsEnabled =
          await _sessionStore.readInAppNotificationsEnabled() ?? true;
      _notificationPreviewsEnabled =
          await _sessionStore.readNotificationPreviewsEnabled() ?? true;
      _notificationBadgesEnabled =
          await _sessionStore.readNotificationBadgesEnabled() ?? true;
      _activityAutoRefreshEnabled =
          await _sessionStore.readActivityAutoRefreshEnabled() ?? true;
      _showRoomDetailsOnCards =
          await _sessionStore.readShowRoomDetailsOnCards() ?? true;
      _showContactInfoOnCards =
          await _sessionStore.readShowContactInfoOnCards() ?? true;
      _backendBaseUrlOverride = await _sessionStore.readBackendBaseUrl();
      final String? storedUserId = await _sessionStore.readUserId();
      await refreshData(restoredUserId: storedUserId);
    } on HostelRepositoryException catch (error) {
      _lastError = error.message;
      notifyListeners();
    }
  }

  Future<void> refreshData({
    String? restoredUserId,
    bool preserveCurrentUserOnMissing = false,
  }) async {
    _setLoading(true);
    try {
      final AppUser? previousUser = _currentUser;
      final String? activeUserId = restoredUserId ?? _currentUser?.id;
      _setupStatus = await _repository.getSetupStatus();
      _adminCatalog = await _repository.getCatalog();
      _blocks = _dedupeBlocks(await _repository.getBlocks());
      _rooms = _dedupeRooms(await _repository.getRooms());
      _students = await _repository.getStudents();
      _guests = await _repository.getGuests();
      _staffMembers = await _repository.getStaffMembers();
      _issues = activeUserId == null
          ? <IssueTicket>[]
          : await _repository.getIssues();
      _gatePasses = await _repository.getGatePasses();
      _parcels = await _repository.getParcels();
      _visitorEntries = await _repository.getVisitorEntries();
      _laundryBookings = await _repository.getLaundryBookings();
      _messMenu = await _repository.getMessMenu();
      _mealAttendance = await _repository.getMealAttendance();
      _foodFeedback = await _repository.getFoodFeedback();
      _notices = await _repository.getNotices();
      _roomRequests = await _repository.getRoomChangeRequests();
      _studentFeeSummaries.clear();
      _messBillsByUser.clear();
      _paymentHistoryByUser.clear();

      if (activeUserId != null) {
        try {
          _currentUser = await _repository.getUser(activeUserId);
        } on HostelRepositoryException catch (error) {
          final bool isMissingUser = error.message == 'User not found.';
          if (isMissingUser) {
            _currentUser =
                preserveCurrentUserOnMissing && previousUser?.id == activeUserId
                    ? previousUser
                    : null;
            if (_currentUser == null) {
              await _sessionStore.clear();
            }
          } else {
            rethrow;
          }
        }
      }
      _notifications = _currentUser == null
          ? <HostelNotificationItem>[]
          : await _repository.getNotifications(_currentUser!.id);
      _chatMessages = _currentUser == null
          ? <ChatMessage>[]
          : await _repository.getChatMessages(_currentUser!.id);
      _feeSettings = _currentUser?.canManageFeeSettings ?? false
          ? await _repository.getFeeSettings()
          : null;

      if (_currentUser?.role.isStudent ?? false) {
        _currentFeeSummary = await _repository.getFeeSummary(_currentUser!.id);
        _currentMessBill = await _repository.getMessBill(_currentUser!.id);
        _paymentHistoryByUser[_currentUser!.id] =
            await _repository.getPaymentHistory(_currentUser!.id);
      } else if (_currentUser?.canCollectFees ?? false) {
        _currentFeeSummary = null;
        _currentMessBill = null;
        for (final AppUser student in _students) {
          _studentFeeSummaries[student.id] =
              await _repository.getFeeSummary(student.id);
          _messBillsByUser[student.id] =
              await _repository.getMessBill(student.id);
          _paymentHistoryByUser[student.id] =
              await _repository.getPaymentHistory(student.id);
        }
      } else {
        _currentFeeSummary = null;
        _currentMessBill = null;
        if (_currentUser?.canManageMess ?? false) {
          for (final AppUser student in _students) {
            _messBillsByUser[student.id] = await _repository.getMessBill(
              student.id,
            );
          }
        }
      }
      _lastError = null;
    } on HostelRepositoryException catch (error) {
      _lastError = error.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> bootstrapAdmin({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _repository.bootstrapAdmin(
        username: username,
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );
      await _sessionStore.writeUserId(_currentUser!.id);
      await refreshData(
        restoredUserId: _currentUser!.id,
        preserveCurrentUserOnMissing: true,
      );
      _lastError = null;
    } on HostelRepositoryException {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _repository.login(
        identifier: identifier,
        password: password,
      );
      if (!(_currentUser?.emailVerified ?? true)) {
        _emailVerificationChallenge =
            await _repository.requestEmailVerification(
          email: _currentUser!.email,
        );
      } else {
        _emailVerificationChallenge = null;
      }
      await _sessionStore.writeUserId(_currentUser!.id);
      await refreshData(
        restoredUserId: _currentUser!.id,
        preserveCurrentUserOnMissing: true,
      );
      _lastError = null;
    } on HostelRepositoryException {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> registerStudent({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
    required String roomId,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _repository.registerStudent(
        username: username,
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        roomId: roomId,
      );
      _emailVerificationChallenge = await _repository.requestEmailVerification(
        email: _currentUser!.email,
      );
      await _sessionStore.writeUserId(_currentUser!.id);
      await refreshData(
        restoredUserId: _currentUser!.id,
        preserveCurrentUserOnMissing: true,
      );
      _lastError = null;
    } on HostelRepositoryException {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> registerGuest({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _repository.registerGuest(
        username: username,
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );
      _emailVerificationChallenge = await _repository.requestEmailVerification(
        email: _currentUser!.email,
      );
      await _sessionStore.writeUserId(_currentUser!.id);
      await refreshData(
        restoredUserId: _currentUser!.id,
        preserveCurrentUserOnMissing: true,
      );
      _lastError = null;
    } on HostelRepositoryException {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createIssue({
    required String category,
    required String comment,
  }) async {
    final AppUser? user = _currentUser;
    if (user == null) {
      return;
    }
    final IssueTicket issue = await _repository.createIssue(
      studentId: user.id,
      category: category,
      comment: comment,
    );
    _issues = <IssueTicket>[issue, ..._issues];
    notifyListeners();
  }

  Future<void> createNotice({
    required String title,
    required String message,
    required String category,
    bool isPinned = false,
  }) async {
    final NoticeItem notice = await _repository.createNotice(
      title: title,
      message: message,
      category: category,
      isPinned: isPinned,
    );
    _notices = <NoticeItem>[notice, ..._notices]
      ..sort((NoticeItem a, NoticeItem b) {
        if (a.isPinned != b.isPinned) {
          return a.isPinned ? -1 : 1;
        }
        return b.postedAt.compareTo(a.postedAt);
      });
    notifyListeners();
    unawaited(_refreshNotificationsIfAuthenticated());
  }

  Future<void> markNotificationRead(String notificationId) async {
    final HostelNotificationItem updated =
        await _repository.markNotificationRead(notificationId);
    final int index = _notifications.indexWhere(
      (HostelNotificationItem item) => item.id == notificationId,
    );
    if (index == -1) {
      _notifications = <HostelNotificationItem>[updated, ..._notifications];
    } else {
      _notifications[index] = updated;
    }
    notifyListeners();
  }

  Future<void> markAllNotificationsRead() async {
    final AppUser? user = _currentUser;
    if (user == null) {
      return;
    }
    await _repository.markAllNotificationsRead(user.id);
    _notifications = _notifications
        .map(
          (HostelNotificationItem item) =>
              item.isRead ? item : item.copyWith(readAt: DateTime.now()),
        )
        .toList(growable: false);
    notifyListeners();
  }

  Future<void> createGatePass({
    required String destination,
    required String reason,
    required String emergencyContact,
    required DateTime departureAt,
    required DateTime expectedReturnAt,
  }) async {
    final AppUser? user = _currentUser;
    if (user == null) {
      return;
    }
    final GatePassRequest gatePass = await _repository.createGatePass(
      studentId: user.id,
      destination: destination,
      reason: reason,
      emergencyContact: emergencyContact,
      departureAt: departureAt,
      expectedReturnAt: expectedReturnAt,
    );
    _gatePasses = <GatePassRequest>[gatePass, ..._gatePasses];
    notifyListeners();
    unawaited(_refreshNotificationsIfAuthenticated());
  }

  Future<void> reviewGatePass({
    required String gatePassId,
    required GatePassStatus status,
  }) async {
    final GatePassRequest updated = await _repository.reviewGatePass(
      gatePassId: gatePassId,
      status: status,
    );
    _replaceGatePass(updated);
    notifyListeners();
    unawaited(_refreshNotificationsIfAuthenticated());
  }

  Future<void> markGatePassDeparture(String gatePassId) async {
    final GatePassRequest updated =
        await _repository.markGatePassDeparture(gatePassId);
    _replaceGatePass(updated);
    notifyListeners();
    unawaited(_refreshNotificationsIfAuthenticated());
  }

  Future<void> markGatePassReturn(String gatePassId) async {
    final GatePassRequest updated =
        await _repository.markGatePassReturn(gatePassId);
    _replaceGatePass(updated);
    notifyListeners();
    unawaited(_refreshNotificationsIfAuthenticated());
  }

  Future<void> createParcel({
    required String userId,
    required String carrier,
    required String trackingCode,
    required String note,
  }) async {
    _setLoading(true);
    try {
      await _repository.createParcel(
        userId: userId,
        carrier: carrier,
        trackingCode: trackingCode,
        note: note,
      );
      await refreshData();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markParcelCollected(String parcelId) async {
    _setLoading(true);
    try {
      await _repository.markParcelCollected(parcelId);
      await refreshData();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createVisitorEntry({
    required String studentId,
    required String visitorName,
    required String relation,
    required String note,
  }) async {
    _setLoading(true);
    try {
      await _repository.createVisitorEntry(
        studentId: studentId,
        visitorName: visitorName,
        relation: relation,
        note: note,
      );
      await refreshData();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> checkOutVisitor(String visitorId) async {
    _setLoading(true);
    try {
      await _repository.checkOutVisitor(visitorId);
      await refreshData();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createLaundryBooking({
    required DateTime scheduledAt,
    required String slotLabel,
    required String machineLabel,
    required String notes,
  }) async {
    final AppUser? user = _currentUser;
    if (user == null) {
      return;
    }
    final LaundryBooking booking = await _repository.createLaundryBooking(
      userId: user.id,
      scheduledAt: scheduledAt,
      slotLabel: slotLabel,
      machineLabel: machineLabel,
      notes: notes,
    );
    _laundryBookings = <LaundryBooking>[booking, ..._laundryBookings]..sort(
        (LaundryBooking a, LaundryBooking b) =>
            a.scheduledAt.compareTo(b.scheduledAt),
      );
    notifyListeners();
  }

  Future<void> updateLaundryBookingStatus({
    required String bookingId,
    required LaundryBookingStatus status,
  }) async {
    final LaundryBooking booking = await _repository.updateLaundryBookingStatus(
      bookingId: bookingId,
      status: status,
    );
    final int index = _laundryBookings.indexWhere(
      (LaundryBooking item) => item.id == bookingId,
    );
    if (index != -1) {
      _laundryBookings[index] = booking;
      notifyListeners();
    }
  }

  Future<void> updateMessMenuDay({
    required MessDay day,
    required String breakfast,
    required String lunch,
    required String dinner,
  }) async {
    _setLoading(true);
    try {
      await _repository.updateMessMenuDay(
        day: day,
        breakfast: breakfast,
        lunch: lunch,
        dinner: dinner,
      );
      await refreshData();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markMealAttendance({
    required MessDay day,
    required MealType mealType,
    required bool attended,
  }) async {
    final AppUser? user = _currentUser;
    if (user == null) {
      return;
    }
    _setLoading(true);
    try {
      await _repository.markMealAttendance(
        userId: user.id,
        day: day,
        mealType: mealType,
        attended: attended,
      );
      await refreshData();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> submitFoodFeedback({
    required int rating,
    required String comment,
  }) async {
    final AppUser? user = _currentUser;
    if (user == null) {
      return;
    }
    _setLoading(true);
    try {
      await _repository.submitFoodFeedback(
        userId: user.id,
        rating: rating,
        comment: comment,
      );
      await refreshData();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createBlock({
    required String code,
    required String name,
    String? description,
  }) async {
    _setLoading(true);
    try {
      await _repository.createBlock(
        code: code,
        name: name,
        description: description,
      );
      await refreshData();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createRoom({
    required String block,
    required String number,
    required int capacity,
    required String roomType,
  }) async {
    _setLoading(true);
    try {
      await _repository.createRoom(
        block: block,
        number: number,
        capacity: capacity,
        roomType: roomType,
      );
      await refreshData();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> assignResidentRoom({
    required String userId,
    required String roomId,
  }) async {
    _setLoading(true);
    try {
      await _repository.assignResidentRoom(
        userId: userId,
        roomId: roomId,
      );
      await refreshData();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateIssueStatus({
    required String issueId,
    required IssueStatus status,
  }) async {
    final AppUser? user = _currentUser;
    IssueTicket? currentIssue;
    for (final IssueTicket item in _issues) {
      if (item.id == issueId) {
        currentIssue = item;
        break;
      }
    }
    final bool canUpdate = user != null &&
        user.canWorkOnIssues &&
        (user.canManageIssues || currentIssue?.assignedStaffId == user.id);
    if (!canUpdate) {
      throw const HostelRepositoryException(
        'Only the assigned staff member, admin, or warden can update this issue.',
      );
    }
    final IssueTicket issue =
        await _repository.updateIssueStatus(issueId: issueId, status: status);
    _replaceIssue(issue);
    notifyListeners();
  }

  Future<void> assignIssue({
    required String issueId,
    required String staffId,
  }) async {
    final AppUser? user = _currentUser;
    if (user == null || !user.canAssignIssues) {
      throw const HostelRepositoryException(
        'Only admin and wardens can assign issues.',
      );
    }
    final IssueTicket issue = await _repository.assignIssue(
      issueId: issueId,
      staffId: staffId,
    );
    _replaceIssue(issue);
    notifyListeners();
  }

  Future<void> createStaff({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
    required String jobTitle,
  }) async {
    _setLoading(true);
    try {
      await _repository.createStaff(
        username: username,
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        jobTitle: jobTitle,
      );
      await refreshData();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteStaff(String staffId) async {
    _setLoading(true);
    try {
      await _repository.deleteStaff(staffId);
      await refreshData();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> prepareCleanWorkspace() async {
    final AppUser? user = _currentUser;
    if (user == null || user.role != UserRole.admin) {
      return;
    }
    _setLoading(true);
    try {
      await _repository.prepareCleanWorkspace(adminId: user.id);
      await refreshData(restoredUserId: user.id);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createRoomChangeRequest({
    required String desiredRoomId,
    required String reason,
  }) async {
    final AppUser? user = _currentUser;
    if (user == null) {
      return;
    }
    _setLoading(true);
    try {
      await _repository.createRoomChangeRequest(
        studentId: user.id,
        desiredRoomId: desiredRoomId,
        reason: reason,
      );
      await refreshData();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateRoomRequestStatus({
    required String requestId,
    required RoomRequestStatus status,
  }) async {
    final RoomChangeRequest request =
        await _repository.updateRoomChangeRequestStatus(
      requestId: requestId,
      status: status,
    );
    final int index = _roomRequests.indexWhere(
      (RoomChangeRequest item) => item.id == requestId,
    );
    if (index != -1) {
      _roomRequests[index] = request;
    }
    notifyListeners();
    unawaited(refreshData());
  }

  Future<void> updateFeeSettings({
    required int maintenanceCharge,
    required int parkingCharge,
    required int waterCharge,
    required int singleOccupancyCharge,
    required int doubleSharingCharge,
    required int tripleSharingCharge,
    required List<FeeChargeItem> customCharges,
  }) async {
    if (!(_currentUser?.canManageFeeSettings ?? false)) {
      return;
    }
    _setLoading(true);
    try {
      await _repository.updateFeeSettings(
        maintenanceCharge: maintenanceCharge,
        parkingCharge: parkingCharge,
        waterCharge: waterCharge,
        singleOccupancyCharge: singleOccupancyCharge,
        doubleSharingCharge: doubleSharingCharge,
        tripleSharingCharge: tripleSharingCharge,
        customCharges: customCharges,
      );
      await refreshData();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateAdminCatalog(AdminCatalog catalog) async {
    if (!(_currentUser?.isAdmin ?? false)) {
      return;
    }
    _setLoading(true);
    try {
      _adminCatalog = await _repository.updateAdminCatalog(catalog);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<PaymentRecord?> payCurrentFee({
    required PaymentMethod method,
  }) async {
    final AppUser? user = _currentUser;
    if (user == null || !user.role.isStudent) {
      return null;
    }
    final PaymentRecord payment =
        await _repository.payFee(userId: user.id, method: method);
    _prependPayment(payment);
    if (_currentFeeSummary != null) {
      _currentFeeSummary = _currentFeeSummary!.copyWith(
        paidAmount: _currentFeeSummary!.total,
      );
    }
    if (_studentFeeSummaries.containsKey(user.id)) {
      final FeeSummary summary = _studentFeeSummaries[user.id]!;
      _studentFeeSummaries[user.id] = summary.copyWith(
        paidAmount: summary.total,
      );
    }
    notifyListeners();
    return payment;
  }

  Future<PaymentRecord?> collectFeeForResident({
    required String userId,
    required PaymentMethod method,
  }) async {
    if (!(_currentUser?.canCollectFees ?? false)) {
      return null;
    }
    final PaymentRecord payment =
        await _repository.payFee(userId: userId, method: method);
    _prependPayment(payment);
    final FeeSummary? summary = _studentFeeSummaries[userId];
    if (summary != null) {
      _studentFeeSummaries[userId] = summary.copyWith(
        paidAmount: summary.total,
      );
    }
    if (_currentUser?.id == userId && _currentFeeSummary != null) {
      _currentFeeSummary = _currentFeeSummary!.copyWith(
        paidAmount: _currentFeeSummary!.total,
      );
    }
    notifyListeners();
    return payment;
  }

  Future<FeeSummary?> sendFeeReminder(String userId) async {
    final FeeSummary summary = await _repository.sendFeeReminder(userId);
    _studentFeeSummaries[userId] = summary;
    if (_currentUser?.id == userId) {
      _currentFeeSummary = summary;
    }
    notifyListeners();
    return summary;
  }

  Future<void> sendChatMessage({
    required String recipientId,
    required String message,
  }) async {
    final AppUser? user = _currentUser;
    if (user == null) {
      return;
    }
    final ChatMessage chatMessage = await _repository.sendChatMessage(
      senderId: user.id,
      recipientId: recipientId,
      message: message,
    );
    _chatMessages = <ChatMessage>[..._chatMessages, chatMessage]
      ..sort((ChatMessage a, ChatMessage b) => a.sentAt.compareTo(b.sentAt));
    notifyListeners();
    unawaited(_refreshNotificationsIfAuthenticated());
  }

  Future<void> markChatThreadRead(String partnerId) async {
    final AppUser? user = _currentUser;
    if (user == null) {
      return;
    }
    await _repository.markChatThreadRead(
      userId: user.id,
      partnerId: partnerId,
    );
    _chatMessages = _chatMessages.map((ChatMessage message) {
      if (message.recipientId == user.id &&
          message.senderId == partnerId &&
          !message.isRead) {
        return message.copyWith(readAt: DateTime.now());
      }
      return message;
    }).toList(growable: false);
    notifyListeners();
  }

  Future<AuthChallenge?> requestEmailVerification() async {
    final AppUser? user = _currentUser;
    if (user == null) {
      return null;
    }
    final AuthChallenge challenge = await _repository.requestEmailVerification(
      email: user.email,
    );
    _emailVerificationChallenge = challenge;
    notifyListeners();
    return challenge;
  }

  Future<AppUser?> verifyCurrentUserEmail(String code) async {
    final AppUser? user = _currentUser;
    if (user == null) {
      return null;
    }
    final AppUser updatedUser = await _repository.verifyEmail(
      email: user.email,
      code: code,
    );
    _emailVerificationChallenge = null;
    _replaceUser(updatedUser);
    _currentUser = updatedUser;
    notifyListeners();
    return updatedUser;
  }

  Future<AuthChallenge> requestPasswordReset({
    required String email,
  }) async {
    final AuthChallenge challenge = await _repository.requestPasswordReset(
      email: email,
    );
    _passwordResetChallenge = challenge;
    notifyListeners();
    return challenge;
  }

  Future<AppUser> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final AppUser updatedUser = await _repository.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
    _passwordResetChallenge = null;
    _replaceUser(updatedUser);
    if (_currentUser?.id == updatedUser.id) {
      _currentUser = updatedUser;
    }
    notifyListeners();
    return updatedUser;
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) {
      return;
    }
    _themeMode = themeMode;
    notifyListeners();
    await _sessionStore.writeThemeMode(themeMode.name);
  }

  Future<void> setInAppNotificationsEnabled(bool value) async {
    if (_inAppNotificationsEnabled == value) {
      return;
    }
    _inAppNotificationsEnabled = value;
    notifyListeners();
    await _sessionStore.writeInAppNotificationsEnabled(value);
  }

  Future<void> setNotificationPreviewsEnabled(bool value) async {
    if (_notificationPreviewsEnabled == value) {
      return;
    }
    _notificationPreviewsEnabled = value;
    notifyListeners();
    await _sessionStore.writeNotificationPreviewsEnabled(value);
  }

  Future<void> setNotificationBadgesEnabled(bool value) async {
    if (_notificationBadgesEnabled == value) {
      return;
    }
    _notificationBadgesEnabled = value;
    notifyListeners();
    await _sessionStore.writeNotificationBadgesEnabled(value);
  }

  Future<void> setActivityAutoRefreshEnabled(bool value) async {
    if (_activityAutoRefreshEnabled == value) {
      return;
    }
    _activityAutoRefreshEnabled = value;
    notifyListeners();
    await _sessionStore.writeActivityAutoRefreshEnabled(value);
  }

  Future<void> setShowRoomDetailsOnCards(bool value) async {
    if (_showRoomDetailsOnCards == value) {
      return;
    }
    _showRoomDetailsOnCards = value;
    notifyListeners();
    await _sessionStore.writeShowRoomDetailsOnCards(value);
  }

  Future<void> setShowContactInfoOnCards(bool value) async {
    if (_showContactInfoOnCards == value) {
      return;
    }
    _showContactInfoOnCards = value;
    notifyListeners();
    await _sessionStore.writeShowContactInfoOnCards(value);
  }

  Future<void> resetAppPreferences() async {
    _themeMode = ThemeMode.system;
    _inAppNotificationsEnabled = true;
    _notificationPreviewsEnabled = true;
    _notificationBadgesEnabled = true;
    _activityAutoRefreshEnabled = true;
    _showRoomDetailsOnCards = true;
    _showContactInfoOnCards = true;
    notifyListeners();
    await _sessionStore.clearAppPreferences();
  }

  Future<void> setBackendBaseUrlOverride(String? value) async {
    final String? normalized = _normalizeBackendBaseUrl(value);
    if (normalized == _backendBaseUrlOverride) {
      return;
    }
    _backendBaseUrlOverride = normalized;
    if (normalized == null) {
      await _sessionStore.clearBackendBaseUrl();
    } else {
      await _sessionStore.writeBackendBaseUrl(normalized);
    }
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _feeSettings = null;
    _currentFeeSummary = null;
    _currentMessBill = null;
    _notifications = <HostelNotificationItem>[];
    _chatMessages = <ChatMessage>[];
    _emailVerificationChallenge = null;
    _passwordResetChallenge = null;
    _studentFeeSummaries.clear();
    _messBillsByUser.clear();
    _paymentHistoryByUser.clear();
    _lastError = null;
    unawaited(_sessionStore.clear());
    notifyListeners();
  }

  String? _normalizeBackendBaseUrl(String? value) {
    if (value == null) {
      return null;
    }
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }

  void _replaceIssue(IssueTicket issue) {
    final int index =
        _issues.indexWhere((IssueTicket item) => item.id == issue.id);
    if (index == -1) {
      _issues = <IssueTicket>[issue, ..._issues];
      return;
    }
    _issues[index] = issue;
  }

  void _replaceGatePass(GatePassRequest gatePass) {
    final int index = _gatePasses
        .indexWhere((GatePassRequest item) => item.id == gatePass.id);
    if (index == -1) {
      _gatePasses = <GatePassRequest>[gatePass, ..._gatePasses];
      return;
    }
    _gatePasses[index] = gatePass;
  }

  void _prependPayment(PaymentRecord payment) {
    _paymentHistoryByUser[payment.userId] = <PaymentRecord>[
      payment,
      ...?_paymentHistoryByUser[payment.userId],
    ];
  }

  Future<void> _refreshNotificationsIfAuthenticated() async {
    await refreshActivityFeed();
  }

  Future<void> refreshActivityFeed() async {
    final AppUser? user = _currentUser;
    if (user == null || _isLoading) {
      return;
    }
    try {
      _notifications = await _repository.getNotifications(user.id);
      _chatMessages = await _repository.getChatMessages(user.id);
      notifyListeners();
    } on HostelRepositoryException {
      // Keep the last loaded snapshot during passive background sync failures.
    } catch (_) {
      // Keep the last loaded snapshot during passive background sync failures.
    }
  }

  void _replaceUser(AppUser user) {
    final int studentIndex =
        _students.indexWhere((AppUser item) => item.id == user.id);
    if (studentIndex != -1) {
      _students[studentIndex] = user;
    }
    final int guestIndex =
        _guests.indexWhere((AppUser item) => item.id == user.id);
    if (guestIndex != -1) {
      _guests[guestIndex] = user;
    }
    final int staffIndex =
        _staffMembers.indexWhere((AppUser item) => item.id == user.id);
    if (staffIndex != -1) {
      _staffMembers[staffIndex] = user;
    }
  }

  ThemeMode _themeModeFromName(String? name) {
    if (name == null || name.isEmpty) {
      return ThemeMode.system;
    }
    try {
      return ThemeMode.values.byName(name);
    } catch (_) {
      return ThemeMode.system;
    }
  }
}
