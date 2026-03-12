part of '../screens/mess_screen.dart';

class _StudentMessHero extends StatelessWidget {
  const _StudentMessHero({
    required this.summary,
  });

  final MessBillSummary? summary;

  @override
  Widget build(BuildContext context) {
    final int totalAmount = summary?.totalAmount ?? 0;
    final int mealCount = summary?.mealCount ?? 0;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF2E8B57), Color(0xFF173C32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14173C32),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            summary?.monthLabel ?? 'Current month',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.84),
                  fontWeight: FontWeight.w700,
                ),
          ),
          heightSpacer(6),
          Text(
            'Mess bill',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          heightSpacer(12),
          Row(
            children: <Widget>[
              Expanded(
                child: _HeroStat(
                  label: 'Total',
                  value: 'Rs ${_formatAmount(totalAmount)}',
                ),
              ),
              widthSpacer(8),
              Expanded(
                child: _HeroStat(
                  label: 'Meals',
                  value: mealCount.toString(),
                ),
              ),
            ],
          ),
          if (summary != null) ...<Widget>[
            heightSpacer(10),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: <Widget>[
                _HeroPill(
                  label: 'B ${summary!.breakfastCount}',
                ),
                _HeroPill(
                  label: 'L ${summary!.lunchCount}',
                ),
                _HeroPill(
                  label: 'D ${summary!.dinnerCount}',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
