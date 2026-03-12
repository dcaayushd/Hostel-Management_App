enum HostelNotificationType {
  fee,
  notice,
  chat,
  complaint,
  roomChange,
  parcel,
  gatePass,
}

extension HostelNotificationTypeX on HostelNotificationType {
  String get label {
    switch (this) {
      case HostelNotificationType.fee:
        return 'Fee';
      case HostelNotificationType.notice:
        return 'Notice';
      case HostelNotificationType.chat:
        return 'Message';
      case HostelNotificationType.complaint:
        return 'Complaint';
      case HostelNotificationType.roomChange:
        return 'Room change';
      case HostelNotificationType.parcel:
        return 'Parcel';
      case HostelNotificationType.gatePass:
        return 'Gate pass';
    }
  }
}

class HostelNotificationItem {
  const HostelNotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.readAt,
  });

  final String id;
  final String userId;
  final String title;
  final String message;
  final HostelNotificationType type;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get isRead => readAt != null;

  bool get isLegacyChatNotification =>
      type == HostelNotificationType.notice &&
      title.trim().toLowerCase() == 'new message';

  HostelNotificationType get resolvedType =>
      isLegacyChatNotification ? HostelNotificationType.chat : type;

  HostelNotificationItem copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    HostelNotificationType? type,
    DateTime? createdAt,
    DateTime? readAt,
    bool clearReadAt = false,
  }) {
    return HostelNotificationItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      readAt: clearReadAt ? null : readAt ?? this.readAt,
    );
  }
}
