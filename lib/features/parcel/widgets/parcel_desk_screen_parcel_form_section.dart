part of '../screens/parcel_desk_screen.dart';

class _ParcelFormSection extends StatelessWidget {
  const _ParcelFormSection({
    required this.formKey,
    required this.students,
    required this.carrierOptions,
    required this.selectedStudentId,
    required this.onStudentChanged,
    required this.carrierController,
    required this.trackingController,
    required this.noteController,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final List<AppUser> students;
  final List<String> carrierOptions;
  final String? selectedStudentId;
  final ValueChanged<String?> onStudentChanged;
  final TextEditingController carrierController;
  final TextEditingController trackingController;
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
              'Add parcel',
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
              controller: carrierController,
              inputHint: 'Carrier',
              validator: _requiredField,
            ),
            if (carrierOptions.isNotEmpty) ...<Widget>[
              heightSpacer(8),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: carrierOptions
                    .map(
                      (String carrier) => ActionChip(
                        label: Text(carrier),
                        onPressed: () {
                          carrierController.text = carrier;
                        },
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
            CustomTextField(
              controller: trackingController,
              inputHint: 'Tracking code',
              validator: _requiredField,
            ),
            CustomTextField(
              controller: noteController,
              inputHint: 'Parcel note',
              validator: _requiredField,
            ),
            heightSpacer(6),
            CustomButton(
              buttonText: 'Record Parcel',
              onTap: students.isEmpty ? null : onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
