enum GatePassStatus {
  pending,
  approved,
  rejected,
  checkedOut,
  returned,
  late,
}

extension GatePassStatusX on GatePassStatus {
  String get label {
    switch (this) {
      case GatePassStatus.pending:
        return 'Pending';
      case GatePassStatus.approved:
        return 'Approved';
      case GatePassStatus.rejected:
        return 'Rejected';
      case GatePassStatus.checkedOut:
        return 'Checked out';
      case GatePassStatus.returned:
        return 'Returned';
      case GatePassStatus.late:
        return 'Late';
    }
  }

  bool get isPending => this == GatePassStatus.pending;

  bool get isApproved => this == GatePassStatus.approved;

  bool get isRejected => this == GatePassStatus.rejected;

  bool get isCheckedOut => this == GatePassStatus.checkedOut;

  bool get isReturned =>
      this == GatePassStatus.returned || this == GatePassStatus.late;
}

class GatePassRequest {
  const GatePassRequest({
    required this.id,
    required this.studentId,
    required this.destination,
    required this.reason,
    required this.emergencyContact,
    required this.passCode,
    required this.status,
    required this.departureAt,
    required this.expectedReturnAt,
    required this.createdAt,
    this.reviewedAt,
    this.checkedOutAt,
    this.returnedAt,
  });

  final String id;
  final String studentId;
  final String destination;
  final String reason;
  final String emergencyContact;
  final String passCode;
  final GatePassStatus status;
  final DateTime departureAt;
  final DateTime expectedReturnAt;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final DateTime? checkedOutAt;
  final DateTime? returnedAt;

  bool get isLateNow {
    if (status == GatePassStatus.late) {
      return true;
    }
    return status == GatePassStatus.checkedOut &&
        DateTime.now().isAfter(expectedReturnAt);
  }

  bool get canCheckOut => status == GatePassStatus.approved;

  bool get canMarkReturned =>
      status == GatePassStatus.checkedOut || status == GatePassStatus.late;

  String get qrPayload => 'HOSTEL:$passCode:$studentId';

  GatePassRequest copyWith({
    String? id,
    String? studentId,
    String? destination,
    String? reason,
    String? emergencyContact,
    String? passCode,
    GatePassStatus? status,
    DateTime? departureAt,
    DateTime? expectedReturnAt,
    DateTime? createdAt,
    DateTime? reviewedAt,
    DateTime? checkedOutAt,
    DateTime? returnedAt,
    bool clearReviewedAt = false,
    bool clearCheckedOutAt = false,
    bool clearReturnedAt = false,
  }) {
    return GatePassRequest(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      destination: destination ?? this.destination,
      reason: reason ?? this.reason,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      passCode: passCode ?? this.passCode,
      status: status ?? this.status,
      departureAt: departureAt ?? this.departureAt,
      expectedReturnAt: expectedReturnAt ?? this.expectedReturnAt,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: clearReviewedAt ? null : reviewedAt ?? this.reviewedAt,
      checkedOutAt:
          clearCheckedOutAt ? null : checkedOutAt ?? this.checkedOutAt,
      returnedAt: clearReturnedAt ? null : returnedAt ?? this.returnedAt,
    );
  }
}
