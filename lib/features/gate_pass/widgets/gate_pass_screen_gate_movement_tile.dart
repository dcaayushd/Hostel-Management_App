part of '../screens/gate_pass_screen.dart';

class _GateMovementTile extends StatelessWidget {
  const _GateMovementTile({
    required this.residentName,
    required this.pass,
  });

  final String residentName;
  final GatePassRequest pass;

  @override
  Widget build(BuildContext context) {
    final DateTime latestAt = _latestMovementAt(pass);
    final Brightness brightness = Theme.of(context).brightness;
    final String label = pass.returnedAt != null
        ? 'Return recorded'
        : pass.checkedOutAt != null
            ? 'Exit recorded'
            : 'Reviewed';

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.tonalSurfaceFor(brightness),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.outlineFor(brightness)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 34.h,
            width: 34.w,
            decoration: BoxDecoration(
              color: _statusColor(pass).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              pass.returnedAt != null
                  ? Icons.login_rounded
                  : pass.checkedOutAt != null
                      ? Icons.logout_rounded
                      : Icons.verified_outlined,
              color: _statusColor(pass),
              size: 18.sp,
            ),
          ),
          widthSpacer(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  residentName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryTextFor(brightness),
                        fontWeight: FontWeight.w800,
                      ),
                ),
                heightSpacer(2),
                Text(
                  '$label • ${pass.destination}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedTextFor(brightness),
                      ),
                ),
              ],
            ),
          ),
          Text(
            _formatDateTime(latestAt),
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.mutedTextFor(brightness),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
