part of '../screens/parcel_desk_screen.dart';

class _StudentDropdown extends StatelessWidget {
  const _StudentDropdown({
    required this.students,
    required this.selectedStudentId,
    required this.onChanged,
    required this.label,
  });

  final List<AppUser> students;
  final String? selectedStudentId;
  final ValueChanged<String?> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppDropdownField<String>(
      initialValue: students.any((AppUser user) => user.id == selectedStudentId)
          ? selectedStudentId
          : null,
      labelText: label,
      items: students
          .map(
            (AppUser user) => DropdownMenuItem<String>(
              value: user.id,
              child: Text(user.fullName),
            ),
          )
          .toList(growable: false),
      onChanged: students.isEmpty ? null : onChanged,
    );
  }
}
