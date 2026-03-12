part of '../screens/parcel_desk_screen.dart';

class _VisitorFormSection extends StatelessWidget {
  const _VisitorFormSection({
    required this.formKey,
    required this.students,
    required this.selectedStudentId,
    required this.onStudentChanged,
    required this.visitorNameController,
    required this.relationController,
    required this.noteController,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final List<AppUser> students;
  final String? selectedStudentId;
  final ValueChanged<String?> onStudentChanged;
  final TextEditingController visitorNameController;
  final TextEditingController relationController;
  final TextEditingController noteController;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return AppSectionCard(
      padding: EdgeInsets.all(12.w),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Add visitor',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryTextFor(brightness),
                    fontWeight: FontWeight.w800,
                  ),
            ),
            heightSpacer(10),
            _StudentDropdown(
              students: students,
              selectedStudentId: selectedStudentId,
              onChanged: onStudentChanged,
              label: 'Resident',
            ),
            CustomTextField(
              controller: visitorNameController,
              inputHint: 'Visitor name',
              validator: _requiredField,
            ),
            CustomTextField(
              controller: relationController,
              inputHint: 'Relation',
              validator: _requiredField,
            ),
            CustomTextField(
              controller: noteController,
              inputHint: 'Visit note',
              validator: _requiredField,
            ),
            heightSpacer(6),
            CustomButton(
              buttonText: 'Log Visitor',
              onTap: students.isEmpty ? null : onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
