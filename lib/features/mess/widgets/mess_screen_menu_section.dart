part of '../screens/mess_screen.dart';

class _MenuSection extends StatelessWidget {
  const _MenuSection({
    required this.menu,
    required this.highlightedDay,
    this.onEditMenuDay,
  });

  final List<MessMenuDay> menu;
  final MessDay highlightedDay;
  final Future<void> Function(MessMenuDay menuDay)? onEditMenuDay;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final List<MessMenuDay> visibleMenu = onEditMenuDay == null
        ? menu
            .where((MessMenuDay item) => item.isPublished)
            .toList(growable: false)
        : menu;
    return AppSectionCard(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Weekly menu',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryTextFor(brightness),
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              StatusChip(
                label: highlightedDay == _todayDay()
                    ? 'Today'
                    : highlightedDay.label,
                color: const Color(0xFF0F766E),
                emphasized: highlightedDay == _todayDay(),
              ),
            ],
          ),
          heightSpacer(4),
          Text(
            'Breakfast, lunch, and dinner for each day.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedTextFor(brightness),
                ),
          ),
          heightSpacer(12),
          if (visibleMenu.isEmpty)
            const AppEmptyState(
              icon: Icons.restaurant_menu_outlined,
              title: 'Menu unavailable',
              message: 'The weekly mess menu has not been published yet.',
            )
          else
            ...visibleMenu.map(
              (MessMenuDay item) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _MenuDayCard(
                  menuDay: item,
                  highlighted: item.day == highlightedDay,
                  onEdit: onEditMenuDay == null
                      ? null
                      : () {
                          onEditMenuDay!(item);
                        },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
