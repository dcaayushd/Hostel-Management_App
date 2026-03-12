String normalizeNoticeCategoryLabel(String value) {
  return value.trim();
}

class NoticeItem {
  const NoticeItem({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.postedAt,
    this.isPinned = false,
  });

  final String id;
  final String title;
  final String message;
  final String category;
  final DateTime postedAt;
  final bool isPinned;

  NoticeItem copyWith({
    String? id,
    String? title,
    String? message,
    String? category,
    DateTime? postedAt,
    bool? isPinned,
  }) {
    return NoticeItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      postedAt: postedAt ?? this.postedAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
