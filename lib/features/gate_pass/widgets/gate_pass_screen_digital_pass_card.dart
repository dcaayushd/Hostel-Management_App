part of '../screens/gate_pass_screen.dart';

class _DigitalPassCard extends StatelessWidget {
  const _DigitalPassCard({
    required this.pass,
  });

  final GatePassRequest pass;

  @override
  Widget build(BuildContext context) {
    final Color accent = _statusColor(pass);
    final Brightness brightness = Theme.of(context).brightness;
    return AppSectionCard(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Digital pass',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
          heightSpacer(10),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.tonalSurfaceFor(brightness),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: AppColors.outlineFor(brightness)),
            ),
            child: Row(
              children: <Widget>[
                _PseudoQrBlock(code: pass.passCode),
                widthSpacer(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        pass.passCode,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.primaryTextFor(brightness),
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      heightSpacer(4),
                      Text(
                        pass.destination,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.mutedTextFor(brightness),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      heightSpacer(4),
                      Text(
                        'Emergency: ${pass.emergencyContact}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.mutedTextFor(brightness),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          heightSpacer(10),
          Text(
            'Departure ${_formatDateTime(pass.departureAt)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedTextFor(brightness),
                ),
          ),
          Text(
            'Return ${_formatDateTime(pass.expectedReturnAt)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedTextFor(brightness),
                ),
          ),
        ],
      ),
    );
  }
}
