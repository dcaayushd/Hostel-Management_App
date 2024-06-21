import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common/spacing.dart';
import '../../../common/constants.dart';
import '../../../common/custom_text_field.dart';

import '../../../theme/text_theme.dart';
import '../../../theme/colors.dart';

import '../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static final _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();

  String? selectedBlock;
  String? selectedRoom;

  List<String> blockOptions = ['A', 'B'];
  List<String> roomOptionsA = [
    '101',
    '102',
    '103',
    '104',
    '105',
    '106',
    '107',
    '108',
    '109',
    '110',
    '111',
    '112',
    '113',
    '114',
    '115',
    '116',
    '117',
    '118',
    '119',
    '120',
    '201',
    '202',
    '203',
    '204',
    '205',
    '206',
    '207',
    '208',
    '209',
    '210',
    '211',
    '212',
    '213',
    '214',
    '215',
    '216',
    '217',
    '218',
    '219',
    '220',
  ];
  List<String> roomOptionsB = [
    '301',
    '302',
    '303',
    '304',
    '305',
    '306',
    '307',
    '308',
    '309',
    '310',
    '311',
    '312',
    '313',
    '314',
    '315',
    '316',
    '317',
    '318',
    '319',
    '320',
    '401',
    '402',
    '403',
    '404',
    '405',
    '406',
    '407',
    '408',
    '409',
    '410',
    '411',
    '412',
    '413',
    '414',
    '415',
    '416',
    '417',
    '418',
    '419',
    '420',
  ];

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    username.dispose();
    firstName.dispose();
    lastName.dispose();
    phoneNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
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
                heightSpacer(40),
                Center(
                  child: Image.asset(
                    AppConstants.logo,
                    width: 150.w,
                    height: 150.h,
                  ),
                ),
                heightSpacer(30),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Register your account',
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: const Color(0xff333333),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                heightSpacer(25),
                Text(
                  'Username',
                  style: AppTextTheme.kLabelStyle,
                ),
                CustomTextField(
                  controller: username,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xffd1d8ff),
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
                      color: Color(0xffd1d8ff),
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
                      color: Color(0xffd1d8ff),
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
                  'Email',
                  style: AppTextTheme.kLabelStyle,
                ),
                CustomTextField(
                  controller: email,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xffd1d8ff),
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
                      color: Color(0xffd1d8ff),
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
                Text(
                  'Phone Number',
                  style: AppTextTheme.kLabelStyle,
                ),
                CustomTextField(
                  controller: phoneNumber,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xffd1d8ff),
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
                heightSpacer(15),
                Row(
                  children: [
                    Container(
                      height: 50.h,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 1,
                            color: Color(
                              0xff2e8b57,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Row(
                        children: [
                          widthSpacer(20),
                          const Text('Block No.'),
                          widthSpacer(20),
                          DropdownButton(
                            value: selectedBlock,
                            onChanged: (String? newValue) {
                              setState(
                                () {
                                  // selectedBlock = newValue!;
                                  selectedBlock = newValue;
                                  selectedRoom = null;
                                },
                              );
                            },
                            items: blockOptions.map((String block) {
                              return DropdownMenuItem(
                                value: block,
                                child: Text(block),
                              );
                            }).toList(),
                          ),
                          widthSpacer(20),
                        ],
                      ),
                    ),
                    widthSpacer(20),
                    Container(
                      height: 50.h,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 1,
                            color: Color(
                              0xff2e8b57,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Row(
                        children: [
                          widthSpacer(20),
                          const Text('Room No.'),
                          widthSpacer(20),
                          DropdownButton<String>(
                            value: selectedRoom,
                            onChanged: (String? newValue) {
                              setState(
                                () {
                                  selectedRoom = newValue;
                                },
                              );
                            },
                            items: (selectedBlock == 'A'
                                    ? roomOptionsA
                                    : roomOptionsB)
                                .map((String room) {
                              return DropdownMenuItem<String>(
                                value: room,
                                child: Text(room),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                heightSpacer(25),
                CustomButton(
                  buttonText: 'Register',
                  onTap: () {
                    log('$selectedBlock');
                    log('$selectedRoom');
                    // if (_formKey.currentState!.validate()) {
                    //   log('validation');
                    // }

                    
                  },
                ),
                // heightSpacer(10),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     const Text('Have an account? '),
                //     InkWell(
                //       onTap: () {
                //         // Login Screen
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) => const LoginScreen(),
                //           ),
                //         );
                //       },
                //       child: Text(
                //         'Login',
                //         style: AppTextTheme.kLabelStyle.copyWith(
                //           fontSize: 14.sp,
                //           color: AppColors.kGreenColor,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
