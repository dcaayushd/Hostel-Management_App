class HostelBlock {
  const HostelBlock({
    required this.code,
    required this.name,
    this.description,
  });

  final String code;
  final String name;
  final String? description;

  String get label => name.trim().isEmpty ? 'Block $code' : name;

  HostelBlock copyWith({
    String? code,
    String? name,
    String? description,
    bool clearDescription = false,
  }) {
    return HostelBlock(
      code: code ?? this.code,
      name: name ?? this.name,
      description: clearDescription ? null : description ?? this.description,
    );
  }
}
