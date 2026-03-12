import '../../core/config/app_environment.dart';
import '../../core/services/api_hostel_repository.dart';
import '../../core/services/hostel_repository.dart';
import '../../core/services/mock_hostel_repository.dart';

HostelRepository? _repository;

HostelRepository buildHostelRepository() {
  return _repository ??= _createRepository();
}

HostelRepository _createRepository() {
  final String? baseUrl = AppEnvironment.pythonApiBaseUrl;
  if (baseUrl != null) {
    return ApiHostelRepository();
  }
  return MockHostelRepository(seedDemoData: AppEnvironment.demoMode);
}
