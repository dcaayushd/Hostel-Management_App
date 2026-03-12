import 'fee_charge_item.dart';

class FeeSettings {
  const FeeSettings({
    required this.maintenanceCharge,
    required this.parkingCharge,
    required this.waterCharge,
    required this.singleOccupancyCharge,
    required this.doubleSharingCharge,
    required this.tripleSharingCharge,
    this.customCharges = const <FeeChargeItem>[],
  });

  final int maintenanceCharge;
  final int parkingCharge;
  final int waterCharge;
  final int singleOccupancyCharge;
  final int doubleSharingCharge;
  final int tripleSharingCharge;
  final List<FeeChargeItem> customCharges;

  FeeSettings copyWith({
    int? maintenanceCharge,
    int? parkingCharge,
    int? waterCharge,
    int? singleOccupancyCharge,
    int? doubleSharingCharge,
    int? tripleSharingCharge,
    List<FeeChargeItem>? customCharges,
  }) {
    return FeeSettings(
      maintenanceCharge: maintenanceCharge ?? this.maintenanceCharge,
      parkingCharge: parkingCharge ?? this.parkingCharge,
      waterCharge: waterCharge ?? this.waterCharge,
      singleOccupancyCharge:
          singleOccupancyCharge ?? this.singleOccupancyCharge,
      doubleSharingCharge: doubleSharingCharge ?? this.doubleSharingCharge,
      tripleSharingCharge: tripleSharingCharge ?? this.tripleSharingCharge,
      customCharges: customCharges ?? this.customCharges,
    );
  }
}
