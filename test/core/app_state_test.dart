import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hostel_management_app/core/models/app_user.dart';
import 'package:hostel_management_app/core/models/hostel_room.dart';
import 'package:hostel_management_app/core/services/mock_hostel_repository.dart';
import 'package:hostel_management_app/core/services/session_store.dart';
import 'package:hostel_management_app/core/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppState session restore', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('initialize restores the persisted user', () async {
      final FakeSessionStore sessionStore =
          FakeSessionStore(initialUserId: 'student_1');
      final AppState state = AppState(
        MockHostelRepository(),
        sessionStore: sessionStore,
      );

      await state.initialize();

      expect(state.isAuthenticated, isTrue);
      expect(state.currentUser?.id, 'student_1');
      expect(state.currentFeeSummary, isNotNull);
    });

    test('logout clears the persisted session', () async {
      final FakeSessionStore sessionStore =
          FakeSessionStore(initialUserId: 'student_1');
      final AppState state = AppState(
        MockHostelRepository(),
        sessionStore: sessionStore,
      );

      await state.initialize();
      state.logout();
      await Future<void>.delayed(Duration.zero);

      expect(state.isAuthenticated, isFalse);
      expect(sessionStore.userId, isNull);
    });

    test('login preserves the authenticated user during refresh fallback',
        () async {
      final FakeSessionStore sessionStore = FakeSessionStore();
      final MissingUserRefreshRepository repository =
          MissingUserRefreshRepository();
      await repository.bootstrapAdmin(
        username: 'admin',
        firstName: 'Hostel',
        lastName: 'Admin',
        email: 'admin@hostel.local',
        password: 'Admin@123',
        phoneNumber: '9800000000',
      );
      final AppState state = AppState(
        repository,
        sessionStore: sessionStore,
      );

      await state.login(
        identifier: 'admin@hostel.local',
        password: 'Admin@123',
      );

      expect(state.isAuthenticated, isTrue);
      expect(state.currentUser?.id, 'admin_1');
      expect(sessionStore.userId, 'admin_1');
    });

    test('initialize restores the persisted theme mode', () async {
      final FakeSessionStore sessionStore = FakeSessionStore(
        initialUserId: 'student_1',
        initialThemeMode: ThemeMode.dark.name,
      );
      final AppState state = AppState(
        MockHostelRepository(),
        sessionStore: sessionStore,
      );

      await state.initialize();

      expect(state.themeMode, ThemeMode.dark);
    });

    test('setThemeMode persists the selected theme', () async {
      final FakeSessionStore sessionStore = FakeSessionStore(
        initialUserId: 'student_1',
      );
      final AppState state = AppState(
        MockHostelRepository(),
        sessionStore: sessionStore,
      );

      await state.initialize();
      await state.setThemeMode(ThemeMode.light);

      expect(state.themeMode, ThemeMode.light);
      expect(sessionStore.themeMode, ThemeMode.light.name);
    });

    test('initialize restores persisted app preferences', () async {
      final FakeSessionStore sessionStore = FakeSessionStore(
        initialUserId: 'student_1',
        initialInAppNotificationsEnabled: false,
        initialNotificationPreviewsEnabled: false,
        initialNotificationBadgesEnabled: false,
        initialActivityAutoRefreshEnabled: false,
        initialShowRoomDetailsOnCards: false,
        initialShowContactInfoOnCards: false,
      );
      final AppState state = AppState(
        MockHostelRepository(),
        sessionStore: sessionStore,
      );

      await state.initialize();

      expect(state.inAppNotificationsEnabled, isFalse);
      expect(state.notificationPreviewsEnabled, isFalse);
      expect(state.notificationBadgesEnabled, isFalse);
      expect(state.activityAutoRefreshEnabled, isFalse);
      expect(state.showRoomDetailsOnCards, isFalse);
      expect(state.showContactInfoOnCards, isFalse);
    });

    test('settings toggles persist selected preferences', () async {
      final FakeSessionStore sessionStore = FakeSessionStore(
        initialUserId: 'student_1',
      );
      final AppState state = AppState(
        MockHostelRepository(),
        sessionStore: sessionStore,
      );

      await state.initialize();
      await state.setInAppNotificationsEnabled(false);
      await state.setNotificationPreviewsEnabled(false);
      await state.setNotificationBadgesEnabled(false);
      await state.setActivityAutoRefreshEnabled(false);
      await state.setShowRoomDetailsOnCards(false);
      await state.setShowContactInfoOnCards(false);

      expect(state.inAppNotificationsEnabled, isFalse);
      expect(state.notificationPreviewsEnabled, isFalse);
      expect(state.notificationBadgesEnabled, isFalse);
      expect(state.activityAutoRefreshEnabled, isFalse);
      expect(state.showRoomDetailsOnCards, isFalse);
      expect(state.showContactInfoOnCards, isFalse);
      expect(sessionStore.inAppNotificationsEnabled, isFalse);
      expect(sessionStore.notificationPreviewsEnabled, isFalse);
      expect(sessionStore.notificationBadgesEnabled, isFalse);
      expect(sessionStore.activityAutoRefreshEnabled, isFalse);
      expect(sessionStore.showRoomDetailsOnCards, isFalse);
      expect(sessionStore.showContactInfoOnCards, isFalse);
    });

    test('resetAppPreferences restores defaults without clearing session',
        () async {
      final FakeSessionStore sessionStore = FakeSessionStore(
        initialUserId: 'student_1',
        initialThemeMode: ThemeMode.dark.name,
        initialInAppNotificationsEnabled: false,
        initialNotificationPreviewsEnabled: false,
        initialNotificationBadgesEnabled: false,
        initialActivityAutoRefreshEnabled: false,
        initialShowRoomDetailsOnCards: false,
        initialShowContactInfoOnCards: false,
      );
      final AppState state = AppState(
        MockHostelRepository(),
        sessionStore: sessionStore,
      );

      await state.initialize();
      await state.resetAppPreferences();

      expect(state.themeMode, ThemeMode.system);
      expect(state.inAppNotificationsEnabled, isTrue);
      expect(state.notificationPreviewsEnabled, isTrue);
      expect(state.notificationBadgesEnabled, isTrue);
      expect(state.activityAutoRefreshEnabled, isTrue);
      expect(state.showRoomDetailsOnCards, isTrue);
      expect(state.showContactInfoOnCards, isTrue);
      expect(sessionStore.userId, 'student_1');
      expect(sessionStore.themeMode, isNull);
      expect(sessionStore.inAppNotificationsEnabled, isNull);
      expect(sessionStore.notificationPreviewsEnabled, isNull);
      expect(sessionStore.notificationBadgesEnabled, isNull);
      expect(sessionStore.activityAutoRefreshEnabled, isNull);
      expect(sessionStore.showRoomDetailsOnCards, isNull);
      expect(sessionStore.showContactInfoOnCards, isNull);
    });

    test(
      'assignResidentRoom refreshes resident and room state',
      () async {
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
          code: 'A',
          name: 'Alpha',
        );
        await repository.createRoom(
          block: 'A',
          number: '101',
          capacity: 2,
          roomType: 'Double Sharing',
        );
        await repository.createRoom(
          block: 'A',
          number: '102',
          capacity: 2,
          roomType: 'Double Sharing',
        );
        final resident = await repository.registerStudent(
          username: 'resident',
          firstName: 'Resident',
          lastName: 'One',
          email: 'resident.one@hostelhub.edu',
          password: 'Student@123',
          phoneNumber: '9801111111',
          roomId: 'room_a101',
        );

        final AppState state = AppState(
          repository,
          sessionStore: FakeSessionStore(initialUserId: 'admin_1'),
        );

        await state.initialize();
        await state.assignResidentRoom(
          userId: resident.id,
          roomId: 'room_a102',
        );

        expect(state.findUser(resident.id)?.roomId, 'room_a102');
        expect(
          state.findRoom('room_a101')?.residentIds,
          isNot(contains(resident.id)),
        );
        expect(state.findRoom('room_a102')?.residentIds, contains(resident.id));
      },
    );

    test('availableRoomsFor deduplicates rooms with the same id', () async {
      final AppState state = AppState(
        DuplicateRoomsRepository(),
        sessionStore: FakeSessionStore(initialUserId: 'student_1'),
      );

      await state.initialize();

      final List<HostelRoom> rooms = state.availableRoomsFor();
      final Set<String> uniqueIds =
          rooms.map((HostelRoom room) => room.id).toSet();

      expect(uniqueIds.length, rooms.length);
    });
  });
}

class FakeSessionStore implements SessionStore {
  FakeSessionStore({
    this.initialUserId,
    this.initialThemeMode,
    this.initialInAppNotificationsEnabled,
    this.initialNotificationPreviewsEnabled,
    this.initialNotificationBadgesEnabled,
    this.initialActivityAutoRefreshEnabled,
    this.initialShowRoomDetailsOnCards,
    this.initialShowContactInfoOnCards,
  })  : userId = initialUserId,
        themeMode = initialThemeMode,
        inAppNotificationsEnabled = initialInAppNotificationsEnabled,
        notificationPreviewsEnabled = initialNotificationPreviewsEnabled,
        notificationBadgesEnabled = initialNotificationBadgesEnabled,
        activityAutoRefreshEnabled = initialActivityAutoRefreshEnabled,
        showRoomDetailsOnCards = initialShowRoomDetailsOnCards,
        showContactInfoOnCards = initialShowContactInfoOnCards;

  final String? initialUserId;
  final String? initialThemeMode;
  final bool? initialInAppNotificationsEnabled;
  final bool? initialNotificationPreviewsEnabled;
  final bool? initialNotificationBadgesEnabled;
  final bool? initialActivityAutoRefreshEnabled;
  final bool? initialShowRoomDetailsOnCards;
  final bool? initialShowContactInfoOnCards;
  String? userId;
  String? themeMode;
  bool? inAppNotificationsEnabled;
  bool? notificationPreviewsEnabled;
  bool? notificationBadgesEnabled;
  bool? activityAutoRefreshEnabled;
  bool? showRoomDetailsOnCards;
  bool? showContactInfoOnCards;

  @override
  Future<void> clear() async {
    userId = null;
  }

  @override
  Future<void> clearAppPreferences() async {
    themeMode = null;
    inAppNotificationsEnabled = null;
    notificationPreviewsEnabled = null;
    notificationBadgesEnabled = null;
    activityAutoRefreshEnabled = null;
    showRoomDetailsOnCards = null;
    showContactInfoOnCards = null;
  }

  @override
  Future<String?> readUserId() async => userId;

  @override
  Future<String?> readThemeMode() async => themeMode;

  @override
  Future<bool?> readInAppNotificationsEnabled() async =>
      inAppNotificationsEnabled;

  @override
  Future<bool?> readNotificationPreviewsEnabled() async =>
      notificationPreviewsEnabled;

  @override
  Future<bool?> readNotificationBadgesEnabled() async =>
      notificationBadgesEnabled;

  @override
  Future<bool?> readActivityAutoRefreshEnabled() async =>
      activityAutoRefreshEnabled;

  @override
  Future<bool?> readShowRoomDetailsOnCards() async => showRoomDetailsOnCards;

  @override
  Future<bool?> readShowContactInfoOnCards() async => showContactInfoOnCards;

  @override
  Future<void> writeUserId(String userId) async {
    this.userId = userId;
  }

  @override
  Future<void> writeThemeMode(String themeMode) async {
    this.themeMode = themeMode;
  }

  @override
  Future<void> writeInAppNotificationsEnabled(bool value) async {
    inAppNotificationsEnabled = value;
  }

  @override
  Future<void> writeNotificationPreviewsEnabled(bool value) async {
    notificationPreviewsEnabled = value;
  }

  @override
  Future<void> writeNotificationBadgesEnabled(bool value) async {
    notificationBadgesEnabled = value;
  }

  @override
  Future<void> writeActivityAutoRefreshEnabled(bool value) async {
    activityAutoRefreshEnabled = value;
  }

  @override
  Future<void> writeShowRoomDetailsOnCards(bool value) async {
    showRoomDetailsOnCards = value;
  }

  @override
  Future<void> writeShowContactInfoOnCards(bool value) async {
    showContactInfoOnCards = value;
  }
}

class DuplicateRoomsRepository extends MockHostelRepository {
  DuplicateRoomsRepository() : super();

  @override
  Future<List<HostelRoom>> getRooms() async {
    final List<HostelRoom> rooms = await super.getRooms();
    final HostelRoom duplicated = rooms.firstWhere(
      (HostelRoom room) => room.hasAvailability,
    );
    return <HostelRoom>[duplicated, ...rooms];
  }
}

class MissingUserRefreshRepository extends MockHostelRepository {
  MissingUserRefreshRepository() : super(seedDemoData: false);

  @override
  Future<List<AppUser>> getStudents() async => const <AppUser>[];

  @override
  Future<List<AppUser>> getGuests() async => const <AppUser>[];

  @override
  Future<List<AppUser>> getStaffMembers() async => const <AppUser>[];
}
