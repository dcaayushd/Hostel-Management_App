part of '../screens/parcel_desk_screen.dart';

class _ParcelCard extends StatelessWidget {
  const _ParcelCard({
    required this.parcel,
    this.residentName,
    this.onCollect,
  });

  final ParcelItem parcel;
  final String? residentName;
  final VoidCallback? onCollect;

  @override
  Widget build(BuildContext context) {
    final Color accent = parcel.status.isPending
        ? const Color(0xFF2B6CB0)
        : AppColors.kGreenColor;
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
                  '${parcel.carrier} • ${parcel.trackingCode}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryTextFor(brightness),
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              StatusChip(
                label: parcel.status.label,
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
            parcel.note,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedTextFor(brightness),
                  height: 1.45,
                ),
          ),
          heightSpacer(8),
          Wrap(
            spacing: 10.w,
            runSpacing: 6.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(
                'Arrived ${_formatDate(parcel.createdAt)}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.mutedTextFor(brightness),
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (parcel.notifiedAt != null)
                Text(
                  'Resident notified',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF2B6CB0),
                        fontWeight: FontWeight.w700,
                      ),
                ),
            ],
          ),
          if (onCollect != null) ...<Widget>[
            heightSpacer(8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onCollect,
                child: const Text('Mark collected'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
