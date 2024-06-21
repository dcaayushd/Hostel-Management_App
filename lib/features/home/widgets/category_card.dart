// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hostel_management_app/common/spacing.dart';

class CategoryCard extends StatelessWidget {
  final String category;
  final String image;
  final VoidCallback onTap;
  const CategoryCard({
    super.key,
    required this.category,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14.0),
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          shadows: [
            BoxShadow(
              color: Color(0x7f2e8b57),
              blurRadius: 4,
              offset: Offset(1, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              height: 70.h,
              width: 70.w,
              child: Image.asset(image),
            ),
            heightSpacer(10),
            Text(
              category,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xff333333),
                fontSize: 15.sp,
              ),
            ),
            heightSpacer(10),
          ],
        ),
      ),
    );
  }
}
