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
import '../models/auth_challenge.dart';
import '../models/admin_catalog.dart';
import '../models/setup_status.dart';
import '../models/failure.dart';

class HostelRepositoryException implements Exception {
  const HostelRepositoryException(this.message) : _failure = null;

  HostelRepositoryException.fromFailure(Failure failure)
      : message = failure.message,
        _failure = failure;

  final String message;
  final Failure? _failure;

  Failure get failure =>
      _failure ??
      Failure(
        message: message,
        type: FailureType.backend,
      );

  @override
  String toString() => message;
}

class HostelRepositoryConnectionException extends HostelRepositoryException {
  const HostelRepositoryConnectionException(super.message);

  HostelRepositoryConnectionException.fromFailure(super.failure)
      : super.fromFailure();
}

abstract interface class HostelRepository {
  Future<SetupStatus> getSetupStatus();

  Future<AppUser> login({
    required String identifier,
    required String password,
  });

  Future<AppUser> bootstrapAdmin({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
  });

  Future<AppUser> registerStudent({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
    required String roomId,
  });

  Future<AppUser> registerGuest({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
  });

  Future<AuthChallenge> requestEmailVerification({
    required String email,
  });

  Future<AppUser> verifyEmail({
    required String email,
    required String code,
  });

  Future<AuthChallenge> requestPasswordReset({
    required String email,
  });

  Future<AppUser> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  Future<AppUser> getUser(String userId);

  Future<List<AppUser>> getStudents();

  Future<List<AppUser>> getGuests();

  Future<List<AppUser>> getStaffMembers();

  Future<List<ChatMessage>> getChatMessages(String userId);

  Future<ChatMessage> sendChatMessage({
    required String senderId,
    required String recipientId,
    required String message,
  });

  Future<void> markChatThreadRead({
    required String userId,
    required String partnerId,
  });

  Future<List<HostelNotificationItem>> getNotifications(String userId);

  Future<HostelNotificationItem> markNotificationRead(String notificationId);

  Future<void> markAllNotificationsRead(String userId);

  Future<List<HostelBlock>> getBlocks();

  Future<HostelBlock> createBlock({
    required String code,
    required String name,
    String? description,
  });

  Future<List<HostelRoom>> getRooms();

  Future<HostelRoom> createRoom({
    required String block,
    required String number,
    required int capacity,
    required String roomType,
  });

  Future<AppUser> assignResidentRoom({
    required String userId,
    required String roomId,
  });

  Future<List<IssueTicket>> getIssues();

  Future<List<GatePassRequest>> getGatePasses();

  Future<GatePassRequest> createGatePass({
    required String studentId,
    required String destination,
    required String reason,
    required String emergencyContact,
    required DateTime departureAt,
    required DateTime expectedReturnAt,
  });

  Future<GatePassRequest> reviewGatePass({
    required String gatePassId,
    required GatePassStatus status,
  });

  Future<GatePassRequest> markGatePassDeparture(String gatePassId);

  Future<GatePassRequest> markGatePassReturn(String gatePassId);

  Future<List<ParcelItem>> getParcels();

  Future<ParcelItem> createParcel({
    required String userId,
    required String carrier,
    required String trackingCode,
    required String note,
  });

  Future<ParcelItem> markParcelCollected(String parcelId);

  Future<List<VisitorEntry>> getVisitorEntries();

  Future<VisitorEntry> createVisitorEntry({
    required String studentId,
    required String visitorName,
    required String relation,
    required String note,
  });

  Future<VisitorEntry> checkOutVisitor(String visitorId);

  Future<List<LaundryBooking>> getLaundryBookings();

  Future<LaundryBooking> createLaundryBooking({
    required String userId,
    required DateTime scheduledAt,
    required String slotLabel,
    required String machineLabel,
    required String notes,
  });

  Future<LaundryBooking> updateLaundryBookingStatus({
    required String bookingId,
    required LaundryBookingStatus status,
  });

  Future<List<MessMenuDay>> getMessMenu();

  Future<MessMenuDay> updateMessMenuDay({
    required MessDay day,
    required String breakfast,
    required String lunch,
    required String dinner,
  });

  Future<List<MealAttendanceDay>> getMealAttendance();

  Future<MealAttendanceDay> markMealAttendance({
    required String userId,
    required MessDay day,
    required MealType mealType,
    required bool attended,
  });

  Future<List<FoodFeedback>> getFoodFeedback();

  Future<FoodFeedback> submitFoodFeedback({
    required String userId,
    required int rating,
    required String comment,
  });

  Future<MessBillSummary> getMessBill(String userId);

  Future<List<NoticeItem>> getNotices();

  Future<NoticeItem> createNotice({
    required String title,
    required String message,
    required String category,
    bool isPinned = false,
  });

  Future<IssueTicket> createIssue({
    required String studentId,
    required String category,
    required String comment,
  });

  Future<IssueTicket> updateIssueStatus({
    required String issueId,
    required IssueStatus status,
  });

  Future<IssueTicket> assignIssue({
    required String issueId,
    required String staffId,
  });

  Future<AppUser> createStaff({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
    required String jobTitle,
  });

  Future<void> deleteStaff(String staffId);

  Future<void> prepareCleanWorkspace({
    required String adminId,
  });

  Future<List<RoomChangeRequest>> getRoomChangeRequests();

  Future<RoomChangeRequest> createRoomChangeRequest({
    required String studentId,
    required String desiredRoomId,
    required String reason,
  });

  Future<RoomChangeRequest> updateRoomChangeRequestStatus({
    required String requestId,
    required RoomRequestStatus status,
  });

  Future<FeeSummary> getFeeSummary(String userId);

  Future<List<PaymentRecord>> getPaymentHistory(String userId);

  Future<PaymentRecord> payFee({
    required String userId,
    required PaymentMethod method,
  });

  Future<FeeSummary> sendFeeReminder(String userId);

  Future<FeeSettings> getFeeSettings();

  Future<FeeSettings> updateFeeSettings({
    required int maintenanceCharge,
    required int parkingCharge,
    required int waterCharge,
    required int singleOccupancyCharge,
    required int doubleSharingCharge,
    required int tripleSharingCharge,
    required List<FeeChargeItem> customCharges,
  });

  Future<AdminCatalog> getCatalog();

  Future<AdminCatalog> getAdminCatalog();

  Future<AdminCatalog> updateAdminCatalog(AdminCatalog catalog);
}
