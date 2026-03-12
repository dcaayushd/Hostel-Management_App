part of '../screens/gate_pass_screen.dart';

class _GatePassCard extends StatelessWidget {
  const _GatePassCard({
    required this.pass,
    this.residentName,
    this.onApprove,
    this.onReject,
    this.onCheckOut,
    this.onReturn,
  });

  final GatePassRequest pass;
  final String? residentName;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onCheckOut;
  final VoidCallback? onReturn;

  @override
  Widget build(BuildContext context) {
    final Color accent = _statusColor(pass);
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
                  pass.destination,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryTextFor(brightness),
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              StatusChip(
                label: pass.isLateNow ? 'Late' : pass.status.label,
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
            pass.reason,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedTextFor(brightness),
                  height: 1.45,
                ),
          ),
          heightSpacer(8),
          Text(
            'Code ${pass.passCode} • ${_formatDateTime(pass.departureAt)}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.mutedTextFor(brightness),
                  fontWeight: FontWeight.w700,
                ),
          ),
          Text(
            'Return by ${_formatDateTime(pass.expectedReturnAt)}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.mutedTextFor(brightness),
                ),
          ),
          heightSpacer(8),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: <Widget>[
              if (onApprove != null)
                _InlineAction(
                  label: 'Approve',
                  color: AppColors.kGreenColor,
                  onTap: onApprove!,
                ),
              if (onReject != null)
                _InlineAction(
                  label: 'Reject',
                  color: const Color(0xFFD92D20),
                  onTap: onReject!,
                ),
              if (onCheckOut != null)
                _InlineAction(
                  label: 'Check out',
                  color: const Color(0xFFB54708),
                  onTap: onCheckOut!,
                ),
              if (onReturn != null)
                _InlineAction(
                  label: 'Mark returned',
                  color: const Color(0xFF2B6CB0),
                  onTap: onReturn!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
