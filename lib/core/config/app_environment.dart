import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

class AppEnvironment {
  const AppEnvironment._();

  static const String _apiBaseUrl =
      String.fromEnvironment('HOSTEL_API_BASE_URL', defaultValue: '');
  static const bool _demoMode =
      bool.fromEnvironment('HOSTEL_DEMO_MODE', defaultValue: false);
  static const bool _forceMockBackend =
      bool.fromEnvironment('HOSTEL_FORCE_MOCK_BACKEND', defaultValue: false);

  static String? get pythonApiBaseUrl {
    final String? explicitBaseUrl = _normalizeBaseUrl(_apiBaseUrl);
    if (explicitBaseUrl != null) {
      return explicitBaseUrl;
    }
    if (_forceMockBackend || _isFlutterTest) {
      return null;
    }
    return _normalizeBaseUrl(_defaultLocalApiBaseUrl);
  }

  static bool get usesPythonBackend => pythonApiBaseUrl != null;

  static bool get demoMode => _demoMode;

  static bool get _isFlutterTest {
    final String? value = Platform.environment['FLUTTER_TEST'];
    return value != null && value != 'false';
  }

  static String get _defaultLocalApiBaseUrl {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      case TargetPlatform.fuchsia:
        return 'http://127.0.0.1:8000';
    }
  }

  static String? _normalizeBaseUrl(String? value) {
    if (value == null) {
      return null;
    }
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
