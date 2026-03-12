part of '../screens/hostel_fee_screen.dart';

class _AdminFeeView extends StatelessWidget {
  const _AdminFeeView({
    required this.state,
    required this.filteredStudents,
    required this.settledStudents,
    required this.showOnlyDues,
    required this.activeFilter,
    required this.residentListTitle,
    required this.residentListDescription,
    required this.canEditSettings,
    required this.formKey,
    required this.electricityController,
    required this.waterController,
    required this.maintenanceController,
    required this.parkingController,
    required this.singleController,
    required this.doubleController,
    required this.tripleController,
    required this.customCharges,
    required this.onAddCustomCharge,
    required this.onEditCustomCharge,
    required this.onRemoveCustomCharge,
    required this.onSave,
    required this.onSendReminder,
    required this.onCollectFee,
    required this.onOpenReceipt,
  });

  final AppState state;
  final List<AppUser> filteredStudents;
  final List<AppUser> settledStudents;
  final bool showOnlyDues;
  final FeeScreenFilter? activeFilter;
  final String residentListTitle;
  final String residentListDescription;
  final bool canEditSettings;
  final GlobalKey<FormState> formKey;
  final TextEditingController electricityController;
  final TextEditingController waterController;
  final TextEditingController maintenanceController;
  final TextEditingController parkingController;
  final TextEditingController singleController;
  final TextEditingController doubleController;
  final TextEditingController tripleController;
  final List<FeeChargeItem> customCharges;
  final VoidCallback onAddCustomCharge;
  final ValueChanged<int> onEditCustomCharge;
  final ValueChanged<int> onRemoveCustomCharge;
  final Future<void> Function() onSave;
  final Future<void> Function(String userId) onSendReminder;
  final Future<void> Function(String userId) onCollectFee;
  final void Function(PaymentRecord payment) onOpenReceipt;

  @override
  Widget build(BuildContext context) {
    final FeeSettings? settings = state.feeSettings;
    final Brightness brightness = Theme.of(context).brightness;
    final Color primaryTextColor = AppColors.primaryTextFor(brightness);
    final Color mutedTextColor = AppColors.mutedTextFor(brightness);
    if (settings == null) {
      return const AppEmptyState(
        icon: Icons.tune_outlined,
        title: 'Fee settings unavailable',
        message: 'Reload the app to fetch current fee configuration.',
      );
    }

    final List<PaymentRecord> recentPayments =
        state.recentPayments.take(6).toList();

    return ListView(
      padding: appPagePadding(context, horizontal: 14, top: 8, bottomExtra: 18),
      children: <Widget>[
        AppTopInfoCard(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      canEditSettings
                          ? 'Monthly fee control'
                          : 'Resident fee desk',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    heightSpacer(4),
                    Text(
                      canEditSettings
                          ? 'Update rates, monitor dues, and send reminders.'
                          : 'Collect fees, review dues, and issue receipts.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.78),
                          ),
                    ),
                  ],
                ),
              ),
              AppTopInfoStatusChip(
                label: canEditSettings ? 'Admin' : 'Warden',
                accentColor: canEditSettings
                    ? AppColors.kTopInfoAccentColor
                    : AppColors.kGreenColor,
              ),
            ],
          ),
        ),
        heightSpacer(10),
        if (canEditSettings)
          AppSectionCard(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const _SectionTitle(title: 'Rate Settings'),
                  heightSpacer(12),
                  _FeeField(
                    label: 'Electricity',
                    controller: electricityController,
                  ),
                  _FeeField(
                    label: 'Water',
                    controller: waterController,
                  ),
                  _FeeField(
                    label: 'Maintenance',
                    controller: maintenanceController,
                  ),
                  _FeeField(
                    label: 'Parking',
                    controller: parkingController,
                  ),
                  _FeeField(
                    label: 'Single occupancy',
                    controller: singleController,
                  ),
                  _FeeField(
                    label: 'Double sharing',
                    controller: doubleController,
                  ),
                  _FeeField(
                    label: 'Triple sharing',
                    controller: tripleController,
                  ),
                  heightSpacer(4),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Additional categories',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: primaryTextColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: onAddCustomCharge,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  if (customCharges.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Text(
                        'No additional fee categories yet. Add custom charges like Wi-Fi, lab access, or special services.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: mutedTextColor,
                              height: 1.45,
                            ),
                      ),
                    )
                  else
                    ...customCharges.asMap().entries.map(
                          (MapEntry<int, FeeChargeItem> entry) => Container(
                            margin: EdgeInsets.only(bottom: 10.h),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: _softSurfaceColor(context),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: _borderColor(context)),
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        entry.value.label,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: primaryTextColor,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      Text(
                                        'Rs ${_formatAmount(entry.value.amount)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: mutedTextColor),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Edit',
                                  onPressed: () =>
                                      onEditCustomCharge(entry.key),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                IconButton(
                                  tooltip: 'Remove',
                                  onPressed: () =>
                                      onRemoveCustomCharge(entry.key),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                          ),
                        ),
                  heightSpacer(6),
                  CustomButton(
                    buttonText: 'Save Rates',
                    onTap: onSave,
                  ),
                ],
              ),
            ),
          ),
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _SectionTitle(
                title: showOnlyDues ? 'Residents With Dues' : 'Resident Dues',
                trailing: showOnlyDues
                    ? TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed(
                            AppRoutes.fees,
                            arguments: const FeeScreenRouteArgs(
                              filter: FeeScreenFilter.allResidents,
                            ),
                          );
                        },
                        icon: const Icon(Icons.view_list_rounded),
                        label: const Text('View all'),
                      )
                    : null,
              ),
              heightSpacer(12),
              Text(
                residentListTitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: primaryTextColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              heightSpacer(4),
              Text(
                residentListDescription,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: mutedTextColor,
                      height: 1.4,
                    ),
              ),
              heightSpacer(12),
              if (filteredStudents.isEmpty)
                AppEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: showOnlyDues ? 'No fee dues' : 'No residents yet',
                  message: showOnlyDues
                      ? 'Residents with unpaid balances for the current cycle will appear here.'
                      : 'Resident balances will appear here once accounts are assigned.',
                )
              else
                ...filteredStudents.map(
                  (AppUser student) => _AdminResidentFeeTile(
                    student: student,
                    summary: state.feeSummaryFor(student.id),
                    roomLabel: state.findRoom(student.roomId ?? '')?.label,
                    onSendReminder: () => onSendReminder(student.id),
                    onCollectFee: () => onCollectFee(student.id),
                    onOpenChat: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.chat,
                        arguments: ChatRouteArgs(partnerId: student.id),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        if (showOnlyDues)
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _SectionTitle(
                  title: 'Paid This Cycle',
                  trailing: activeFilter == FeeScreenFilter.duesOnly
                      ? TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed(
                              AppRoutes.fees,
                              arguments: const FeeScreenRouteArgs(
                                filter: FeeScreenFilter.allResidents,
                              ),
                            );
                          },
                          icon: const Icon(Icons.people_alt_outlined),
                          label: const Text('All residents'),
                        )
                      : null,
                ),
                heightSpacer(12),
                if (settledStudents.isEmpty)
                  const AppEmptyState(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'No settled residents yet',
                    message:
                        'Residents who have already cleared the current cycle will appear here.',
                  )
                else
                  ...settledStudents.map(
                    (AppUser student) => _AdminResidentFeeTile(
                      student: student,
                      summary: state.feeSummaryFor(student.id),
                      roomLabel: state.findRoom(student.roomId ?? '')?.label,
                      onSendReminder: () {},
                      onCollectFee: () {},
                      onOpenChat: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.chat,
                          arguments: ChatRouteArgs(partnerId: student.id),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _SectionTitle(title: 'Recent Receipts'),
              heightSpacer(12),
              if (recentPayments.isEmpty)
                const AppEmptyState(
                  icon: Icons.receipt_outlined,
                  title: 'No receipts yet',
                  message: 'Completed online payments will appear here.',
                )
              else
                ...recentPayments.map(
                  (PaymentRecord payment) => _AdminPaymentTile(
                    payment: payment,
                    residentName:
                        state.findUser(payment.userId)?.fullName ?? 'Resident',
                    onTap: () => onOpenReceipt(payment),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
