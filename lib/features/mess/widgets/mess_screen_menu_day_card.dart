part of '../screens/mess_screen.dart';

class _MenuDayCard extends StatelessWidget {
  const _MenuDayCard({
    required this.menuDay,
    required this.highlighted,
    this.onEdit,
  });

  final MessMenuDay menuDay;
  final bool highlighted;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.activeSurfaceFor(
                brightness,
                color: AppColors.kGreenColor,
                lightAlpha: 0.10,
                darkAlpha: 0.18,
              )
            : AppColors.tonalSurfaceFor(brightness),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: highlighted
              ? AppColors.activeBorderFor(
                  brightness,
                  color: AppColors.kGreenColor,
                )
              : AppColors.outlineFor(brightness),
        ),
        boxShadow: highlighted
            ? <BoxShadow>[
                AppColors.activeShadow(
                  brightness,
                  color: AppColors.kGreenColor,
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  menuDay.day.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryTextFor(brightness),
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              if (highlighted)
                const StatusChip(
                  label: 'Today',
                  color: AppColors.kGreenColor,
                  emphasized: true,
                ),
              if (onEdit != null) ...<Widget>[
                if (highlighted) widthSpacer(6),
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding: EdgeInsets.all(7.w),
                    decoration: BoxDecoration(
                      color: AppColors.kGreenColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      color: AppColors.kGreenColor,
                      size: 16.sp,
                    ),
                  ),
                ),
              ],
            ],
          ),
          heightSpacer(10),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: <Widget>[
              _MenuItemPill(
                label: 'Breakfast',
                value: menuDay.breakfast,
                icon: Icons.free_breakfast_outlined,
              ),
              _MenuItemPill(
                label: 'Lunch',
                value: menuDay.lunch,
                icon: Icons.lunch_dining_outlined,
              ),
              _MenuItemPill(
                label: 'Dinner',
                value: menuDay.dinner,
                icon: Icons.dinner_dining_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
