part of '../screens/room_availability_screen.dart';

class _RoomInventoryCard extends StatelessWidget {
  const _RoomInventoryCard({
    required this.room,
    this.highlighted = false,
  });

  final HostelRoom room;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final Brightness brightness = Theme.of(context).brightness;
    final Color primaryTextColor = AppColors.primaryTextFor(brightness);
    final Color mutedTextColor = AppColors.mutedTextFor(brightness);
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: highlighted
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.kGreenColor.withValues(
                    alpha: brightness == Brightness.dark ? 0.22 : 0.14,
                  ),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
              ],
            )
          : null,
      child: AppSectionCard(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 48.h,
                  width: 48.w,
                  decoration: BoxDecoration(
                    color: AppColors.iconSurfaceFor(
                      brightness,
                      lightColor: AppColors.kGreenColor,
                      lightAlpha: 0.10,
                      darkAlpha: 0.14,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.meeting_room_outlined,
                    color: AppColors.iconColorFor(brightness),
                  ),
                ),
                widthSpacer(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        room.label,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: primaryTextColor,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      heightSpacer(4),
                      Text(
                        room.roomType,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: mutedTextColor,
                            ),
                      ),
                    ],
                  ),
                ),
                if (state.currentRoom?.id == room.id)
                  const StatusChip(
                    label: 'Current room',
                    color: AppColors.kGreenColor,
                    emphasized: true,
                  )
                else if (highlighted)
                  const StatusChip(
                    label: 'Search match',
                    color: AppColors.kGreenColor,
                    emphasized: true,
                  )
                else
                  StatusChip(
                    label: room.hasAvailability ? 'Available' : 'Full',
                    color: room.hasAvailability
                        ? AppColors.kGreenColor
                        : const Color(0xFFB42318),
                    emphasized: room.hasAvailability,
                  ),
              ],
            ),
            heightSpacer(12),
            LinearProgressIndicator(
              value: room.occupiedBeds / room.capacity,
              minHeight: 10.h,
              borderRadius: BorderRadius.circular(999.r),
              valueColor: AlwaysStoppedAnimation<Color>(
                room.hasAvailability
                    ? AppColors.kGreenColor
                    : const Color(0xFFB42318),
              ),
              backgroundColor: brightness == Brightness.dark
                  ? const Color(0xFF233B31)
                  : AppColors.softSurfaceFor(brightness),
            ),
            heightSpacer(12),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: <Widget>[
                AppMetaChip(
                  icon: Icons.apartment_outlined,
                  label: 'Block ${room.block}',
                ),
                AppMetaChip(
                  icon: Icons.people_outline,
                  label: '${room.occupiedBeds}/${room.capacity} occupied',
                ),
                AppMetaChip(
                  icon: Icons.bed_outlined,
                  label: '${room.availableBeds} bed(s) open',
                  highlighted: room.availableBeds > 0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
