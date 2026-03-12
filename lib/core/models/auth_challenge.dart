enum AuthChallengeDeliveryMethod { local, email }

class AuthChallenge {
  const AuthChallenge({
    required this.email,
    required this.code,
    required this.expiresAt,
    this.deliveryMethod = AuthChallengeDeliveryMethod.local,
    this.deliveryError,
  });

  final String email;
  final String code;
  final DateTime expiresAt;
  final AuthChallengeDeliveryMethod deliveryMethod;
  final String? deliveryError;

  bool get isExpired => expiresAt.isBefore(DateTime.now());

  bool get isEmailDelivered =>
      deliveryMethod == AuthChallengeDeliveryMethod.email;

  bool get usesLocalCode => deliveryMethod == AuthChallengeDeliveryMethod.local;

  AuthChallenge copyWith({
    String? email,
    String? code,
    DateTime? expiresAt,
    AuthChallengeDeliveryMethod? deliveryMethod,
    String? deliveryError,
  }) {
    return AuthChallenge(
      email: email ?? this.email,
      code: code ?? this.code,
      expiresAt: expiresAt ?? this.expiresAt,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      deliveryError: deliveryError ?? this.deliveryError,
    );
  }
}
