enum PaymentMethod { eSewa, card, bankTransfer, cash }

enum PaymentStatus { paid }

extension PaymentMethodX on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.eSewa:
        return 'eSewa';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.bankTransfer:
        return 'Bank';
      case PaymentMethod.cash:
        return 'Cash';
    }
  }

  String get subtitle {
    switch (this) {
      case PaymentMethod.eSewa:
        return 'Wallet';
      case PaymentMethod.card:
        return 'Visa / MasterCard';
      case PaymentMethod.bankTransfer:
        return 'Direct transfer';
      case PaymentMethod.cash:
        return 'Collected by staff';
    }
  }
}

extension PaymentStatusX on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.paid:
        return 'Paid';
    }
  }
}

class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.userId,
    required this.amount,
    required this.method,
    required this.status,
    required this.receiptId,
    required this.billingMonth,
    required this.paidAt,
  });

  final String id;
  final String userId;
  final int amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final String receiptId;
  final String billingMonth;
  final DateTime paidAt;

  PaymentRecord copyWith({
    String? id,
    String? userId,
    int? amount,
    PaymentMethod? method,
    PaymentStatus? status,
    String? receiptId,
    String? billingMonth,
    DateTime? paidAt,
  }) {
    return PaymentRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      receiptId: receiptId ?? this.receiptId,
      billingMonth: billingMonth ?? this.billingMonth,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}
