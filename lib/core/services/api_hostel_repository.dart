import 'dart:async';

import 'package:http/http.dart' as http;

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
import 'api_service.dart';
import 'hostel_repository.dart';
import 'secure_storage.dart';

class ApiHostelRepository implements HostelRepository {
  ApiHostelRepository({
    String? baseUrl,
    http.Client? client,
    TokenStorage? tokenStorage,
    ApiService? apiService,
  }) : _api = apiService ??
            ApiService(
              baseUrl: baseUrl,
              client: client,
              tokenStorage: tokenStorage,
            );

  final ApiService _api;

  @override
  Future<SetupStatus> getSetupStatus() async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'GET',
      path: '/setup/status',
    );
    return _parseSetupStatus(payload);
  }

  @override
  Future<AppUser> login({
    required String identifier,
    required String password,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'POST',
      path: '/auth/login',
      body: <String, dynamic>{
        'identifier': identifier.trim(),
        'password': password.trim(),
      },
    );
    await _persistAuthTokenFromPayload(payload);
    return _parseUser(payload);
  }

  @override
  Future<AppUser> bootstrapAdmin({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'POST',
      path: '/auth/bootstrap-admin',
      body: <String, dynamic>{
        'username': username.trim(),
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'password': password.trim(),
        'phoneNumber': phoneNumber.trim(),
      },
    );
    await _persistAuthTokenFromPayload(payload);
    return _parseUser(payload);
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
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'POST',
      path: '/auth/register',
      body: <String, dynamic>{
        'username': username.trim(),
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'password': password.trim(),
        'phoneNumber': phoneNumber.trim(),
        'roomId': roomId,
      },
    );
    await _persistAuthTokenFromPayload(payload);
    return _parseUser(payload);
  }

  @override
  Future<AppUser> registerGuest({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'POST',
      path: '/auth/register-guest',
      body: <String, dynamic>{
        'username': username.trim(),
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'password': password.trim(),
        'phoneNumber': phoneNumber.trim(),
      },
    );
    await _persistAuthTokenFromPayload(payload);
    return _parseUser(payload);
  }

  @override
  Future<AuthChallenge> requestEmailVerification({
    required String email,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'POST',
      path: '/auth/verify-email/request',
      body: <String, dynamic>{'email': email.trim()},
    );
    return _parseAuthChallenge(payload);
  }

  @override
  Future<AppUser> verifyEmail({
    required String email,
    required String code,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'POST',
      path: '/auth/verify-email/confirm',
      body: <String, dynamic>{
        'email': email.trim(),
        'code': code.trim(),
      },
    );
    await _persistAuthTokenFromPayload(payload);
    return _parseUser(payload);
  }

  @override
  Future<AuthChallenge> requestPasswordReset({
    required String email,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'POST',
      path: '/auth/password-reset/request',
      body: <String, dynamic>{'email': email.trim()},
    );
    return _parseAuthChallenge(payload);
  }

  @override
  Future<AppUser> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'POST',
      path: '/auth/password-reset/confirm',
      body: <String, dynamic>{
        'email': email.trim(),
        'code': code.trim(),
        'newPassword': newPassword.trim(),
      },
    );
    await _persistAuthTokenFromPayload(payload);
    return _parseUser(payload);
  }

  @override
  Future<AppUser> getUser(String userId) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'GET',
      path: '/users/$userId',
    );
    return _parseUser(payload);
  }

  @override
  Future<List<AppUser>> getStudents() async {
    final List<dynamic> payload = await _requestList(
      method: 'GET',
      path: '/students',
    );
    return payload
        .map((dynamic user) => _parseUser(user as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<List<AppUser>> getGuests() async {
    final List<dynamic> payload = await _requestList(
      method: 'GET',
      path: '/guests',
    );
    return payload
        .map((dynamic user) => _parseUser(user as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<List<AppUser>> getStaffMembers() async {
    final List<dynamic> payload = await _requestList(
      method: 'GET',
      path: '/staff',
    );
    return payload
        .map((dynamic user) => _parseUser(user as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<List<ChatMessage>> getChatMessages(String userId) async {
    final List<dynamic> payload = await _requestList(
      method: 'GET',
      path: '/chat/$userId',
    );
    return payload
        .map((dynamic item) => _parseChatMessage(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<ChatMessage> sendChatMessage({
    required String senderId,
    required String recipientId,
    required String message,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'POST',
      path: '/chat',
      body: <String, dynamic>{
        'senderId': senderId,
        'recipientId': recipientId,
        'message': message.trim(),
      },
    );
    return _parseChatMessage(payload);
  }

  @override
  Future<void> markChatThreadRead({
    required String userId,
    required String partnerId,
  }) async {
    await _request(
      method: 'PATCH',
      path: '/chat/read',
      body: <String, dynamic>{
        'userId': userId,
        'partnerId': partnerId,
      },
    );
  }

  @override
  Future<List<HostelNotificationItem>> getNotifications(String userId) async {
    final List<dynamic> payload = await _requestList(
      method: 'GET',
      path: '/notifications/$userId',
    );
    return payload
        .map(
          (dynamic item) => _parseNotification(item as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  @override
  Future<HostelNotificationItem> markNotificationRead(
    String notificationId,
  ) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'PATCH',
      path: '/notifications/$notificationId/read',
      body: const <String, dynamic>{},
    );
    return _parseNotification(payload);
  }

  @override
  Future<void> markAllNotificationsRead(String userId) async {
    await _request(
      method: 'PATCH',
      path: '/notifications/$userId/read-all',
      body: const <String, dynamic>{},
    );
  }

  @override
  Future<List<HostelBlock>> getBlocks() async {
    final List<dynamic> payload = await _requestList(
      method: 'GET',
      path: '/blocks',
    );
    return payload
        .map((dynamic block) => _parseBlock(block as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<HostelBlock> createBlock({
    required String code,
    required String name,
    String? description,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'POST',
      path: '/blocks',
      body: <String, dynamic>{
        'code': code.trim(),
        'name': name.trim(),
        'description': description?.trim(),
      },
    );
    return _parseBlock(payload);
  }

  @override
  Future<List<HostelRoom>> getRooms() async {
    final List<dynamic> payload = await _requestList(
      method: 'GET',
      path: '/rooms',
    );
    return payload
        .map((dynamic room) => _parseRoom(room as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<HostelRoom> createRoom({
    required String block,
    required String number,
    required int capacity,
    required String roomType,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'POST',
      path: '/rooms',
      body: <String, dynamic>{
        'block': block.trim(),
        'number': number.trim(),
        'capacity': capacity,
        'roomType': roomType.trim(),
      },
    );
    return _parseRoom(payload);
  }

  @override
  Future<AppUser> assignResidentRoom({
    required String userId,
    required String roomId,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'PATCH',
      path: '/students/$userId/room',
      body: <String, dynamic>{'roomId': roomId},
    );
    return _parseUser(payload);
  }

  @override
  Future<List<IssueTicket>> getIssues() async {
    final List<dynamic> payload = await _requestList(
      method: 'GET',
      path: '/issues',
    );
    return payload
        .map((dynamic issue) => _parseIssue(issue as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<List<GatePassRequest>> getGatePasses() async {
    final List<dynamic> payload = await _requestList(
      method: 'GET',
      path: '/gate-passes',
    );
    return payload
        .map((dynamic item) => _parseGatePass(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<GatePassRequest> createGatePass({
    required String studentId,
    required String destination,
    required String reason,
    required String emergencyContact,
    required DateTime departureAt,
    required DateTime expectedReturnAt,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'POST',
      path: '/gate-passes',
      body: <String, dynamic>{
        'studentId': studentId,
        'destination': destination.trim(),
        'reason': reason.trim(),
        'emergencyContact': emergencyContact.trim(),
        'departureAt': departureAt.toIso8601String(),
        'expectedReturnAt': expectedReturnAt.toIso8601String(),
      },
    );
    return _parseGatePass(payload);
  }

  @override
  Future<GatePassRequest> reviewGatePass({
    required String gatePassId,
    required GatePassStatus status,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'PATCH',
      path: '/gate-passes/$gatePassId/review',
      body: <String, dynamic>{'status': status.name},
    );
    return _parseGatePass(payload);
  }

  @override
  Future<GatePassRequest> markGatePassDeparture(String gatePassId) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'PATCH',
      path: '/gate-passes/$gatePassId/checkout',
      body: const <String, dynamic>{},
    );
    return _parseGatePass(payload);
  }

  @override
  Future<GatePassRequest> markGatePassReturn(String gatePassId) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'PATCH',
      path: '/gate-passes/$gatePassId/return',
      body: const <String, dynamic>{},
    );
    return _parseGatePass(payload);
  }

  @override
  Future<List<ParcelItem>> getParcels() async {
    final List<dynamic> payload = await _requestList(
      method: 'GET',
      path: '/parcels',
    );
    return payload
        .map((dynamic item) => _parseParcel(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<ParcelItem> createParcel({
    required String userId,
    required String carrier,
    required String trackingCode,
    required String note,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'POST',
      path: '/parcels',
      body: <String, dynamic>{
        'userId': userId,
        'carrier': carrier.trim(),
        'trackingCode': trackingCode.trim(),
        'note': note.trim(),
      },
    );
    return _parseParcel(payload);
  }

  @override
  Future<ParcelItem> markParcelCollected(String parcelId) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'PATCH',
      path: '/parcels/$parcelId/collect',
      body: const <String, dynamic>{},
    );
    return _parseParcel(payload);
  }

  @override
  Future<List<VisitorEntry>> getVisitorEntries() async {
    final List<dynamic> payload = await _requestList(
      method: 'GET',
      path: '/visitors',
    );
    return payload
        .map((dynamic item) => _parseVisitorEntry(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<VisitorEntry> createVisitorEntry({
    required String studentId,
    required String visitorName,
    required String relation,
    required String note,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'POST',
      path: '/visitors',
      body: <String, dynamic>{
        'studentId': studentId,
        'visitorName': visitorName.trim(),
        'relation': relation.trim(),
        'note': note.trim(),
      },
    );
    return _parseVisitorEntry(payload);
  }

  @override
  Future<VisitorEntry> checkOutVisitor(String visitorId) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'PATCH',
      path: '/visitors/$visitorId/checkout',
      body: const <String, dynamic>{},
    );
    return _parseVisitorEntry(payload);
  }

  @override
  Future<List<LaundryBooking>> getLaundryBookings() async {
    final List<dynamic> payload = await _requestList(
      method: 'GET',
      path: '/laundry-bookings',
    );
    return payload
        .map((dynamic item) =>
            _parseLaundryBooking(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<LaundryBooking> createLaundryBooking({
    required String userId,
    required DateTime scheduledAt,
    required String slotLabel,
    required String machineLabel,
    required String notes,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'POST',
      path: '/laundry-bookings',
      body: <String, dynamic>{
        'userId': userId,
        'scheduledAt': scheduledAt.toIso8601String(),
        'slotLabel': slotLabel.trim(),
        'machineLabel': machineLabel.trim(),
        'notes': notes.trim(),
      },
    );
    return _parseLaundryBooking(payload);
  }

  @override
  Future<LaundryBooking> updateLaundryBookingStatus({
    required String bookingId,
    required LaundryBookingStatus status,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'PATCH',
      path: '/laundry-bookings/$bookingId',
      body: <String, dynamic>{'status': status.value},
    );
    return _parseLaundryBooking(payload);
  }

  @override
  Future<List<MessMenuDay>> getMessMenu() async {
    final List<dynamic> payload = await _requestList(
      method: 'GET',
      path: '/mess/menu',
    );
    return payload
        .map(
          (dynamic item) => _parseMessMenuDay(item as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  @override
  Future<MessMenuDay> updateMessMenuDay({
    required MessDay day,
    required String breakfast,
    required String lunch,
    required String dinner,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'PATCH',
      path: '/mess/menu/${day.name}',
      body: <String, dynamic>{
        'breakfast': breakfast.trim(),
        'lunch': lunch.trim(),
        'dinner': dinner.trim(),
      },
    );
    return _parseMessMenuDay(payload);
  }

  @override
  Future<List<MealAttendanceDay>> getMealAttendance() async {
    final List<dynamic> payload = await _requestList(
      method: 'GET',
      path: '/mess/attendance',
    );
    return payload
        .map(
          (dynamic item) => _parseMealAttendance(item as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  @override
  Future<MealAttendanceDay> markMealAttendance({
    required String userId,
    required MessDay day,
    required MealType mealType,
    required bool attended,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'POST',
      path: '/mess/attendance',
      body: <String, dynamic>{
        'userId': userId,
        'day': day.name,
        'mealType': mealType.name,
        'attended': attended,
      },
    );
    return _parseMealAttendance(payload);
  }

  @override
  Future<List<FoodFeedback>> getFoodFeedback() async {
    final List<dynamic> payload = await _requestList(
      method: 'GET',
      path: '/mess/feedback',
    );
    return payload
        .map(
          (dynamic item) => _parseFoodFeedback(item as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  @override
  Future<FoodFeedback> submitFoodFeedback({
    required String userId,
    required int rating,
    required String comment,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'POST',
      path: '/mess/feedback',
      body: <String, dynamic>{
        'userId': userId,
        'rating': rating,
        'comment': comment.trim(),
      },
    );
    return _parseFoodFeedback(payload);
  }

  @override
  Future<MessBillSummary> getMessBill(String userId) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'GET',
      path: '/mess/bill/$userId',
    );
    return _parseMessBill(payload);
  }

  @override
  Future<List<NoticeItem>> getNotices() async {
    final List<dynamic> payload = await _requestList(
      method: 'GET',
      path: '/notices',
    );
    return payload
        .map(
          (dynamic notice) => _parseNotice(notice as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  @override
  Future<NoticeItem> createNotice({
    required String title,
    required String message,
    required String category,
    bool isPinned = false,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'POST',
      path: '/notices',
      body: <String, dynamic>{
        'title': title.trim(),
        'message': message.trim(),
        'category': category.trim(),
        'isPinned': isPinned,
      },
    );
    return _parseNotice(payload);
  }

  @override
  Future<IssueTicket> createIssue({
    required String studentId,
    required String category,
    required String comment,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'POST',
      path: '/issues',
      body: <String, dynamic>{
        'studentId': studentId,
        'category': category.trim(),
        'comment': comment.trim(),
      },
    );
    return _parseIssue(payload);
  }

  @override
  Future<IssueTicket> updateIssueStatus({
    required String issueId,
    required IssueStatus status,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'PATCH',
      path: '/issues/$issueId',
      body: <String, dynamic>{'status': status.name},
    );
    return _parseIssue(payload);
  }

  @override
  Future<IssueTicket> assignIssue({
    required String issueId,
    required String staffId,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'PATCH',
      path: '/issues/$issueId/assign',
      body: <String, dynamic>{'staffId': staffId},
    );
    return _parseIssue(payload);
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
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'POST',
      path: '/staff',
      body: <String, dynamic>{
        'username': username.trim(),
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'password': password.trim(),
        'phoneNumber': phoneNumber.trim(),
        'jobTitle': jobTitle.trim(),
      },
    );
    return _parseUser(payload);
  }

  @override
  Future<void> deleteStaff(String staffId) async {
    await _request(
      method: 'DELETE',
      path: '/staff/$staffId',
    );
  }

  @override
  Future<void> prepareCleanWorkspace({
    required String adminId,
  }) async {
    await _request(
      method: 'PATCH',
      path: '/admin/prepare-clean-workspace',
      body: <String, dynamic>{'adminId': adminId},
    );
  }

  @override
  Future<List<RoomChangeRequest>> getRoomChangeRequests() async {
    final List<dynamic> payload = await _requestList(
      method: 'GET',
      path: '/room-change-requests',
    );
    return payload
        .map(
          (dynamic request) =>
              _parseRoomRequest(request as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  @override
  Future<RoomChangeRequest> createRoomChangeRequest({
    required String studentId,
    required String desiredRoomId,
    required String reason,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'POST',
      path: '/room-change-requests',
      body: <String, dynamic>{
        'studentId': studentId,
        'desiredRoomId': desiredRoomId,
        'reason': reason.trim(),
      },
    );
    return _parseRoomRequest(payload);
  }

  @override
  Future<RoomChangeRequest> updateRoomChangeRequestStatus({
    required String requestId,
    required RoomRequestStatus status,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'PATCH',
      path: '/room-change-requests/$requestId',
      body: <String, dynamic>{'status': status.name},
    );
    return _parseRoomRequest(payload);
  }

  @override
  Future<FeeSummary> getFeeSummary(String userId) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'GET',
      path: '/fees/$userId',
    );
    return _parseFeeSummary(payload);
  }

  @override
  Future<List<PaymentRecord>> getPaymentHistory(String userId) async {
    final List<dynamic> payload = await _requestList(
      method: 'GET',
      path: '/payments/$userId',
    );
    return payload
        .map(
          (dynamic payment) => _parsePayment(payment as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  @override
  Future<PaymentRecord> payFee({
    required String userId,
    required PaymentMethod method,
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'POST',
      path: '/payments',
      body: <String, dynamic>{
        'userId': userId,
        'paymentMethod': method.name,
      },
    );
    return _parsePayment(payload);
  }

  @override
  Future<FeeSummary> sendFeeReminder(String userId) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'POST',
      path: '/fees/$userId/reminder',
      body: const <String, dynamic>{},
    );
    return _parseFeeSummary(payload);
  }

  @override
  Future<FeeSettings> getFeeSettings() async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'GET',
      path: '/fee-settings',
    );
    return _parseFeeSettings(payload);
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
  }) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'PATCH',
      path: '/fee-settings',
      body: <String, dynamic>{
        'maintenanceCharge': maintenanceCharge,
        'parkingCharge': parkingCharge,
        'waterCharge': waterCharge,
        'singleOccupancyCharge': singleOccupancyCharge,
        'doubleSharingCharge': doubleSharingCharge,
        'tripleSharingCharge': tripleSharingCharge,
        'customCharges': customCharges
            .map((FeeChargeItem item) => item.toJson())
            .toList(growable: false),
      },
    );
    return _parseFeeSettings(payload);
  }

  @override
  Future<AdminCatalog> getCatalog() async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'GET',
      path: '/catalog',
    );
    return _parseAdminCatalog(payload);
  }

  @override
  Future<AdminCatalog> getAdminCatalog() async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'GET',
      path: '/admin/catalog',
    );
    return _parseAdminCatalog(payload);
  }

  @override
  Future<AdminCatalog> updateAdminCatalog(AdminCatalog catalog) async {
    final Map<String, dynamic> payload = await _requestObject(
      method: 'PATCH',
      path: '/admin/catalog',
      body: catalog.toJson(),
    );
    return _parseAdminCatalog(payload);
  }

  Future<dynamic> _request({
    required String method,
    required String path,
    Map<String, dynamic>? body,
  }) async {
    return _api.requestJson(
      method: method,
      path: path,
      body: body,
    );
  }

  Future<Map<String, dynamic>> _requestObject({
    required String method,
    required String path,
    Map<String, dynamic>? body,
  }) async {
    final dynamic payload = await _request(
      method: method,
      path: path,
      body: body,
    );
    return payload as Map<String, dynamic>;
  }

  Future<List<dynamic>> _requestList({
    required String method,
    required String path,
    Map<String, dynamic>? body,
  }) async {
    final dynamic payload = await _request(
      method: method,
      path: path,
      body: body,
    );
    return payload as List<dynamic>;
  }

  Future<void> _persistAuthTokenFromPayload(
      Map<String, dynamic> payload) async {
    final String? authToken = payload['authToken'] as String?;
    if (authToken == null || authToken.trim().isEmpty) {
      return;
    }
    await _api.persistAuthToken(authToken);
  }

  AppUser _parseUser(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      username: json['username'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      password: json['password'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String,
      role: UserRole.values.byName(json['role'] as String),
      roomId: json['roomId'] as String?,
      jobTitle: json['jobTitle'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      emailVerifiedAt: json['emailVerifiedAt'] == null
          ? null
          : DateTime.parse(json['emailVerifiedAt'] as String),
    );
  }

  AuthChallenge _parseAuthChallenge(Map<String, dynamic> json) {
    final String deliveryMethodName =
        json['deliveryMethod'] as String? ?? 'local';
    return AuthChallenge(
      email: json['email'] as String,
      code: json['code'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      deliveryMethod: AuthChallengeDeliveryMethod.values.byName(
        deliveryMethodName,
      ),
      deliveryError: json['deliveryError'] as String?,
    );
  }

  SetupStatus _parseSetupStatus(Map<String, dynamic> json) {
    return SetupStatus(
      requiresBootstrap: json['requiresBootstrap'] as bool? ?? false,
      demoMode: json['demoMode'] as bool? ?? false,
    );
  }

  HostelNotificationItem _parseNotification(Map<String, dynamic> json) {
    return HostelNotificationItem(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: HostelNotificationType.values.byName(json['type'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
    );
  }

  ChatMessage _parseChatMessage(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      recipientId: json['recipientId'] as String,
      message: json['message'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
    );
  }

  HostelBlock _parseBlock(Map<String, dynamic> json) {
    return HostelBlock(
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  HostelRoom _parseRoom(Map<String, dynamic> json) {
    return HostelRoom(
      id: json['id'] as String,
      block: json['block'] as String,
      number: json['number'] as String,
      capacity: json['capacity'] as int,
      roomType: json['roomType'] as String,
      residentIds: (json['residentIds'] as List<dynamic>)
          .cast<String>()
          .toList(growable: false),
    );
  }

  IssueTicket _parseIssue(Map<String, dynamic> json) {
    return IssueTicket(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      category: json['category'] as String,
      comment: json['comment'] as String,
      status: IssueStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      assignedStaffId: json['assignedStaffId'] as String?,
    );
  }

  GatePassRequest _parseGatePass(Map<String, dynamic> json) {
    return GatePassRequest(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      destination: json['destination'] as String,
      reason: json['reason'] as String,
      emergencyContact: json['emergencyContact'] as String,
      passCode: json['passCode'] as String,
      status: GatePassStatus.values.byName(json['status'] as String),
      departureAt: DateTime.parse(json['departureAt'] as String),
      expectedReturnAt: DateTime.parse(json['expectedReturnAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
      checkedOutAt: json['checkedOutAt'] == null
          ? null
          : DateTime.parse(json['checkedOutAt'] as String),
      returnedAt: json['returnedAt'] == null
          ? null
          : DateTime.parse(json['returnedAt'] as String),
    );
  }

  ParcelItem _parseParcel(Map<String, dynamic> json) {
    return ParcelItem(
      id: json['id'] as String,
      userId: json['userId'] as String,
      carrier: json['carrier'] as String,
      trackingCode: json['trackingCode'] as String,
      note: json['note'] as String? ?? '',
      status: ParcelStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      notifiedAt: json['notifiedAt'] == null
          ? null
          : DateTime.parse(json['notifiedAt'] as String),
      collectedAt: json['collectedAt'] == null
          ? null
          : DateTime.parse(json['collectedAt'] as String),
    );
  }

  VisitorEntry _parseVisitorEntry(Map<String, dynamic> json) {
    return VisitorEntry(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      visitorName: json['visitorName'] as String,
      relation: json['relation'] as String,
      note: json['note'] as String? ?? '',
      checkedInAt: DateTime.parse(json['checkedInAt'] as String),
      checkedOutAt: json['checkedOutAt'] == null
          ? null
          : DateTime.parse(json['checkedOutAt'] as String),
    );
  }

  LaundryBooking _parseLaundryBooking(Map<String, dynamic> json) {
    return LaundryBooking(
      id: json['id'] as String,
      userId: json['userId'] as String,
      machineLabel: json['machineLabel'] as String,
      slotLabel: json['slotLabel'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      notes: json['notes'] as String? ?? '',
      status: laundryBookingStatusFromValue(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );
  }

  NoticeItem _parseNotice(Map<String, dynamic> json) {
    return NoticeItem(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      category: json['category'] as String? ?? '',
      postedAt: DateTime.parse(json['postedAt'] as String),
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }

  MessMenuDay _parseMessMenuDay(Map<String, dynamic> json) {
    return MessMenuDay(
      day: MessDay.values.byName(json['day'] as String),
      breakfast: json['breakfast'] as String,
      lunch: json['lunch'] as String,
      dinner: json['dinner'] as String,
    );
  }

  MealAttendanceDay _parseMealAttendance(Map<String, dynamic> json) {
    return MealAttendanceDay(
      id: json['id'] as String,
      userId: json['userId'] as String,
      day: MessDay.values.byName(json['day'] as String),
      date: DateTime.parse(json['date'] as String),
      breakfast: json['breakfast'] as bool,
      lunch: json['lunch'] as bool,
      dinner: json['dinner'] as bool,
    );
  }

  FoodFeedback _parseFoodFeedback(Map<String, dynamic> json) {
    return FoodFeedback(
      id: json['id'] as String,
      userId: json['userId'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
    );
  }

  MessBillSummary _parseMessBill(Map<String, dynamic> json) {
    return MessBillSummary(
      monthLabel: json['monthLabel'] as String,
      breakfastCount: json['breakfastCount'] as int,
      lunchCount: json['lunchCount'] as int,
      dinnerCount: json['dinnerCount'] as int,
      breakfastRate: json['breakfastRate'] as int,
      lunchRate: json['lunchRate'] as int,
      dinnerRate: json['dinnerRate'] as int,
    );
  }

  RoomChangeRequest _parseRoomRequest(Map<String, dynamic> json) {
    return RoomChangeRequest(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      currentRoomId: json['currentRoomId'] as String,
      desiredRoomId: json['desiredRoomId'] as String,
      reason: json['reason'] as String,
      status: RoomRequestStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
    );
  }

  FeeSummary _parseFeeSummary(Map<String, dynamic> json) {
    final List<dynamic> rawAdditionalCharges =
        json['additionalCharges'] as List<dynamic>? ?? <dynamic>[];
    return FeeSummary(
      maintenanceCharge: json['maintenanceCharge'] as int,
      parkingCharge: json['parkingCharge'] as int,
      waterCharge: json['waterCharge'] as int,
      roomCharge: json['roomCharge'] as int,
      additionalCharges: rawAdditionalCharges
          .whereType<Map<String, dynamic>>()
          .map(FeeChargeItem.fromJson)
          .toList(growable: false),
      billingMonth: json['billingMonth'] as String? ?? 'Current cycle',
      paidAmount: json['paidAmount'] as int? ?? 0,
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      lastReminderAt: json['lastReminderAt'] == null
          ? null
          : DateTime.parse(json['lastReminderAt'] as String),
    );
  }

  PaymentRecord _parsePayment(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: json['amount'] as int,
      method: PaymentMethod.values.byName(json['paymentMethod'] as String),
      status: PaymentStatus.values.byName(json['status'] as String),
      receiptId: json['receiptId'] as String,
      billingMonth: json['billingMonth'] as String,
      paidAt: DateTime.parse(json['paidAt'] as String),
    );
  }

  FeeSettings _parseFeeSettings(Map<String, dynamic> json) {
    final List<dynamic> rawCustomCharges =
        json['customCharges'] as List<dynamic>? ?? <dynamic>[];
    return FeeSettings(
      maintenanceCharge: json['maintenanceCharge'] as int,
      parkingCharge: json['parkingCharge'] as int,
      waterCharge: json['waterCharge'] as int,
      singleOccupancyCharge: json['singleOccupancyCharge'] as int,
      doubleSharingCharge: json['doubleSharingCharge'] as int,
      tripleSharingCharge: json['tripleSharingCharge'] as int,
      customCharges: rawCustomCharges
          .whereType<Map<String, dynamic>>()
          .map(FeeChargeItem.fromJson)
          .toList(growable: false),
    );
  }

  AdminCatalog _parseAdminCatalog(Map<String, dynamic> json) {
    return AdminCatalog.fromJson(json);
  }
}
