part of '../screens/parcel_desk_screen.dart';

class _VisitorListSection extends StatelessWidget {
  const _VisitorListSection({
    required this.title,
    required this.entries,
    required this.state,
    this.onCheckOut,
    this.showResident = false,
  });

  final String title;
  final List<VisitorEntry> entries;
  final AppState state;
  final Future<void> Function(String visitorId)? onCheckOut;
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
            'Resident visitor entries and check-out status.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedTextFor(brightness),
                ),
          ),
          heightSpacer(12),
          if (entries.isEmpty)
            const AppEmptyState(
              icon: Icons.group_outlined,
              title: 'No visitors',
              message:
                  'Visitor entries will appear here once visits are logged.',
            )
          else
            ...entries.map(
              (VisitorEntry entry) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _VisitorCard(
                  entry: entry,
                  residentName: showResident
                      ? state.findUser(entry.studentId)?.fullName
                      : null,
                  onCheckOut: onCheckOut == null || !entry.isActive
                      ? null
                      : () => onCheckOut!(entry.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
