import '../../core/config/app_environment.dart';
import '../../core/services/api_hostel_repository.dart';
import '../../core/services/hostel_repository.dart';
import '../../core/services/mock_hostel_repository.dart';
import '../../core/services/session_store.dart';

Future<HostelRepository> buildHostelRepository({
  SessionStore? sessionStore,
}) async {
  final SessionStore store =
      sessionStore ?? const SharedPreferencesSessionStore();
  final String? storedBaseUrl = await store.readBackendBaseUrl();
  final String? baseUrl = AppEnvironment.resolvePythonApiBaseUrl(
    storedBaseUrl: storedBaseUrl,
  );
  if (baseUrl != null) {
    return ApiHostelRepository(baseUrl: baseUrl);
  }
  return MockHostelRepository(seedDemoData: AppEnvironment.demoMode);
}
