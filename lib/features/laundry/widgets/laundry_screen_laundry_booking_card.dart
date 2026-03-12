part of '../screens/laundry_screen.dart';

class _LaundryBookingCard extends StatelessWidget {
  const _LaundryBookingCard({
    required this.booking,
    required this.resident,
    required this.canManage,
    this.onComplete,
    this.onCancel,
  });

  final LaundryBooking booking;
  final AppUser? resident;
  final bool canManage;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final Color color = _statusColor(booking.status);
    final Brightness brightness = Theme.of(context).brightness;
    final bool isToday =
        DateUtils.isSameDay(booking.scheduledAt, DateTime.now());
    final bool highlighted = booking.isActive || isToday;

    return Container(
      padding: highlighted ? EdgeInsets.all(12.w) : null,
      decoration: highlighted
          ? BoxDecoration(
              color: booking.isActive
                  ? AppColors.activeSurfaceFor(
                      brightness,
                      color: color,
                      lightAlpha: 0.08,
                      darkAlpha: 0.14,
                    )
                  : AppColors.tonalSurfaceFor(brightness),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: booking.isActive
                    ? AppColors.activeBorderFor(brightness, color: color)
                    : AppColors.outlineFor(brightness),
              ),
              boxShadow: booking.isActive
                  ? <BoxShadow>[
                      AppColors.activeShadow(
                        brightness,
                        color: color,
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${booking.machineLabel}  ${booking.slotLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primaryTextFor(brightness),
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              StatusChip(
                label: booking.status.label,
                color: color,
                emphasized: booking.isActive,
              ),
            ],
          ),
          if (canManage && resident != null) ...<Widget>[
            heightSpacer(8),
            Text(
              '${resident!.firstName} ${resident!.lastName}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryTextFor(brightness),
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
          heightSpacer(8),
          Text(
            '${_formatBookingDate(booking.scheduledAt)}  •  ${booking.notes}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedTextFor(brightness),
                  height: 1.45,
                ),
          ),
          heightSpacer(8),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: <Widget>[
              if (booking.isActive)
                const StatusChip(
                  label: 'Running now',
                  color: AppColors.kGreenColor,
                  emphasized: true,
                ),
              if (isToday)
                const StatusChip(
                  label: 'Today',
                  color: AppColors.kGreenColor,
                  emphasized: true,
                ),
            ],
          ),
          if (booking.completedAt != null) ...<Widget>[
            heightSpacer(6),
            Text(
              'Closed ${_formatBookingDate(booking.completedAt!)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedTextFor(brightness),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
          if (onComplete != null || onCancel != null) ...<Widget>[
            heightSpacer(12),
            Row(
              children: <Widget>[
                if (onComplete != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onComplete,
                      style: AppButtonStyles.outlined(
                        Theme.of(context).brightness,
                        color: AppColors.kGreenColor,
                      ),
                      child: const Text('Complete'),
                    ),
                  ),
                if (onComplete != null && onCancel != null) widthSpacer(8),
                if (onCancel != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: AppButtonStyles.outlined(
                        Theme.of(context).brightness,
                        color: AppColors.kWarningColor,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static Color _statusColor(LaundryBookingStatus status) {
    switch (status) {
      case LaundryBookingStatus.scheduled:
        return AppColors.kGreenColor;
      case LaundryBookingStatus.completed:
        return AppColors.kGreenColor;
      case LaundryBookingStatus.cancelled:
        return AppColors.kWarningColor;
    }
  }

  static String _formatBookingDate(DateTime value) {
    final String day = value.day.toString().padLeft(2, '0');
    final String month = value.month.toString().padLeft(2, '0');
    final String hour = value.hour.toString().padLeft(2, '0');
    final String minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} $hour:$minute';
  }
}
