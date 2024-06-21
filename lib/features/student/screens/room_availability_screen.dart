import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hostel_management_app/common/constants.dart';
import 'package:hostel_management_app/common/spacing.dart';

import '../../../common/app_bar.dart';

class RoomAvailabilityScreen extends StatefulWidget {
  const RoomAvailabilityScreen({super.key});

  @override
  State<RoomAvailabilityScreen> createState() => _RoomAvailabilityScreenState();
}

class _RoomAvailabilityScreenState extends State<RoomAvailabilityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, 'Room Availability'),
      body: Column(
        children: [
          ListView.builder(
            padding: EdgeInsets.all(10.h),
            shrinkWrap: true,
            itemCount: 2,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: const RoomCard(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class RoomCard extends StatelessWidget {
  const RoomCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.r),
            topRight: Radius.circular(30.r),
            bottomLeft: Radius.circular(30.r),
          ),
          border: Border.all(
            color: const Color(0xFF007b3b),
            width: 2,
          )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Image.asset(
                AppConstants.bed,
                height: 70.h,
                width: 70.w,
              ),
              const Text(
                'Room No. : 413',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          widthSpacer(15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Block:',
                style: TextStyle(
                  fontSize: 16.sp,
                ),
              ),
              heightSpacer(5),
              Text(
                'Capacity:',
                style: TextStyle(
                  fontSize: 16.sp,
                ),
              ),
              heightSpacer(5),
              Text(
                'Current Capacity:',
                style: TextStyle(
                  fontSize: 16.sp,
                ),
              ),
              heightSpacer(5),
              Text(
                'Room Type:',
                style: TextStyle(
                  fontSize: 16.sp,
                ),
              ),
              heightSpacer(5),
              Row(
                children: [
                  Text(
                    'Status:',
                    style: TextStyle(
                      fontSize: 16.sp,
                    ),
                  ),
                  widthSpacer(10),
                  Container(
                    height: 30.h,
                    padding: const EdgeInsets.only(
                      left: 5,
                      right: 5,
                      bottom: 5,
                      top: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ecc71),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Available',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
