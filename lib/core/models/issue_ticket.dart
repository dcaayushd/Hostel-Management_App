class IssueTicket {
  const IssueTicket({
    required this.id,
    required this.studentId,
    required this.category,
    required this.comment,
    required this.status,
    required this.createdAt,
    this.assignedStaffId,
  });

  final String id;
  final String studentId;
  final String category;
  final String comment;
  final IssueStatus status;
  final DateTime createdAt;
  final String? assignedStaffId;

  IssueTicket copyWith({
    String? id,
    String? studentId,
    String? category,
    String? comment,
    IssueStatus? status,
    DateTime? createdAt,
    String? assignedStaffId,
    bool clearAssignedStaffId = false,
  }) {
    return IssueTicket(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      category: category ?? this.category,
      comment: comment ?? this.comment,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      assignedStaffId:
          clearAssignedStaffId ? null : assignedStaffId ?? this.assignedStaffId,
    );
  }
}

enum IssueStatus { open, inProgress, resolved }

extension IssueStatusX on IssueStatus {
  String get label {
    switch (this) {
      case IssueStatus.open:
        return 'Open';
      case IssueStatus.inProgress:
        return 'In Progress';
      case IssueStatus.resolved:
        return 'Resolved';
    }
  }

  bool get isResolved => this == IssueStatus.resolved;
}
