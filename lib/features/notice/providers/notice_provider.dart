import 'package:flutter/foundation.dart';

import '../../../core/models/failure.dart';
import '../../../core/models/notice_item.dart';
import '../../../core/services/hostel_repository.dart';

class NoticeProvider extends ChangeNotifier {
  NoticeProvider(this._repository);

  final HostelRepository _repository;

  bool _isLoading = false;
  Failure? _lastFailure;
  List<NoticeItem> _notices = const <NoticeItem>[];

  bool get isLoading => _isLoading;

  Failure? get lastFailure => _lastFailure;

  List<NoticeItem> get notices => List<NoticeItem>.unmodifiable(_notices);

  Future<void> loadNotices() async {
    _setLoading(true);
    try {
      _notices = _sorted(await _repository.getNotices());
      _lastFailure = null;
      notifyListeners();
    } on HostelRepositoryException catch (error) {
      _lastFailure = error.failure;
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<NoticeItem> createNotice({
    required String title,
    required String message,
    required String category,
    bool isPinned = false,
  }) async {
    final NoticeItem notice = await _repository.createNotice(
      title: title,
      message: message,
      category: category,
      isPinned: isPinned,
    );
    _notices = _sorted(<NoticeItem>[notice, ..._notices]);
    _lastFailure = null;
    notifyListeners();
    return notice;
  }

  List<NoticeItem> _sorted(List<NoticeItem> notices) {
    final List<NoticeItem> sorted = List<NoticeItem>.from(notices);
    sorted.sort((NoticeItem a, NoticeItem b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      return b.postedAt.compareTo(a.postedAt);
    });
    return sorted;
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }
}
