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

    return Column(
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
            StatusChip(label: booking.status.label, color: color),
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
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.kGreenColor,
                      side: const BorderSide(color: AppColors.kGreenColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: const Text('Complete'),
                  ),
                ),
              if (onComplete != null && onCancel != null) widthSpacer(8),
              if (onCancel != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB54708),
                      side: const BorderSide(color: Color(0xFFB54708)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  static Color _statusColor(LaundryBookingStatus status) {
    switch (status) {
      case LaundryBookingStatus.scheduled:
        return const Color(0xFF2B6CB0);
      case LaundryBookingStatus.completed:
        return AppColors.kGreenColor;
      case LaundryBookingStatus.cancelled:
        return const Color(0xFFB54708);
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
