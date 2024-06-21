import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hostel_management_app/common/app_bar.dart';
import 'package:hostel_management_app/common/custom_text_field.dart';
import 'package:hostel_management_app/common/spacing.dart';
import 'package:hostel_management_app/features/auth/widgets/custom_button.dart';
import 'package:hostel_management_app/theme/text_theme.dart';

class StudentCreateIssueScreen extends StatefulWidget {
  const StudentCreateIssueScreen({super.key});

  @override
  State<StudentCreateIssueScreen> createState() =>
      _StudentCreateIssueScreenState();
}

class _StudentCreateIssueScreenState extends State<StudentCreateIssueScreen> {
  TextEditingController studentComment = TextEditingController();
  String? selectedISsue;

  List<String> issues = [
    'Bathroom',
    'Bedroom',
    'Electricity',
    'Furniture',
    'Mesh Food',
    'Water',
  ];

  @override
  void dispose() {
    studentComment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, 'Create Issue'),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 15.w,
            vertical: 10.h,
          ),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heightSpacer(15),
                Text(
                  'Room Number',
                  style: AppTextTheme.kLabelStyle,
                ),
                heightSpacer(15),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  width: double.maxFinite,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xff2e8b57),
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      '413',
                      style: TextStyle(
                        fontSize: 17.sp,
                      ),
                    ),
                  ),
                ),
                heightSpacer(15),
                Text(
                  'Block Number',
                  style: AppTextTheme.kLabelStyle,
                ),
                heightSpacer(15),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  width: double.maxFinite,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xff2e8b57),
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      'B',
                      style: TextStyle(
                        fontSize: 17.sp,
                      ),
                    ),
                  ),
                ),
                heightSpacer(15),
                Text(
                  'Email Id',
                  style: AppTextTheme.kLabelStyle,
                ),
                heightSpacer(15),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  width: double.maxFinite,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xff2e8b57),
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      'dcaayushd@gmail.com',
                      style: TextStyle(
                        fontSize: 17.sp,
                      ),
                    ),
                  ),
                ),
                heightSpacer(15),
                Text(
                  'Phone Number',
                  style: AppTextTheme.kLabelStyle,
                ),
                heightSpacer(15),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  width: double.maxFinite,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xff2e8b57),
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      '9876543210',
                      style: TextStyle(
                        fontSize: 17.sp,
                      ),
                    ),
                  ),
                ),
                heightSpacer(15),
                Text(
                  'Issue you\'re facing',
                  style: AppTextTheme.kLabelStyle,
                ),
                heightSpacer(15),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  width: double.maxFinite,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xff2e8b57),
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: DropdownButton<String>(
                      underline: const SizedBox(),
                      isExpanded: true,
                      value: selectedISsue,
                      onChanged: (String? newValue) {
                        setState(
                          () {
                            selectedISsue = newValue;
                          },
                        );
                      },
                      items: issues.map((String issue) {
                        return DropdownMenuItem<String>(
                          value: issue,
                          child: Text(issue),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                heightSpacer(15),
                Text(
                  'Comments',
                  style: AppTextTheme.kLabelStyle,
                ),
                heightSpacer(15),
                CustomTextField(
                  controller: studentComment,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Comment is required';
                    } else {
                      return null;
                    }
                  },
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xffd1d8ff),
                    ),
                  ),
                ),
                heightSpacer(40),
                CustomButton(
                  buttonText: 'Submit',
                  onTap: () {},
                ),
                heightSpacer(10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
