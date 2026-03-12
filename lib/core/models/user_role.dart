enum UserRole { student, guest, staff, admin }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.guest:
        return 'Guest';
      case UserRole.staff:
        return 'Staff';
      case UserRole.admin:
        return 'Admin';
    }
  }

  bool get isStudent => this == UserRole.student;

  bool get isGuest => this == UserRole.guest;

  bool get isStaff => this == UserRole.staff;

  bool get canManageIssues => this == UserRole.admin || this == UserRole.staff;

  bool get canManageStaff => this == UserRole.admin;

  bool get canManageRoomRequests =>
      this == UserRole.admin || this == UserRole.staff;

  bool get canManageInventory => this == UserRole.admin;

  bool get canManageFeeSettings => this == UserRole.admin;

  bool get canCollectFees => this == UserRole.admin || this == UserRole.staff;

  bool get canManageNotices => this == UserRole.admin;

  bool get canManageMess => this == UserRole.admin || this == UserRole.staff;

  bool get canEditMessMenu => this == UserRole.admin;

  bool get canManageFrontDesk =>
      this == UserRole.admin || this == UserRole.staff;

  bool get canManageGatePass =>
      this == UserRole.admin || this == UserRole.staff;

  bool get canManageLaundry => this == UserRole.admin || this == UserRole.staff;
}
