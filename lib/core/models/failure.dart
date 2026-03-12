enum FailureType {
  backend,
  unauthorized,
  network,
  parsing,
  unknown,
}

class Failure {
  const Failure({
    required this.message,
    required this.type,
    this.statusCode,
  });

  final String message;
  final FailureType type;
  final int? statusCode;

  bool get isNetworkIssue => type == FailureType.network;

  bool get isUnauthorized => type == FailureType.unauthorized;
}
