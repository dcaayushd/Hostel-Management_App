class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.message,
    required this.sentAt,
    this.readAt,
  });

  final String id;
  final String senderId;
  final String recipientId;
  final String message;
  final DateTime sentAt;
  final DateTime? readAt;

  bool get isRead => readAt != null;

  bool involves(String userId) {
    return senderId == userId || recipientId == userId;
  }

  String counterpartFor(String userId) {
    return senderId == userId ? recipientId : senderId;
  }

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? recipientId,
    String? message,
    DateTime? sentAt,
    DateTime? readAt,
    bool clearReadAt = false,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      message: message ?? this.message,
      sentAt: sentAt ?? this.sentAt,
      readAt: clearReadAt ? null : readAt ?? this.readAt,
    );
  }
}
