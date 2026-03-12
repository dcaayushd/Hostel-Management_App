class FeeChargeItem {
  const FeeChargeItem({
    required this.label,
    required this.amount,
  });

  final String label;
  final int amount;

  FeeChargeItem copyWith({
    String? label,
    int? amount,
  }) {
    return FeeChargeItem(
      label: label ?? this.label,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'label': label,
      'amount': amount,
    };
  }

  static FeeChargeItem fromJson(Map<String, dynamic> json) {
    return FeeChargeItem(
      label: json['label'] as String? ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
    );
  }
}
