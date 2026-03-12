part of '../screens/gate_pass_screen.dart';

class _GateMovementSection extends StatelessWidget {
  const _GateMovementSection({
    required this.passes,
    required this.state,
  });

  final List<GatePassRequest> passes;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final List<GatePassRequest> movements = passes
        .where(
          (GatePassRequest item) =>
              item.checkedOutAt != null ||
              item.returnedAt != null ||
              item.reviewedAt != null,
        )
        .toList(growable: false)
      ..sort((GatePassRequest a, GatePassRequest b) {
        return _latestMovementAt(b).compareTo(_latestMovementAt(a));
      });

    return AppSectionCard(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Access log',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryTextFor(brightness),
                  fontWeight: FontWeight.w800,
                ),
          ),
          heightSpacer(4),
          Text(
            'Recent approvals, exits, and returns.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedTextFor(brightness),
                ),
          ),
          heightSpacer(12),
          if (movements.isEmpty)
            const AppEmptyState(
              icon: Icons.history_toggle_off_rounded,
              title: 'No access activity',
              message: 'Desk actions will appear here after processing passes.',
            )
          else
            ...movements.take(6).map(
                  (GatePassRequest item) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: _GateMovementTile(
                      residentName:
                          state.findUser(item.studentId)?.fullName ?? 'Unknown',
                      pass: item,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
