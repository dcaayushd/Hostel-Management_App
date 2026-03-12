part of '../screens/gate_pass_screen.dart';

class _GatePassListSection extends StatelessWidget {
  const _GatePassListSection({
    required this.title,
    required this.description,
    required this.passes,
    required this.state,
    this.showResident = false,
    this.onApprove,
    this.onReject,
    this.onCheckOut,
    this.onReturn,
  });

  final String title;
  final String description;
  final List<GatePassRequest> passes;
  final AppState state;
  final bool showResident;
  final ValueChanged<String>? onApprove;
  final ValueChanged<String>? onReject;
  final ValueChanged<String>? onCheckOut;
  final ValueChanged<String>? onReturn;

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
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedTextFor(brightness),
                ),
          ),
          heightSpacer(12),
          if (passes.isEmpty)
            const AppEmptyState(
              icon: Icons.qr_code_2_outlined,
              title: 'No gate passes',
              message:
                  'Gate pass requests will appear here once a resident submits one.',
            )
          else
            ...passes.map(
              (GatePassRequest item) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _GatePassCard(
                  pass: item,
                  residentName: showResident
                      ? state.findUser(item.studentId)?.fullName
                      : null,
                  onApprove: onApprove == null || !item.status.isPending
                      ? null
                      : () => onApprove!(item.id),
                  onReject: onReject == null || !item.status.isPending
                      ? null
                      : () => onReject!(item.id),
                  onCheckOut: onCheckOut == null || !item.canCheckOut
                      ? null
                      : () => onCheckOut!(item.id),
                  onReturn: onReturn == null ||
                          !item.canMarkReturned && !item.isLateNow
                      ? null
                      : () => onReturn!(item.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
