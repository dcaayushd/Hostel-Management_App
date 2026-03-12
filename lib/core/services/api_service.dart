import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_environment.dart';
import '../models/failure.dart';
import 'hostel_repository.dart';
import 'secure_storage.dart';

class ApiService {
  ApiService._({
    required String baseUrl,
    required http.Client client,
    required TokenStorage tokenStorage,
  })  : _baseUrl = _normalizeBaseUrl(baseUrl),
        _client = client,
        _tokenStorage = tokenStorage;

  static ApiService? _shared;

  factory ApiService({
    String? baseUrl,
    http.Client? client,
    TokenStorage? tokenStorage,
  }) {
    final String resolvedBaseUrl =
        baseUrl ?? AppEnvironment.pythonApiBaseUrl ?? '';
    if (resolvedBaseUrl.trim().isEmpty) {
      throw StateError('A backend base URL is required for ApiService.');
    }
    if (baseUrl == null && client == null && tokenStorage == null) {
      return _shared ??= ApiService._(
        baseUrl: resolvedBaseUrl,
        client: http.Client(),
        tokenStorage: const SecureStorageHelper(),
      );
    }
    return ApiService._(
      baseUrl: resolvedBaseUrl,
      client: client ?? http.Client(),
      tokenStorage: tokenStorage ?? const SecureStorageHelper(),
    );
  }

  final String _baseUrl;
  final http.Client _client;
  final TokenStorage _tokenStorage;

  Future<dynamic> requestJson({
    required String method,
    required String path,
    Map<String, dynamic>? body,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl$path');
    final http.Request request = http.Request(method, uri);
    request.headers['Accept'] = 'application/json';
    request.headers['Content-Type'] = 'application/json';

    final String? authToken = await _tokenStorage.readAuthToken();
    if (authToken != null && authToken.trim().isNotEmpty) {
      request.headers['Authorization'] = 'Bearer ${authToken.trim()}';
    }

    if (body != null) {
      request.body = jsonEncode(body);
    }

    try {
      final http.StreamedResponse streamedResponse =
          await _client.send(request).timeout(const Duration(seconds: 10));
      final http.Response response = await http.Response.fromStream(
        streamedResponse,
      );
      final dynamic payload = response.body.isEmpty
          ? null
          : _normalizeJson(jsonDecode(response.body));

      if (response.statusCode >= 400) {
        if (response.statusCode == 401) {
          await _tokenStorage.clearAuthToken();
        }
        throw HostelRepositoryException.fromFailure(
          _failureFromResponse(response.statusCode, payload),
        );
      }

      return payload;
    } on SocketException {
      throw HostelRepositoryConnectionException.fromFailure(
        const Failure(
          message:
              'No internet connection or backend access. Check your network and try again.',
          type: FailureType.network,
        ),
      );
    } on TimeoutException {
      throw HostelRepositoryConnectionException.fromFailure(
        const Failure(
          message: 'The backend did not respond in time.',
          type: FailureType.network,
        ),
      );
    } on http.ClientException {
      throw HostelRepositoryConnectionException.fromFailure(
        const Failure(
          message: 'Unable to reach the backend service.',
          type: FailureType.network,
        ),
      );
    } on FormatException {
      throw HostelRepositoryException.fromFailure(
        const Failure(
          message: 'Backend returned an invalid response.',
          type: FailureType.parsing,
        ),
      );
    }
  }

  Future<void> persistAuthToken(String token) async {
    if (token.trim().isEmpty) {
      return;
    }
    await _tokenStorage.writeAuthToken(token.trim());
  }

  Future<void> clearAuthToken() => _tokenStorage.clearAuthToken();

  static String _normalizeBaseUrl(String value) {
    final String trimmed = value.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  Failure _failureFromResponse(int statusCode, dynamic payload) {
    final String fallbackMessage = switch (statusCode) {
      401 => 'Your session has expired. Please sign in again.',
      403 => 'You do not have permission to perform this action.',
      >= 500 => 'The backend reported an internal error.',
      _ => 'Backend request failed.',
    };
    final String message =
        payload is Map<String, dynamic> && payload['message'] is String
            ? payload['message'] as String
            : fallbackMessage;

    if (statusCode == 401 || statusCode == 403) {
      return Failure(
        message: message,
        type: FailureType.unauthorized,
        statusCode: statusCode,
      );
    }
    if (statusCode >= 500) {
      return Failure(
        message: message,
        type: FailureType.backend,
        statusCode: statusCode,
      );
    }
    return Failure(
      message: message,
      type: FailureType.backend,
      statusCode: statusCode,
    );
  }

  dynamic _normalizeJson(dynamic value) {
    if (value is List<dynamic>) {
      return value.map(_normalizeJson).toList(growable: false);
    }
    if (value is Map<dynamic, dynamic>) {
      return <String, dynamic>{
        for (final MapEntry<dynamic, dynamic> entry in value.entries)
          _toCamelCase(entry.key.toString()): _normalizeJson(entry.value),
      };
    }
    return value;
  }

  String _toCamelCase(String value) {
    if (!value.contains('_')) {
      return value;
    }
    final List<String> parts = value.split('_');
    if (parts.isEmpty) {
      return value;
    }
    return parts.first +
        parts.skip(1).map((String part) {
          if (part.isEmpty) {
            return '';
          }
          return '${part[0].toUpperCase()}${part.substring(1)}';
        }).join();
  }
}
