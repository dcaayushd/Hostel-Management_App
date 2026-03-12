import 'package:shared_preferences/shared_preferences.dart';

import 'secure_storage.dart';

abstract interface class SessionStore {
  Future<String?> readUserId();

  Future<void> writeUserId(String userId);

  Future<String?> readThemeMode();

  Future<void> writeThemeMode(String themeMode);

  Future<bool?> readInAppNotificationsEnabled();

  Future<void> writeInAppNotificationsEnabled(bool value);

  Future<bool?> readNotificationPreviewsEnabled();

  Future<void> writeNotificationPreviewsEnabled(bool value);

  Future<bool?> readNotificationBadgesEnabled();

  Future<void> writeNotificationBadgesEnabled(bool value);

  Future<bool?> readActivityAutoRefreshEnabled();

  Future<void> writeActivityAutoRefreshEnabled(bool value);

  Future<bool?> readShowRoomDetailsOnCards();

  Future<void> writeShowRoomDetailsOnCards(bool value);

  Future<bool?> readShowContactInfoOnCards();

  Future<void> writeShowContactInfoOnCards(bool value);

  Future<void> clearAppPreferences();

  Future<void> clear();
}

class SharedPreferencesSessionStore implements SessionStore {
  const SharedPreferencesSessionStore({
    TokenStorage? tokenStorage,
  }) : _tokenStorage = tokenStorage ?? const SecureStorageHelper();

  static const String _userIdKey = 'session_user_id';
  static const String _themeModeKey = 'theme_mode';
  static const String _inAppNotificationsKey = 'in_app_notifications_enabled';
  static const String _notificationPreviewsKey =
      'notification_previews_enabled';
  static const String _notificationBadgesKey = 'notification_badges_enabled';
  static const String _activityAutoRefreshKey = 'activity_auto_refresh_enabled';
  static const String _showRoomDetailsOnCardsKey = 'show_room_details_on_cards';
  static const String _showContactInfoOnCardsKey = 'show_contact_info_on_cards';

  final TokenStorage _tokenStorage;

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<String?> readUserId() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(_userIdKey);
  }

  @override
  Future<void> writeUserId(String userId) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(_userIdKey, userId);
  }

  @override
  Future<String?> readThemeMode() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(_themeModeKey);
  }

  @override
  Future<void> writeThemeMode(String themeMode) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(_themeModeKey, themeMode);
  }

  @override
  Future<bool?> readInAppNotificationsEnabled() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(_inAppNotificationsKey);
  }

  @override
  Future<void> writeInAppNotificationsEnabled(bool value) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setBool(_inAppNotificationsKey, value);
  }

  @override
  Future<bool?> readNotificationPreviewsEnabled() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(_notificationPreviewsKey);
  }

  @override
  Future<void> writeNotificationPreviewsEnabled(bool value) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setBool(_notificationPreviewsKey, value);
  }

  @override
  Future<bool?> readNotificationBadgesEnabled() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(_notificationBadgesKey);
  }

  @override
  Future<void> writeNotificationBadgesEnabled(bool value) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setBool(_notificationBadgesKey, value);
  }

  @override
  Future<bool?> readActivityAutoRefreshEnabled() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(_activityAutoRefreshKey);
  }

  @override
  Future<void> writeActivityAutoRefreshEnabled(bool value) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setBool(_activityAutoRefreshKey, value);
  }

  @override
  Future<bool?> readShowRoomDetailsOnCards() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(_showRoomDetailsOnCardsKey);
  }

  @override
  Future<void> writeShowRoomDetailsOnCards(bool value) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setBool(_showRoomDetailsOnCardsKey, value);
  }

  @override
  Future<bool?> readShowContactInfoOnCards() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(_showContactInfoOnCardsKey);
  }

  @override
  Future<void> writeShowContactInfoOnCards(bool value) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setBool(_showContactInfoOnCardsKey, value);
  }

  @override
  Future<void> clearAppPreferences() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove(_themeModeKey);
    await prefs.remove(_inAppNotificationsKey);
    await prefs.remove(_notificationPreviewsKey);
    await prefs.remove(_notificationBadgesKey);
    await prefs.remove(_activityAutoRefreshKey);
    await prefs.remove(_showRoomDetailsOnCardsKey);
    await prefs.remove(_showContactInfoOnCardsKey);
  }

  @override
  Future<void> clear() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove(_userIdKey);
    await _tokenStorage.clearAuthToken();
  }
}
