part of '../screens/parcel_desk_screen.dart';

class _ParcelListSection extends StatelessWidget {
  const _ParcelListSection({
    required this.title,
    required this.parcels,
    required this.state,
    this.onCollect,
    this.showResident = false,
  });

  final String title;
  final List<ParcelItem> parcels;
  final AppState state;
  final Future<void> Function(String parcelId)? onCollect;
  final bool showResident;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return AppSectionCard(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryTextFor(brightness),
                  fontWeight: FontWeight.w800,
                ),
          ),
          heightSpacer(4),
          Text(
            'Incoming parcels and pickup status.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedTextFor(brightness),
                ),
          ),
          heightSpacer(12),
          if (parcels.isEmpty)
            const AppEmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No parcels',
              message: 'Parcel records will appear here once they are logged.',
            )
          else
            ...parcels.map(
              (ParcelItem parcel) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _ParcelCard(
                  parcel: parcel,
                  residentName: showResident
                      ? state.findUser(parcel.userId)?.fullName
                      : null,
                  onCollect: onCollect == null || !parcel.status.isPending
                      ? null
                      : () => onCollect!(parcel.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
