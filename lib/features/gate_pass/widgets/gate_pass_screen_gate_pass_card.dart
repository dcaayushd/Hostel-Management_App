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
    final bool isActivePass =
        pass.canCheckOut || pass.canMarkReturned || pass.isLateNow;
    final bool isTodayPass =
        DateUtils.isSameDay(pass.departureAt, DateTime.now()) ||
            DateUtils.isSameDay(pass.expectedReturnAt, DateTime.now());
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: isActivePass
            ? AppColors.activeSurfaceFor(
                brightness,
                color: accent,
                lightAlpha: 0.08,
                darkAlpha: 0.14,
              )
            : AppColors.tonalSurfaceFor(brightness),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isActivePass
              ? AppColors.activeBorderFor(brightness, color: accent)
              : AppColors.outlineFor(brightness),
        ),
        boxShadow: isActivePass
            ? <BoxShadow>[
                AppColors.activeShadow(
                  brightness,
                  color: accent,
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
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
                emphasized: isActivePass,
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
          if (isActivePass || isTodayPass) ...<Widget>[
            heightSpacer(8),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: <Widget>[
                if (pass.canMarkReturned || pass.isLateNow)
                  StatusChip(
                    label: 'Currently out',
                    color: pass.isLateNow
                        ? AppColors.kWarningColor
                        : AppColors.kGreenColor,
                    emphasized: true,
                  )
                else if (pass.canCheckOut)
                  const StatusChip(
                    label: 'Ready now',
                    color: AppColors.kGreenColor,
                    emphasized: true,
                  ),
                if (isTodayPass)
                  const StatusChip(
                    label: 'Today',
                    color: AppColors.kGreenColor,
                    emphasized: true,
                  ),
              ],
            ),
          ],
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
                  color: AppColors.kDangerStrongColor,
                  onTap: onReject!,
                ),
              if (onCheckOut != null)
                _InlineAction(
                  label: 'Check out',
                  color: AppColors.kWarningColor,
                  onTap: onCheckOut!,
                ),
              if (onReturn != null)
                _InlineAction(
                  label: 'Mark returned',
                  color: AppColors.kGreenColor,
                  onTap: onReturn!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
