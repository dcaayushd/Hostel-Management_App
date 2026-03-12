part of '../screens/mess_screen.dart';

class _MessBillSection extends StatelessWidget {
  const _MessBillSection({
    required this.state,
  });

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final List<_StudentBillRow> rows = state.students
        .map(
          (AppUser student) {
            final MessBillSummary? bill = state.messBillFor(student.id);
            if (bill == null) {
              return null;
            }
            return _StudentBillRow(
              name: student.fullName,
              meals: bill.mealCount,
              total: bill.totalAmount,
            );
          },
        )
        .whereType<_StudentBillRow>()
        .toList(growable: false)
      ..sort(
        (_StudentBillRow a, _StudentBillRow b) => b.total.compareTo(a.total),
      );

    return AppSectionCard(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Mess bills',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.kSecondaryColor,
                  fontWeight: FontWeight.w800,
                ),
          ),
          heightSpacer(4),
          Text(
            'Current month meal totals by resident.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.kMutedTextColor,
                ),
          ),
          heightSpacer(12),
          if (rows.isEmpty)
            const AppEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No mess bills yet',
              message: 'Bills will update as attendance gets logged.',
            )
          else
            ...rows.map(
              (_StudentBillRow row) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FCFA),
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(color: AppColors.kBorderColor),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              row.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.kSecondaryColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            heightSpacer(3),
                            Text(
                              '${row.meals} meals',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.kMutedTextColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Rs ${_formatAmount(row.total)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.kGreenColor,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
