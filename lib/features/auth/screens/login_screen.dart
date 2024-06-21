// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../home/screen/home_screen.dart';
import '../../../features/auth/screens/register_screen.dart';

import '../../../theme/colors.dart';
import '../../../theme/text_theme.dart';

import '/common/constants.dart';
import '/common/custom_text_field.dart';
import '/common/spacing.dart';

import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static final _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 15.w,
            vertical: 20.h,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    AppConstants.logo,
                    height: 250.h,
                  ),
                ),
                heightSpacer(30),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Login to your account',
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: const Color(0xFF333333),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                heightSpacer(25),
                Text(
                  'Email',
                  style: AppTextTheme.kLabelStyle,
                ),
                heightSpacer(15),
                CustomTextField(
                  controller: email,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFd1d8ff),
                    ),
                  ),
                  inputHint: 'Enter your email',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Email is required';
                    } else {
                      return null;
                    }
                  },
                ),
                heightSpacer(20),
                Text(
                  'Password',
                  style: AppTextTheme.kLabelStyle,
                ),
                heightSpacer(15),
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
                heightSpacer(30),
                CustomButton(
                  buttonText: 'Login',
                  buttonColor: Colors.white,
                  onTap: () {
                    // if (_formKey.currentState!.validate()) {
                    //   log('validation');
                    // }
                    // Navigator.push(
                    //   context,
                    //   CupertinoPageRoute(
                    //     builder: (context) => const HomeScreen(),
                    //   ),
                    // );
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
                heightSpacer(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Don\'t have an account yet? '),
                    InkWell(
                      onTap: () {
                        // Register Screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Register',
                        style: AppTextTheme.kLabelStyle.copyWith(
                          fontSize: 14.sp,
                          color: AppColors.kGreenColor,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
