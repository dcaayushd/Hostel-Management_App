class SetupStatus {
  const SetupStatus({
    required this.requiresBootstrap,
    required this.demoMode,
  });

  final bool requiresBootstrap;
  final bool demoMode;

  SetupStatus copyWith({
    bool? requiresBootstrap,
    bool? demoMode,
  }) {
    return SetupStatus(
      requiresBootstrap: requiresBootstrap ?? this.requiresBootstrap,
      demoMode: demoMode ?? this.demoMode,
    );
  }
}
