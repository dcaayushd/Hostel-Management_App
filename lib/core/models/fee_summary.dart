import 'fee_charge_item.dart';

class FeeSummary {
  const FeeSummary({
    required this.maintenanceCharge,
    required this.parkingCharge,
    required this.waterCharge,
    required this.roomCharge,
    this.additionalCharges = const <FeeChargeItem>[],
    this.billingMonth = 'Current cycle',
    this.paidAmount = 0,
    this.dueDate,
    this.lastReminderAt,
  });

  final int maintenanceCharge;
  final int parkingCharge;
  final int waterCharge;
  final int roomCharge;
  final List<FeeChargeItem> additionalCharges;
  final String billingMonth;
  final int paidAmount;
  final DateTime? dueDate;
  final DateTime? lastReminderAt;

  int get total =>
      maintenanceCharge +
      parkingCharge +
      waterCharge +
      roomCharge +
      additionalCharges.fold<int>(
        0,
        (int sum, FeeChargeItem item) => sum + item.amount,
      );

  int get balance {
    final int remaining = total - paidAmount;
    return remaining < 0 ? 0 : remaining;
  }

  bool get isPaid => balance == 0;

  FeeSummary copyWith({
    int? maintenanceCharge,
    int? parkingCharge,
    int? waterCharge,
    int? roomCharge,
    List<FeeChargeItem>? additionalCharges,
    String? billingMonth,
    int? paidAmount,
    DateTime? dueDate,
    DateTime? lastReminderAt,
    bool clearLastReminderAt = false,
  }) {
    return FeeSummary(
      maintenanceCharge: maintenanceCharge ?? this.maintenanceCharge,
      parkingCharge: parkingCharge ?? this.parkingCharge,
      waterCharge: waterCharge ?? this.waterCharge,
      roomCharge: roomCharge ?? this.roomCharge,
      additionalCharges: additionalCharges ?? this.additionalCharges,
      billingMonth: billingMonth ?? this.billingMonth,
      paidAmount: paidAmount ?? this.paidAmount,
      dueDate: dueDate ?? this.dueDate,
      lastReminderAt:
          clearLastReminderAt ? null : lastReminderAt ?? this.lastReminderAt,
    );
  }
}
