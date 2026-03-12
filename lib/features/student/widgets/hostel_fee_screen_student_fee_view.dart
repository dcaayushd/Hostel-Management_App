part of '../screens/hostel_fee_screen.dart';

class _StudentFeeView extends StatelessWidget {
  const _StudentFeeView({
    required this.state,
    required this.onPay,
    required this.onOpenReceipt,
  });

  final AppState state;
  final Future<void> Function(PaymentMethod method) onPay;
  final void Function(PaymentRecord payment) onOpenReceipt;

  @override
  Widget build(BuildContext context) {
    final FeeSummary? fees = state.currentFeeSummary;
    final Brightness brightness = Theme.of(context).brightness;
    final Color primaryTextColor = AppColors.primaryTextFor(brightness);
    final Color mutedTextColor = AppColors.mutedTextFor(brightness);
    if (fees == null) {
      return const AppEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Fee details unavailable',
        message: 'Fee summaries are available only for student accounts.',
      );
    }

    final List<PaymentRecord> payments = state.currentPaymentHistory;
    final PaymentRecord? latestPayment =
        payments.isEmpty ? null : payments.first;
    final String roomLabel = state.currentRoom?.label ?? 'No room';

    return ListView(
      padding: appPagePadding(context, horizontal: 14, top: 8, bottomExtra: 18),
      children: <Widget>[
        _StudentFeeHero(
          summary: fees,
          roomLabel: roomLabel,
          latestPayment: latestPayment,
          onOpenLatestReceipt:
              latestPayment == null ? null : () => onOpenReceipt(latestPayment),
        ),
        if (!fees.isPaid) ...<Widget>[
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _SectionTitle(
                  title: 'Pay Online',
                  trailing: Text(
                    'Due Rs ${_formatAmount(fees.balance)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: mutedTextColor,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                heightSpacer(12),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final int columns = constraints.maxWidth > 360 ? 3 : 2;
                    final double spacing = 8.w;
                    final double width =
                        (constraints.maxWidth - ((columns - 1) * spacing)) /
                            columns;
                    final List<PaymentMethod> methods = PaymentMethod.values
                        .where((PaymentMethod method) =>
                            method != PaymentMethod.cash)
                        .toList(growable: false);
                    return Wrap(
                      spacing: spacing,
                      runSpacing: 8.h,
                      children: methods
                          .map(
                            (PaymentMethod method) => SizedBox(
                              width: width,
                              child: _PaymentMethodTile(
                                method: method,
                                onTap: () => onPay(method),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _SectionTitle(title: 'Monthly Tracking'),
              heightSpacer(12),
              _ProgressStrip(
                label: 'Paid',
                value: fees.total == 0 ? 1 : fees.paidAmount / fees.total,
                caption:
                    'Rs ${_formatAmount(fees.paidAmount)} of Rs ${_formatAmount(fees.total)}',
              ),
              heightSpacer(14),
              _FeeRow(label: 'Maintenance', value: fees.maintenanceCharge),
              _FeeRow(label: 'Parking', value: fees.parkingCharge),
              _FeeRow(label: 'Water', value: fees.waterCharge),
              _FeeRow(label: 'Room', value: fees.roomCharge),
              ...fees.additionalCharges.map(
                (FeeChargeItem item) => _FeeRow(
                  label: item.label,
                  value: item.amount,
                ),
              ),
              _FeeRow(
                label: 'Paid',
                value: fees.paidAmount,
                valueColor: AppColors.kGreenColor,
              ),
              _FeeRow(
                label: 'Balance',
                value: fees.balance,
                isLast: true,
                valueColor:
                    fees.isPaid ? AppColors.kGreenColor : primaryTextColor,
              ),
            ],
          ),
        ),
        AppSectionCard(
          child: _ReminderCard(summary: fees),
        ),
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _SectionTitle(title: 'Payment History'),
              heightSpacer(12),
              if (payments.isEmpty)
                const AppEmptyState(
                  icon: Icons.payments_outlined,
                  title: 'No payments yet',
                  message: 'Your completed payments and receipts appear here.',
                )
              else
                ...payments.map(
                  (PaymentRecord payment) => _PaymentHistoryTile(
                    payment: payment,
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
