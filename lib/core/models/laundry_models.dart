enum LaundryBookingStatus {
  scheduled,
  completed,
  cancelled,
}

extension LaundryBookingStatusX on LaundryBookingStatus {
  String get value {
    switch (this) {
      case LaundryBookingStatus.scheduled:
        return 'scheduled';
      case LaundryBookingStatus.completed:
        return 'completed';
      case LaundryBookingStatus.cancelled:
        return 'cancelled';
    }
  }

  String get label {
    switch (this) {
      case LaundryBookingStatus.scheduled:
        return 'Scheduled';
      case LaundryBookingStatus.completed:
        return 'Completed';
      case LaundryBookingStatus.cancelled:
        return 'Cancelled';
    }
  }
}

LaundryBookingStatus laundryBookingStatusFromValue(String value) {
  return LaundryBookingStatus.values.firstWhere(
    (LaundryBookingStatus status) => status.value == value,
  );
}

class LaundryBooking {
  const LaundryBooking({
    required this.id,
    required this.userId,
    required this.machineLabel,
    required this.slotLabel,
    required this.scheduledAt,
    required this.notes,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  final String id;
  final String userId;
  final String machineLabel;
  final String slotLabel;
  final DateTime scheduledAt;
  final String notes;
  final LaundryBookingStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  bool get isActive => status == LaundryBookingStatus.scheduled;

  LaundryBooking copyWith({
    String? id,
    String? userId,
    String? machineLabel,
    String? slotLabel,
    DateTime? scheduledAt,
    String? notes,
    LaundryBookingStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return LaundryBooking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      machineLabel: machineLabel ?? this.machineLabel,
      slotLabel: slotLabel ?? this.slotLabel,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
    );
  }
}
