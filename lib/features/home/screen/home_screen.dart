import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hostel_management_app/common/constants.dart';
import 'package:hostel_management_app/common/spacing.dart';
import 'package:hostel_management_app/features/home/widgets/category_card.dart';
import 'package:hostel_management_app/theme/colors.dart';
import 'package:hostel_management_app/theme/text_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: AppTextTheme.kLabelStyle.copyWith(
            fontSize: 22.sp,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15.w),
            child: InkWell(
              onTap: () {},
              child: SvgPicture.asset(
                AppConstants.profile,
              ),
            ),
          ),
        ],
        backgroundColor: AppColors.kGreenColor,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 15.w,
          vertical: 10.h,
        ),
        child: Column(
          children: [
            heightSpacer(20),
            Container(
              height: 140.h,
              width: double.maxFinite,
              decoration: const ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 2,
                    color: Color(0xff007b3b),
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(2),
                  ),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x332e8b57),
                    blurRadius: 8,
                    offset: Offset(2, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aayush Dc',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xff333333),
                            fontSize: 24.sp,
                          ),
                        ),
                        heightSpacer(15),
                        Text(
                          'Room No.: 412',
                          style: TextStyle(
                            // fontWeight: FontWeight.w700,
                            color: const Color(0xff333333),
                            fontSize: 15.sp,
                          ),
                        ),
                        Text(
                          'Block No.: B',
                          style: TextStyle(
                            // fontWeight: FontWeight.w700,
                            color: const Color(0xff333333),
                            fontSize: 15.sp,
                          ),
                        ),
                      ],
                    ),
                    widthSpacer(10),
                    Column(
                      children: [
                        SvgPicture.asset(AppConstants.createIssue),
                        Text(
                          'Create Issues',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            heightSpacer(30),
            Container(
              width: double.maxFinite,
              // color: const Color(0xff262e8b57),
              color: const Color(0x262e8b57),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  heightSpacer(20),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Categories',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff333333),
                        fontSize: 19.sp,
                      ),
                    ),
                  ),
                  heightSpacer(15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CategoryCard(
                        category: 'Room\nAvailability',
                        image: AppConstants.roomAvailability,
                        onTap: () {},
                      ),
                      CategoryCard(
                        category: 'All\nIssues',
                        image: AppConstants.allIssues,
                        onTap: () {},
                      ),
                      CategoryCard(
                        category: 'Staff\nMembers',
                        image: AppConstants.staffMember,
                        onTap: () {},
                      ),
                    ],
                  ),
                  heightSpacer(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CategoryCard(
                        category: 'Create\nStaff',
                        image: AppConstants.createStaff,
                        onTap: () {},
                      ),
                      CategoryCard(
                        category: 'Hostel\nFees',
                        image: AppConstants.hostelFee,
                        onTap: () {},
                      ),
                      CategoryCard(
                        category: 'Change\nRequests',
                        image: AppConstants.roomChange,
                        onTap: () {},
                      ),
                    ],
                  ),
                  heightSpacer(20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
