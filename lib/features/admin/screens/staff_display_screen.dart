// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hostel_management_app/common/app_bar.dart';
import 'package:hostel_management_app/common/constants.dart';
import 'package:hostel_management_app/common/spacing.dart';
import 'package:hostel_management_app/theme/text_theme.dart';

class StaffDisplayScreen extends StatefulWidget {
  const StaffDisplayScreen({super.key});

  @override
  State<StaffDisplayScreen> createState() => _StaffDisplayScreenState();
}

class _StaffDisplayScreenState extends State<StaffDisplayScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, 'All Staff'),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 2 / 1.2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: 1,
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: const ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 2,
                    color: Color(0xFF007b38),
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Image.asset(
                              AppConstants.person,
                              width: 90.w,
                              height: 90.h,
                            ),
                            heightSpacer(20),
                            Text(
                              'Hostel Warden',
                              style: AppTextTheme.kLabelStyle,
                            ),
                          ],
                        ),
                        widthSpacer(10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              heightSpacer(10),
                              Text(
                                'Name: Mangal Bdr. Karki',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                ),
                              ),
                              heightSpacer(8),
                              Text(
                                'Email: mangalkarki6@gmail.com',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                ),
                              ),
                              heightSpacer(8),
                              Text(
                                'Contact: 9804532792',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: const Color(0xFFec6977),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                          // widthSpacer(10),
                          // const Icon(
                          //   CupertinoIcons.delete,
                          //   color: Colors.white,
                          //   size: 16,
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
