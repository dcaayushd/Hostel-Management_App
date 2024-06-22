import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../common/app_bar.dart';

import '../../../common/custom_text_field.dart';
import '../../../common/spacing.dart';
import '../../../theme/text_theme.dart';
import '../../auth/widgets/custom_button.dart';

class CreateStaffScreen extends StatefulWidget {
  const CreateStaffScreen({super.key});

  @override
  State<CreateStaffScreen> createState() => _CreateStaffScreenState();
}

class _CreateStaffScreenState extends State<CreateStaffScreen> {
  static final _formKey = GlobalKey<FormState>();

  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController jobRole = TextEditingController();

  @override
  void dispose() {
    username.dispose();
    email.dispose();
    password.dispose();
    firstName.dispose();
    lastName.dispose();
    phoneNumber.dispose();
    jobRole.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, 'Create Staff'),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 15.w,
            vertical: 10.h,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heightSpacer(15),
                Text(
                  'Username',
                  style: AppTextTheme.kLabelStyle,
                ),
                CustomTextField(
                  controller: username,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFd1d8ff),
                    ),
                  ),
                  inputHint: 'Enter your username',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Username is required';
                    } else {
                      return null;
                    }
                  },
                ),
                heightSpacer(15),
                Text(
                  'First Name',
                  style: AppTextTheme.kLabelStyle,
                ),
                CustomTextField(
                  controller: firstName,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFd1d8ff),
                    ),
                  ),
                  inputHint: 'Enter your first name',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'First Name is required';
                    } else {
                      return null;
                    }
                  },
                ),
                heightSpacer(15),
                Text(
                  'Last Name',
                  style: AppTextTheme.kLabelStyle,
                ),
                CustomTextField(
                  controller: lastName,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFd1d8ff),
                    ),
                  ),
                  inputHint: 'Enter your last name',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Last Name is required';
                    } else {
                      return null;
                    }
                  },
                ),
                heightSpacer(15),
                Text(
                  'Job Role',
                  style: AppTextTheme.kLabelStyle,
                ),
                CustomTextField(
                  controller: jobRole,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFd1d8ff),
                    ),
                  ),
                  inputHint: 'Enter your Job Role',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Job Role is required';
                    } else {
                      return null;
                    }
                  },
                ),
                // heightSpacer(15),
                // Text(
                //   'Email',
                //   style: AppTextTheme.kLabelStyle,
                // ),
                // CustomTextField(
                //   controller: email,
                //   enabledBorder: OutlineInputBorder(
                //     borderRadius: BorderRadius.circular(14),
                //     borderSide: const BorderSide(
                //       color: Color(0xFFd1d8ff),
                //     ),
                //   ),
                //   inputHint: 'Enter your email',
                //   validator: (value) {
                //     if (value!.isEmpty) {
                //       return 'Email is required';
                //     } else {
                //       return null;
                //     }
                //   },
                // ),
                heightSpacer(15),
                Text(
                  'Password',
                  style: AppTextTheme.kLabelStyle,
                ),
                CustomTextField(
                  controller: password,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFd1d8ff),
                    ),
                  ),
                  inputHint: 'Enter your password',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Password is required';
                    } else {
                      return null;
                    }
                  },
                ),
                heightSpacer(15),
                Text(
                  'Phone Number',
                  style: AppTextTheme.kLabelStyle,
                ),
                CustomTextField(
                  controller: phoneNumber,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFd1d8ff),
                    ),
                  ),
                  inputHint: 'Enter your phone number',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Phone Number is required';
                    } else {
                      return null;
                    }
                  },
                ),
                heightSpacer(40),
                CustomButton(
                  buttonText: 'Create Staff',
                  onTap: () {
                    if (_formKey.currentState!.validate()) {}
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
