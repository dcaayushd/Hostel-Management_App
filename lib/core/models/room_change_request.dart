class RoomChangeRequest {
  const RoomChangeRequest({
    required this.id,
    required this.studentId,
    required this.currentRoomId,
    required this.desiredRoomId,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
  });

  final String id;
  final String studentId;
  final String currentRoomId;
  final String desiredRoomId;
  final String reason;
  final RoomRequestStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  RoomChangeRequest copyWith({
    String? id,
    String? studentId,
    String? currentRoomId,
    String? desiredRoomId,
    String? reason,
    RoomRequestStatus? status,
    DateTime? createdAt,
    DateTime? resolvedAt,
    bool clearResolvedAt = false,
  }) {
    return RoomChangeRequest(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      currentRoomId: currentRoomId ?? this.currentRoomId,
      desiredRoomId: desiredRoomId ?? this.desiredRoomId,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: clearResolvedAt ? null : resolvedAt ?? this.resolvedAt,
    );
  }
}

enum RoomRequestStatus { pending, approved, rejected }

extension RoomRequestStatusX on RoomRequestStatus {
  String get label {
    switch (this) {
      case RoomRequestStatus.pending:
        return 'Pending';
      case RoomRequestStatus.approved:
        return 'Approved';
      case RoomRequestStatus.rejected:
        return 'Rejected';
    }
  }

  bool get isPending => this == RoomRequestStatus.pending;
}
