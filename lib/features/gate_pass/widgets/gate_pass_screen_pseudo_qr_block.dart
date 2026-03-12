part of '../screens/gate_pass_screen.dart';

class _PseudoQrBlock extends StatelessWidget {
  const _PseudoQrBlock({
    required this.code,
  });

  final String code;

  @override
  Widget build(BuildContext context) {
    final List<int> values = code.codeUnits;
    return SizedBox(
      width: 76.w,
      height: 76.w,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        itemCount: 36,
        itemBuilder: (BuildContext context, int index) {
          final int value = values[index % values.length];
          final bool active = ((value + index) % 3) != 0;
          return Container(
            decoration: BoxDecoration(
              color: active ? AppColors.kSecondaryColor : Colors.white,
              borderRadius: BorderRadius.circular(2.r),
            ),
          );
        },
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

Color _statusColor(GatePassRequest pass) {
  if (pass.isLateNow) {
    return const Color(0xFFD92D20);
  }
  switch (pass.status) {
    case GatePassStatus.pending:
      return const Color(0xFFB54708);
    case GatePassStatus.approved:
      return const Color(0xFF2B6CB0);
    case GatePassStatus.rejected:
      return const Color(0xFFD92D20);
    case GatePassStatus.checkedOut:
      return const Color(0xFFB54708);
    case GatePassStatus.returned:
      return AppColors.kGreenColor;
    case GatePassStatus.late:
      return const Color(0xFFD92D20);
  }
}

DateTime _latestMovementAt(GatePassRequest pass) {
  return pass.returnedAt ??
      pass.checkedOutAt ??
      pass.reviewedAt ??
      pass.createdAt;
}

String _formatDateTime(DateTime date) {
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
  final int hourValue = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final String hour = hourValue.toString().padLeft(2, '0');
  final String minute = date.minute.toString().padLeft(2, '0');
  final String meridiem = date.hour >= 12 ? 'PM' : 'AM';
  return '$day ${months[date.month - 1]} ${date.year} • $hour:$minute $meridiem';
}

final GatePassRequest _emptyGatePass = GatePassRequest(
  id: '',
  studentId: '',
  destination: '',
  reason: '',
  emergencyContact: '',
  passCode: '',
  status: GatePassStatus.pending,
  departureAt: DateTime(2000),
  expectedReturnAt: DateTime(2000),
  createdAt: DateTime(2000),
);
