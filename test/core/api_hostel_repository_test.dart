import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hostel_management_app/core/models/fee_charge_item.dart';
import 'package:hostel_management_app/core/services/api_hostel_repository.dart';
import 'package:hostel_management_app/core/services/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ApiHostelRepository', () {
    test('getSetupStatus parses clean-start status', () async {
      final ApiHostelRepository repository = ApiHostelRepository(
        baseUrl: 'http://127.0.0.1:8000',
        tokenStorage: InMemoryTokenStorage(),
        client: MockClient((http.Request request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/setup/status');
          return http.Response(
            jsonEncode(
              <String, dynamic>{
                'requiresBootstrap': true,
                'demoMode': false,
              },
            ),
            200,
            headers: <String, String>{
              'content-type': 'application/json',
            },
          );
        }),
      );

      final status = await repository.getSetupStatus();

      expect(status.requiresBootstrap, isTrue);
      expect(status.demoMode, isFalse);
    });

    test('login parses the authenticated user payload', () async {
      final InMemoryTokenStorage tokenStorage = InMemoryTokenStorage();
      final ApiHostelRepository repository = ApiHostelRepository(
        baseUrl: 'http://127.0.0.1:8000',
        tokenStorage: tokenStorage,
        client: MockClient((http.Request request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/auth/login');
          return http.Response(
            jsonEncode(
              <String, dynamic>{
                'id': 'student_1',
                'username': 'aayush',
                'firstName': 'Aayush',
                'lastName': 'DC',
                'email': 'aayush.dc@hostelhub.edu',
                'phoneNumber': '9876543210',
                'role': 'student',
                'roomId': 'room_b413',
                'jobTitle': null,
                'authToken': 'signed-token',
                'emailVerified': true,
                'emailVerifiedAt': '2026-01-07T00:00:00+00:00',
              },
            ),
            200,
            headers: <String, String>{
              'content-type': 'application/json',
            },
          );
        }),
      );

      final user = await repository.login(
        identifier: 'aayush.dc@hostelhub.edu',
        password: 'Student@123',
      );

      expect(user.id, 'student_1');
      expect(user.role.name, 'student');
      expect(user.roomId, 'room_b413');
      expect(await tokenStorage.readAuthToken(), 'signed-token');
    });

    test('authorized requests include the persisted bearer token', () async {
      final InMemoryTokenStorage tokenStorage =
          InMemoryTokenStorage('persisted-token');
      final ApiHostelRepository repository = ApiHostelRepository(
        baseUrl: 'http://127.0.0.1:8000',
        tokenStorage: tokenStorage,
        client: MockClient((http.Request request) async {
          expect(
            request.headers['authorization'] ??
                request.headers['Authorization'],
            'Bearer persisted-token',
          );
          return http.Response(
            jsonEncode(
              <String, dynamic>{
                'requiresBootstrap': false,
                'demoMode': true,
              },
            ),
            200,
            headers: <String, String>{
              'content-type': 'application/json',
            },
          );
        }),
      );

      final status = await repository.getSetupStatus();

      expect(status.demoMode, isTrue);
    });

    test('snake_case payload keys are normalized during decoding', () async {
      final ApiHostelRepository repository = ApiHostelRepository(
        baseUrl: 'http://127.0.0.1:8000',
        tokenStorage: InMemoryTokenStorage(),
        client: MockClient((http.Request request) async {
          expect(request.url.path, '/rooms');
          return http.Response(
            jsonEncode(
              <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 'room_a102',
                  'block': 'A',
                  'number': '102',
                  'capacity': 2,
                  'room_type': 'Double Sharing',
                  'resident_ids': <String>['student_4'],
                },
              ],
            ),
            200,
            headers: <String, String>{
              'content-type': 'application/json',
            },
          );
        }),
      );

      final rooms = await repository.getRooms();

      expect(rooms.first.roomType, 'Double Sharing');
      expect(rooms.first.residentIds, <String>['student_4']);
    });

    test('getUser fetches the current user by id', () async {
      final ApiHostelRepository repository = ApiHostelRepository(
        baseUrl: 'http://127.0.0.1:8000',
        tokenStorage: InMemoryTokenStorage(),
        client: MockClient((http.Request request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/users/admin_1');
          return http.Response(
            jsonEncode(
              <String, dynamic>{
                'id': 'admin_1',
                'username': 'admin',
                'firstName': 'Hostel',
                'lastName': 'Admin',
                'email': 'admin@yourhostel.com',
                'phoneNumber': '9800000000',
                'role': 'admin',
                'roomId': null,
                'jobTitle': 'Hostel Admin',
                'emailVerified': true,
                'emailVerifiedAt': '2026-03-10T15:47:09.429223+00:00',
              },
            ),
            200,
            headers: <String, String>{
              'content-type': 'application/json',
            },
          );
        }),
      );

      final user = await repository.getUser('admin_1');

      expect(user.id, 'admin_1');
      expect(user.role.name, 'admin');
      expect(user.emailVerified, isTrue);
    });

    test('getRooms parses resident ids and room metadata', () async {
      final ApiHostelRepository repository = ApiHostelRepository(
        baseUrl: 'http://127.0.0.1:8000',
        tokenStorage: InMemoryTokenStorage(),
        client: MockClient((http.Request request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/rooms');
          return http.Response(
            jsonEncode(
              <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 'room_a102',
                  'block': 'A',
                  'number': '102',
                  'capacity': 2,
                  'roomType': 'Double Sharing',
                  'residentIds': <String>['student_4'],
                },
              ],
            ),
            200,
            headers: <String, String>{
              'content-type': 'application/json',
            },
          );
        }),
      );

      final rooms = await repository.getRooms();

      expect(rooms, hasLength(1));
      expect(rooms.first.label, 'A-102');
      expect(rooms.first.occupiedBeds, 1);
    });

    test('assignResidentRoom sends patch payload and parses response',
        () async {
      final ApiHostelRepository repository = ApiHostelRepository(
        baseUrl: 'http://127.0.0.1:8000',
        tokenStorage: InMemoryTokenStorage(),
        client: MockClient((http.Request request) async {
          expect(request.method, 'PATCH');
          expect(request.url.path, '/students/student_1/room');
          final Map<String, dynamic> payload =
              jsonDecode(request.body) as Map<String, dynamic>;
          expect(payload['roomId'], 'room_e301');
          return http.Response(
            jsonEncode(
              <String, dynamic>{
                'id': 'student_1',
                'username': 'aayush',
                'firstName': 'Aayush',
                'lastName': 'DC',
                'email': 'aayush.dc@hostelhub.edu',
                'phoneNumber': '9876543210',
                'role': 'student',
                'roomId': 'room_e301',
                'jobTitle': null,
                'emailVerified': true,
                'emailVerifiedAt': '2026-01-07T00:00:00+00:00',
              },
            ),
            200,
            headers: <String, String>{
              'content-type': 'application/json',
            },
          );
        }),
      );

      final user = await repository.assignResidentRoom(
        userId: 'student_1',
        roomId: 'room_e301',
      );

      expect(user.roomId, 'room_e301');
    });

    test('registerGuest posts guest payload and parses response', () async {
      final ApiHostelRepository repository = ApiHostelRepository(
        baseUrl: 'http://127.0.0.1:8000',
        tokenStorage: InMemoryTokenStorage(),
        client: MockClient((http.Request request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/auth/register-guest');
          final Map<String, dynamic> payload =
              jsonDecode(request.body) as Map<String, dynamic>;
          expect(payload['email'], 'guest.arrival@hostelhub.edu');
          return http.Response(
            jsonEncode(
              <String, dynamic>{
                'id': 'guest_2',
                'username': 'guestarrival',
                'firstName': 'Guest',
                'lastName': 'Arrival',
                'email': 'guest.arrival@hostelhub.edu',
                'phoneNumber': '9801111113',
                'role': 'guest',
                'roomId': null,
                'jobTitle': null,
                'emailVerified': false,
                'emailVerifiedAt': null,
              },
            ),
            201,
            headers: <String, String>{
              'content-type': 'application/json',
            },
          );
        }),
      );

      final user = await repository.registerGuest(
        username: 'guestarrival',
        firstName: 'Guest',
        lastName: 'Arrival',
        email: 'guest.arrival@hostelhub.edu',
        password: 'Guest@123',
        phoneNumber: '9801111113',
      );

      expect(user.role.name, 'guest');
      expect(user.roomId, isNull);
    });

    test('bootstrapAdmin posts clean-start admin payload', () async {
      final ApiHostelRepository repository = ApiHostelRepository(
        baseUrl: 'http://127.0.0.1:8000',
        tokenStorage: InMemoryTokenStorage(),
        client: MockClient((http.Request request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/auth/bootstrap-admin');
          return http.Response(
            jsonEncode(
              <String, dynamic>{
                'id': 'admin_1',
                'username': 'owner',
                'firstName': 'Owner',
                'lastName': 'Admin',
                'email': 'owner@hostelhub.edu',
                'phoneNumber': '9807777777',
                'role': 'admin',
                'roomId': null,
                'jobTitle': 'Hostel Admin',
                'emailVerified': true,
                'emailVerifiedAt': '2026-03-09T10:00:00+00:00',
              },
            ),
            201,
            headers: <String, String>{
              'content-type': 'application/json',
            },
          );
        }),
      );

      final user = await repository.bootstrapAdmin(
        username: 'owner',
        firstName: 'Owner',
        lastName: 'Admin',
        email: 'owner@hostelhub.edu',
        password: 'Admin@123',
        phoneNumber: '9807777777',
      );

      expect(user.role.name, 'admin');
      expect(user.emailVerified, isTrue);
    });

    test('requestEmailVerification parses delivery method', () async {
      final ApiHostelRepository repository = ApiHostelRepository(
        baseUrl: 'http://127.0.0.1:8000',
        tokenStorage: InMemoryTokenStorage(),
        client: MockClient((http.Request request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/auth/verify-email/request');
          return http.Response(
            jsonEncode(
              <String, dynamic>{
                'email': 'verify.me@gmail.com',
                'code': '123456',
                'expiresAt': '2026-03-10T12:30:00+00:00',
                'deliveryMethod': 'email',
              },
            ),
            200,
            headers: <String, String>{
              'content-type': 'application/json',
            },
          );
        }),
      );

      final challenge = await repository.requestEmailVerification(
        email: 'verify.me@gmail.com',
      );

      expect(challenge.isEmailDelivered, isTrue);
      expect(challenge.usesLocalCode, isFalse);
    });

    test('getNotifications parses chat notification payloads', () async {
      final ApiHostelRepository repository = ApiHostelRepository(
        baseUrl: 'http://127.0.0.1:8000',
        tokenStorage: InMemoryTokenStorage(),
        client: MockClient((http.Request request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/notifications/staff_1');
          return http.Response(
            jsonEncode(
              <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 'notification_401',
                  'userId': 'staff_1',
                  'title': 'New message',
                  'message': 'Aayush DC: Need help with my room.',
                  'type': 'chat',
                  'createdAt': '2026-03-10T12:45:00+00:00',
                  'readAt': null,
                },
              ],
            ),
            200,
            headers: <String, String>{
              'content-type': 'application/json',
            },
          );
        }),
      );

      final notifications = await repository.getNotifications('staff_1');

      expect(notifications, hasLength(1));
      expect(notifications.first.resolvedType.name, 'chat');
    });

    test('updateFeeSettings sends patch payload and parses response', () async {
      final ApiHostelRepository repository = ApiHostelRepository(
        baseUrl: 'http://127.0.0.1:8000',
        tokenStorage: InMemoryTokenStorage(),
        client: MockClient((http.Request request) async {
          expect(request.method, 'PATCH');
          expect(request.url.path, '/fee-settings');
          final Map<String, dynamic> payload =
              jsonDecode(request.body) as Map<String, dynamic>;
          expect(payload['doubleSharingCharge'], 5600);
          return http.Response(
            jsonEncode(
              <String, dynamic>{
                'maintenanceCharge': 1500,
                'parkingCharge': 450,
                'waterCharge': 600,
                'singleOccupancyCharge': 7000,
                'doubleSharingCharge': 5600,
                'tripleSharingCharge': 4700,
                'customCharges': <Map<String, dynamic>>[
                  <String, dynamic>{'label': 'Wi-Fi', 'amount': 300},
                ],
              },
            ),
            200,
            headers: <String, String>{
              'content-type': 'application/json',
            },
          );
        }),
      );

      final settings = await repository.updateFeeSettings(
        maintenanceCharge: 1500,
        parkingCharge: 450,
        waterCharge: 600,
        singleOccupancyCharge: 7000,
        doubleSharingCharge: 5600,
        tripleSharingCharge: 4700,
        customCharges: const <FeeChargeItem>[
          FeeChargeItem(label: 'Wi-Fi', amount: 300),
        ],
      );

      expect(settings.maintenanceCharge, 1500);
      expect(settings.doubleSharingCharge, 5600);
      expect(settings.customCharges.first.label, 'Wi-Fi');
    });
  });
}
