part of '../screens/mess_screen.dart';

class _AdminMessHero extends StatelessWidget {
  const _AdminMessHero({
    required this.studentsCount,
    required this.mealsToday,
    required this.residentsToday,
    required this.averageRating,
  });

  final int studentsCount;
  final int mealsToday;
  final int residentsToday;
  final double averageRating;

  @override
  Widget build(BuildContext context) {
    return AppTopInfoCard(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Mess operations',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          heightSpacer(4),
          Text(
            'Track menu, attendance, bills, and meal feedback in one place.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                ),
          ),
          heightSpacer(12),
          Row(
            children: <Widget>[
              Expanded(
                child: _CompactStatCard(
                  label: 'Residents',
                  value: studentsCount.toString(),
                  icon: Icons.groups_2_outlined,
                  color: AppColors.kGreenColor,
                ),
              ),
              widthSpacer(8),
              Expanded(
                child: _CompactStatCard(
                  label: 'Meals today',
                  value: mealsToday.toString(),
                  icon: Icons.restaurant_menu_outlined,
                  color: const Color(0xFF0F766E),
                ),
              ),
            ],
          ),
          heightSpacer(8),
          Row(
            children: <Widget>[
              Expanded(
                child: _CompactStatCard(
                  label: 'Residents served',
                  value: residentsToday.toString(),
                  icon: Icons.how_to_reg_outlined,
                  color: const Color(0xFF3B755E),
                ),
              ),
              widthSpacer(8),
              Expanded(
                child: _CompactStatCard(
                  label: 'Avg rating',
                  value: averageRating == 0
                      ? '--'
                      : averageRating.toStringAsFixed(1),
                  icon: Icons.star_rate_rounded,
                  color: const Color(0xFFB54708),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
