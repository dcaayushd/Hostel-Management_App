import 'user_role.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.role,
    this.roomId,
    this.jobTitle,
    this.emailVerified = false,
    this.emailVerifiedAt,
  });

  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phoneNumber;
  final UserRole role;
  final String? roomId;
  final String? jobTitle;
  final bool emailVerified;
  final DateTime? emailVerifiedAt;

  String get fullName => '$firstName $lastName';

  String get normalizedJobTitle => (jobTitle ?? '').trim().toLowerCase();

  bool get isAdmin => role == UserRole.admin;

  bool get isWarden =>
      isAdmin ||
      (role == UserRole.staff && normalizedJobTitle.contains('warden'));

  bool get isSpecialistStaff => role == UserRole.staff && !isWarden;

  String get accessLabel {
    if (isAdmin) {
      return 'Admin';
    }
    if (isWarden) {
      return 'Warden';
    }
    return role.label;
  }

  bool get canAssignIssues => isAdmin || isWarden;

  bool get canManageIssues => isAdmin || isWarden;

  bool get canWorkOnIssues => isAdmin || role == UserRole.staff;

  bool get canManageStaff => isAdmin;

  bool get canManageRoomRequests => isAdmin || isWarden;

  bool get canViewResidents => isAdmin || isWarden;

  bool get canManageInventory => isAdmin;

  bool get canManageFeeSettings => isAdmin;

  bool get canCollectFees => isAdmin || isWarden;

  bool get canManageNotices => isAdmin || isWarden;

  bool get canManageMess => isAdmin || isWarden;

  bool get canEditMessMenu => isAdmin || isWarden;

  bool get canManageFrontDesk => isAdmin || isWarden;

  bool get canManageGatePass => isAdmin || isWarden;

  bool get canManageLaundry => isAdmin || isWarden;

  bool get canViewStaffDirectory =>
      role != UserRole.student && role != UserRole.guest;

  AppUser copyWith({
    String? id,
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? phoneNumber,
    UserRole? role,
    String? roomId,
    String? jobTitle,
    bool? emailVerified,
    DateTime? emailVerifiedAt,
    bool clearRoomId = false,
    bool clearJobTitle = false,
    bool clearEmailVerifiedAt = false,
  }) {
    return AppUser(
      id: id ?? this.id,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      roomId: clearRoomId ? null : roomId ?? this.roomId,
      jobTitle: clearJobTitle ? null : jobTitle ?? this.jobTitle,
      emailVerified: emailVerified ?? this.emailVerified,
      emailVerifiedAt:
          clearEmailVerifiedAt ? null : emailVerifiedAt ?? this.emailVerifiedAt,
    );
  }
}
