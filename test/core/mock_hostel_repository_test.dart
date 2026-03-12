import 'package:flutter_test/flutter_test.dart';
import 'package:hostel_management_app/core/models/app_user.dart';
import 'package:hostel_management_app/core/models/app_notification.dart';
import 'package:hostel_management_app/core/models/auth_challenge.dart';
import 'package:hostel_management_app/core/models/chat_message.dart';
import 'package:hostel_management_app/core/models/fee_charge_item.dart';
import 'package:hostel_management_app/core/models/front_desk_models.dart';
import 'package:hostel_management_app/core/models/gate_pass_models.dart';
import 'package:hostel_management_app/core/models/hostel_room.dart';
import 'package:hostel_management_app/core/models/issue_ticket.dart';
import 'package:hostel_management_app/core/models/laundry_models.dart';
import 'package:hostel_management_app/core/models/mess_models.dart';
import 'package:hostel_management_app/core/models/notice_item.dart';
import 'package:hostel_management_app/core/models/payment_record.dart';
import 'package:hostel_management_app/core/models/room_change_request.dart';
import 'package:hostel_management_app/core/services/mock_hostel_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MockHostelRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('registerStudent assigns the student to the selected room', () async {
      final MockHostelRepository repository = MockHostelRepository();

      final registeredUser = await repository.registerStudent(
        username: 'newstudent',
        firstName: 'New',
        lastName: 'Student',
        email: 'new.student@hostelhub.edu',
        password: 'Student@123',
        phoneNumber: '9801111111',
        roomId: 'room_e301',
      );

      final rooms = await repository.getRooms();
      final assignedRoom = rooms.firstWhere((room) => room.id == 'room_e301');
      final feeSummary = await repository.getFeeSummary(registeredUser.id);

      expect(registeredUser.roomId, 'room_e301');
      expect(assignedRoom.occupiedBeds, 1);
      expect(assignedRoom.residentIds, contains(registeredUser.id));
      expect(feeSummary.total, greaterThan(0));
    });

    test('seed data includes at least 100 students with valid emails',
        () async {
      final MockHostelRepository repository = MockHostelRepository();

      final students = await repository.getStudents();

      expect(students.length, greaterThanOrEqualTo(100));
      expect(
        students.every((user) => user.email.contains('@hostelhub.edu')),
        isTrue,
      );
    });

    test('requestEmailVerification and verifyEmail update resident state',
        () async {
      final MockHostelRepository repository = MockHostelRepository();

      final created = await repository.registerStudent(
        username: 'verifyme',
        firstName: 'Verify',
        lastName: 'Me',
        email: 'verify.me@hostelhub.edu',
        password: 'Student@123',
        phoneNumber: '9801111112',
        roomId: 'room_e302',
      );
      final AuthChallenge challenge = await repository.requestEmailVerification(
        email: created.email,
      );
      final verified = await repository.verifyEmail(
        email: created.email,
        code: challenge.code,
      );

      expect(verified.emailVerified, isTrue);
    });

    test('registerGuest creates a guest account outside staff lists', () async {
      final MockHostelRepository repository = MockHostelRepository();

      final registered = await repository.registerGuest(
        username: 'guestarrival',
        firstName: 'Guest',
        lastName: 'Arrival',
        email: 'guest.arrival@hostelhub.edu',
        password: 'Guest@123',
        phoneNumber: '9801111113',
      );
      final guests = await repository.getGuests();
      final staff = await repository.getStaffMembers();

      expect(registered.role.name, 'guest');
      expect(registered.roomId, isNull);
      expect(guests.any((user) => user.id == registered.id), isTrue);
      expect(staff.any((user) => user.id == registered.id), isFalse);
    });

    test('getUser returns a user without depending on role lists', () async {
      final MockHostelRepository repository =
          MockHostelRepository(seedDemoData: false);

      final AppUser admin = await repository.bootstrapAdmin(
        username: 'owner',
        firstName: 'Owner',
        lastName: 'Admin',
        email: 'owner@hostelhub.edu',
        password: 'Admin@123',
        phoneNumber: '9807777777',
      );

      final AppUser fetched = await repository.getUser(admin.id);

      expect(fetched.id, admin.id);
      expect(fetched.role.name, 'admin');
      expect(fetched.email, admin.email);
    });

    test('clean repository bootstraps the first admin account', () async {
      final MockHostelRepository repository =
          MockHostelRepository(seedDemoData: false);

      final status = await repository.getSetupStatus();
      final admin = await repository.bootstrapAdmin(
        username: 'owner',
        firstName: 'Owner',
        lastName: 'Admin',
        email: 'owner@hostelhub.edu',
        password: 'Admin@123',
        phoneNumber: '9807777777',
      );

      expect(status.requiresBootstrap, isTrue);
      expect(admin.role.name, 'admin');
      expect((await repository.getSetupStatus()).requiresBootstrap, isFalse);
    });

    test('bootstrapped admin persists across repository instances', () async {
      final MockHostelRepository repository =
          MockHostelRepository(seedDemoData: false);

      final AppUser admin = await repository.bootstrapAdmin(
        username: 'persistent-owner',
        firstName: 'Persistent',
        lastName: 'Owner',
        email: 'persistent.owner@hostelhub.edu',
        password: 'Admin@123',
        phoneNumber: '9807777000',
      );

      final MockHostelRepository restartedRepository =
          MockHostelRepository(seedDemoData: false);
      final status = await restartedRepository.getSetupStatus();
      final restored = await restartedRepository.login(
        identifier: admin.email,
        password: 'Admin@123',
      );

      expect(status.requiresBootstrap, isFalse);
      expect(restored.id, admin.id);
      expect(restored.role.name, 'admin');
      expect(restored.email, admin.email);
    });

    test('workspace entities persist across repository instances', () async {
      final MockHostelRepository repository =
          MockHostelRepository(seedDemoData: false);

      await repository.bootstrapAdmin(
        username: 'owner',
        firstName: 'Owner',
        lastName: 'Admin',
        email: 'owner@hostelhub.edu',
        password: 'Admin@123',
        phoneNumber: '9807777777',
      );
      await repository.createBlock(
        code: 'F',
        name: 'City View',
      );
      final HostelRoom room = await repository.createRoom(
        block: 'F',
        number: '301',
        capacity: 2,
        roomType: 'Double Sharing',
      );
      final AppUser staff = await repository.createStaff(
        username: 'warden',
        firstName: 'Night',
        lastName: 'Warden',
        email: 'night.warden@hostelhub.edu',
        password: 'Staff@123',
        phoneNumber: '9802222222',
        jobTitle: 'Night Warden',
      );
      final AppUser guest = await repository.registerGuest(
        username: 'visitor',
        firstName: 'Guest',
        lastName: 'Persisted',
        email: 'guest.persisted@hostelhub.edu',
        password: 'Guest@123',
        phoneNumber: '9803333333',
      );
      final NoticeItem notice = await repository.createNotice(
        title: 'Inspection',
        message: 'Room inspection starts at 7 AM tomorrow.',
        category: 'Announcement',
      );

      final MockHostelRepository restarted =
          MockHostelRepository(seedDemoData: false);

      expect((await restarted.getBlocks()).any((block) => block.code == 'F'),
          isTrue);
      expect((await restarted.getRooms()).any((item) => item.id == room.id),
          isTrue);
      expect(
        (await restarted.getStaffMembers()).any((item) => item.id == staff.id),
        isTrue,
      );
      expect(
        (await restarted.getGuests()).any((item) => item.id == guest.id),
        isTrue,
      );
      expect(
        (await restarted.getNotices()).any((item) => item.id == notice.id),
        isTrue,
      );
    });

    test('prepareCleanWorkspace keeps only the admin account', () async {
      final MockHostelRepository repository = MockHostelRepository();

      await repository.prepareCleanWorkspace(adminId: 'admin_1');

      expect((await repository.getStudents()), isEmpty);
      expect((await repository.getStaffMembers()), hasLength(1));
      expect((await repository.getBlocks()), isEmpty);
      expect((await repository.getNotices()), isEmpty);
      expect((await repository.getSetupStatus()).demoMode, isFalse);
    });

    test('requestPasswordReset and resetPassword rotate the password',
        () async {
      final MockHostelRepository repository = MockHostelRepository();

      final AuthChallenge challenge = await repository.requestPasswordReset(
        email: 'aayush.dc@hostelhub.edu',
      );
      await repository.resetPassword(
        email: 'aayush.dc@hostelhub.edu',
        code: challenge.code,
        newPassword: 'Student@456',
      );
      final user = await repository.login(
        identifier: 'aayush.dc@hostelhub.edu',
        password: 'Student@456',
      );

      expect(user.id, 'student_1');
    });

    test('approving a room request moves the resident to the new room',
        () async {
      final MockHostelRepository repository = MockHostelRepository();

      await repository.updateRoomChangeRequestStatus(
        requestId: 'request_1',
        status: RoomRequestStatus.approved,
      );

      final students = await repository.getStudents();
      final rooms = await repository.getRooms();
      final movedStudent =
          students.firstWhere((user) => user.id == 'student_1');
      final oldRoom = rooms.firstWhere((room) => room.id == 'room_b413');
      final newRoom = rooms.firstWhere((room) => room.id == 'room_e301');

      expect(movedStudent.roomId, 'room_e301');
      expect(oldRoom.residentIds, isNot(contains('student_1')));
      expect(newRoom.residentIds, contains('student_1'));
    });

    test(
        'assignResidentRoom moves the resident and resolves the pending request',
        () async {
      final MockHostelRepository repository = MockHostelRepository();

      final AppUser updated = await repository.assignResidentRoom(
        userId: 'student_1',
        roomId: 'room_e301',
      );
      final rooms = await repository.getRooms();
      final requests = await repository.getRoomChangeRequests();
      final oldRoom = rooms.firstWhere((room) => room.id == 'room_b413');
      final newRoom = rooms.firstWhere((room) => room.id == 'room_e301');
      final request = requests.firstWhere((item) => item.id == 'request_1');

      expect(updated.roomId, 'room_e301');
      expect(oldRoom.residentIds, isNot(contains('student_1')));
      expect(newRoom.residentIds, contains('student_1'));
      expect(request.status, RoomRequestStatus.approved);
    });

    test('createBlock and createRoom update inventory immediately', () async {
      final MockHostelRepository repository = MockHostelRepository();

      await repository.createBlock(
        code: 'F',
        name: 'City View',
        description: 'New compact wing for overflow capacity.',
      );
      final createdRoom = await repository.createRoom(
        block: 'F',
        number: '301',
        capacity: 2,
        roomType: 'Double Sharing',
      );

      final blocks = await repository.getBlocks();
      final rooms = await repository.getRooms();

      expect(blocks.any((block) => block.code == 'F'), isTrue);
      expect(createdRoom.label, 'F-301');
      expect(rooms.any((room) => room.id == createdRoom.id), isTrue);
    });

    test('updateFeeSettings recalculates student totals', () async {
      final MockHostelRepository repository = MockHostelRepository();

      await repository.updateFeeSettings(
        maintenanceCharge: 1500,
        parkingCharge: 450,
        waterCharge: 600,
        singleOccupancyCharge: 7000,
        doubleSharingCharge: 5600,
        tripleSharingCharge: 4700,
        customCharges: const <FeeChargeItem>[],
      );

      final fees = await repository.getFeeSummary('student_1');

      expect(fees.total, 8650);
      expect(fees.roomCharge, 5600);
      expect(
        fees.additionalCharges.any(
          (FeeChargeItem item) => item.label == 'Electricity',
        ),
        isTrue,
      );
    });

    test('payFee stores a receipt and clears the pending balance', () async {
      final MockHostelRepository repository = MockHostelRepository();

      final payment = await repository.payFee(
        userId: 'student_1',
        method: PaymentMethod.card,
      );
      final summary = await repository.getFeeSummary('student_1');
      final history = await repository.getPaymentHistory('student_1');

      expect(payment.receiptId, startsWith('RCT-'));
      expect(summary.isPaid, isTrue);
      expect(summary.balance, 0);
      expect(history.first.receiptId, payment.receiptId);
    });

    test('assignIssue sets the assigned staff member on the complaint',
        () async {
      final MockHostelRepository repository = MockHostelRepository();

      final IssueTicket issue = await repository.assignIssue(
        issueId: 'issue_1',
        staffId: 'staff_2',
      );

      expect(issue.assignedStaffId, 'staff_2');
      expect(issue.status, IssueStatus.inProgress);
    });

    test('createNotice publishes a pinned board update', () async {
      final MockHostelRepository repository = MockHostelRepository();

      final notice = await repository.createNotice(
        title: 'Water tank cleaning',
        message: 'Water supply will pause from 11 AM to 1 PM on Friday.',
        category: 'Announcement',
        isPinned: true,
      );
      final notices = await repository.getNotices();

      expect(notice.isPinned, isTrue);
      expect(notices.first.title, 'Water tank cleaning');
      expect(notices.first.category, 'Announcement');
    });

    test('createGatePass stores a pending leave request', () async {
      final MockHostelRepository repository = MockHostelRepository();

      final pass = await repository.createGatePass(
        studentId: 'student_2',
        destination: 'Kalanki',
        reason: 'Family function',
        emergencyContact: '9801234567',
        departureAt: DateTime.now().add(const Duration(hours: 2)),
        expectedReturnAt: DateTime.now().add(const Duration(hours: 8)),
      );
      final passes = await repository.getGatePasses();

      expect(pass.status, GatePassStatus.pending);
      expect(passes.any((GatePassRequest item) => item.id == pass.id), isTrue);
    });

    test('markGatePassReturn closes a checked out pass', () async {
      final MockHostelRepository repository = MockHostelRepository();

      final pass = await repository.markGatePassReturn('gatepass_1');

      expect(pass.status, anyOf(GatePassStatus.returned, GatePassStatus.late));
      expect(pass.returnedAt, isNotNull);
    });

    test('markMealAttendance updates the student mess bill', () async {
      final MockHostelRepository repository = MockHostelRepository();

      await repository.markMealAttendance(
        userId: 'student_1',
        day: MessDay.friday,
        mealType: MealType.dinner,
        attended: true,
      );
      final bill = await repository.getMessBill('student_1');

      expect(bill.dinnerCount, greaterThanOrEqualTo(1));
      expect(bill.totalAmount, greaterThan(0));
    });

    test('submitFoodFeedback stores the student rating', () async {
      final MockHostelRepository repository = MockHostelRepository();

      final feedback = await repository.submitFoodFeedback(
        userId: 'student_1',
        rating: 5,
        comment: 'Dinner was balanced and served hot.',
      );
      final items = await repository.getFoodFeedback();

      expect(feedback.rating, 5);
      expect(items.first.id, feedback.id);
      expect(items.first.userId, 'student_1');
    });

    test('createParcel stores a pending parcel for a resident', () async {
      final MockHostelRepository repository = MockHostelRepository();

      final parcel = await repository.createParcel(
        userId: 'student_3',
        carrier: 'FedEx',
        trackingCode: 'FDX-4488',
        note: 'Electronics package',
      );
      final parcels = await repository.getParcels();

      expect(parcel.status, ParcelStatus.awaitingPickup);
      expect(parcels.first.id, parcel.id);
      expect(parcels.first.userId, 'student_3');
    });

    test('checkOutVisitor closes an active visitor entry', () async {
      final MockHostelRepository repository = MockHostelRepository();

      final entry = await repository.checkOutVisitor('visitor_1');
      final entries = await repository.getVisitorEntries();

      expect(entry.isActive, isFalse);
      expect(
          entries
              .firstWhere((VisitorEntry item) => item.id == 'visitor_1')
              .isActive,
          isFalse);
    });

    test('notifications can be read and cleared for a user', () async {
      final MockHostelRepository repository = MockHostelRepository();

      final List<HostelNotificationItem> initial =
          await repository.getNotifications('student_1');
      final HostelNotificationItem unread = initial.firstWhere(
        (HostelNotificationItem item) => !item.isRead,
      );

      final HostelNotificationItem updated =
          await repository.markNotificationRead(unread.id);
      final List<HostelNotificationItem> afterSingleRead =
          await repository.getNotifications('student_1');
      await repository.markAllNotificationsRead('student_1');
      final List<HostelNotificationItem> afterMarkAll =
          await repository.getNotifications('student_1');

      expect(updated.isRead, isTrue);
      expect(
        afterSingleRead
            .firstWhere((HostelNotificationItem item) => item.id == unread.id)
            .isRead,
        isTrue,
      );
      expect(afterMarkAll.every((HostelNotificationItem item) => item.isRead),
          isTrue);
    });

    test('chat messages can be sent to staff and appear in the thread',
        () async {
      final MockHostelRepository repository = MockHostelRepository();

      final ChatMessage message = await repository.sendChatMessage(
        senderId: 'student_1',
        recipientId: 'staff_1',
        message: 'Can you review my gate pass today?',
      );
      final List<ChatMessage> thread =
          await repository.getChatMessages('student_1');

      expect(message.recipientId, 'staff_1');
      expect(thread.any((ChatMessage item) => item.id == message.id), isTrue);
    });

    test('createLaundryBooking stores a scheduled laundry slot', () async {
      final MockHostelRepository repository = MockHostelRepository();

      final LaundryBooking booking = await repository.createLaundryBooking(
        userId: 'student_3',
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
        slotLabel: '08:00 - 09:00',
        machineLabel: 'Machine C',
        notes: 'Uniform wash',
      );
      final List<LaundryBooking> bookings =
          await repository.getLaundryBookings();

      expect(booking.status, LaundryBookingStatus.scheduled);
      expect(
        bookings.any((LaundryBooking item) => item.id == booking.id),
        isTrue,
      );
    });
  });
}
