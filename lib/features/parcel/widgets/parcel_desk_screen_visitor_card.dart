part of '../screens/parcel_desk_screen.dart';

class _VisitorCard extends StatelessWidget {
  const _VisitorCard({
    required this.entry,
    this.residentName,
    this.onCheckOut,
  });

  final VisitorEntry entry;
  final String? residentName;
  final VoidCallback? onCheckOut;

  @override
  Widget build(BuildContext context) {
    final Color accent =
        entry.isActive ? const Color(0xFFB54708) : AppColors.kGreenColor;
    final Brightness brightness = Theme.of(context).brightness;
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.tonalSurfaceFor(brightness),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.outlineFor(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${entry.visitorName} • ${entry.relation}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryTextFor(brightness),
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              StatusChip(
                label: entry.isActive ? 'Inside' : 'Checked out',
                color: accent,
              ),
            ],
          ),
          if (residentName != null) ...<Widget>[
            heightSpacer(6),
            Text(
              residentName!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedTextFor(brightness),
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
          heightSpacer(6),
          Text(
            entry.note,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedTextFor(brightness),
                  height: 1.45,
                ),
          ),
          heightSpacer(8),
          Text(
            entry.isActive
                ? 'Checked in ${_formatDateTime(entry.checkedInAt)}'
                : 'Checked out ${_formatDateTime(entry.checkedOutAt!)}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.mutedTextFor(brightness),
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (onCheckOut != null) ...<Widget>[
            heightSpacer(8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onCheckOut,
                child: const Text('Check out'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String? _requiredField(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Required';
  }
  return null;
}

String _formatDate(DateTime date) {
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final String day = date.day.toString().padLeft(2, '0');
  return '$day ${months[date.month - 1]} ${date.year}';
}

String _formatDateTime(DateTime date) {
  final String hour =
      (date.hour % 12 == 0 ? 12 : date.hour % 12).toString().padLeft(2, '0');
  final String minute = date.minute.toString().padLeft(2, '0');
  final String meridiem = date.hour >= 12 ? 'PM' : 'AM';
  return '${_formatDate(date)} • $hour:$minute $meridiem';
}
