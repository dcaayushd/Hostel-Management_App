enum ParcelStatus { awaitingPickup, collected }

extension ParcelStatusX on ParcelStatus {
  String get label {
    switch (this) {
      case ParcelStatus.awaitingPickup:
        return 'Awaiting pickup';
      case ParcelStatus.collected:
        return 'Collected';
    }
  }

  bool get isPending => this == ParcelStatus.awaitingPickup;
}

class ParcelItem {
  const ParcelItem({
    required this.id,
    required this.userId,
    required this.carrier,
    required this.trackingCode,
    required this.note,
    required this.status,
    required this.createdAt,
    this.notifiedAt,
    this.collectedAt,
  });

  final String id;
  final String userId;
  final String carrier;
  final String trackingCode;
  final String note;
  final ParcelStatus status;
  final DateTime createdAt;
  final DateTime? notifiedAt;
  final DateTime? collectedAt;

  ParcelItem copyWith({
    String? id,
    String? userId,
    String? carrier,
    String? trackingCode,
    String? note,
    ParcelStatus? status,
    DateTime? createdAt,
    DateTime? notifiedAt,
    DateTime? collectedAt,
    bool clearNotifiedAt = false,
    bool clearCollectedAt = false,
  }) {
    return ParcelItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      carrier: carrier ?? this.carrier,
      trackingCode: trackingCode ?? this.trackingCode,
      note: note ?? this.note,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      notifiedAt: clearNotifiedAt ? null : notifiedAt ?? this.notifiedAt,
      collectedAt: clearCollectedAt ? null : collectedAt ?? this.collectedAt,
    );
  }
}

class VisitorEntry {
  const VisitorEntry({
    required this.id,
    required this.studentId,
    required this.visitorName,
    required this.relation,
    required this.note,
    required this.checkedInAt,
    this.checkedOutAt,
  });

  final String id;
  final String studentId;
  final String visitorName;
  final String relation;
  final String note;
  final DateTime checkedInAt;
  final DateTime? checkedOutAt;

  bool get isActive => checkedOutAt == null;

  VisitorEntry copyWith({
    String? id,
    String? studentId,
    String? visitorName,
    String? relation,
    String? note,
    DateTime? checkedInAt,
    DateTime? checkedOutAt,
    bool clearCheckedOutAt = false,
  }) {
    return VisitorEntry(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      visitorName: visitorName ?? this.visitorName,
      relation: relation ?? this.relation,
      note: note ?? this.note,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      checkedOutAt:
          clearCheckedOutAt ? null : checkedOutAt ?? this.checkedOutAt,
    );
  }
}
