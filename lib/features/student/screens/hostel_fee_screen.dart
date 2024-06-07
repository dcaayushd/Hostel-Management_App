import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../../common/app_bar.dart';
import '../../../common/constants.dart';
import '../../../common/spacing.dart';

class HostelFeeScreen extends StatelessWidget {
  const HostelFeeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context,
        'Hostel Fees',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              heightSpacer(20),
              SvgPicture.asset(
                AppConstants.hostel,
                height: 200.h,
              ),
              heightSpacer(40),
              Container(
                width: double.maxFinite,
                decoration: ShapeDecoration(
                  color: const Color(0x4C2E8B57),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 4,
                      strokeAlign: BorderSide.strokeAlignOutside,
                      color: Color(0xFF2E8857),
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x332E8B57),
                      blurRadius: 8,
                      offset: Offset(1, 4),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      heightSpacer(20),
                      Text(
                        'Hostel Details',
                        style: TextStyle(
                          color: const Color(0xFF333333),
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      heightSpacer(20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Block No.',
                                style: TextStyle(
                                  color: const Color(0xFF464646),
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Text(
                                ' : B',
                                style: TextStyle(
                                  color: Color(0xFF464646),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Room No.',
                                style: TextStyle(
                                  color: const Color(0xFF464646),
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Text(
                                ' : 413',
                                style: TextStyle(
                                  color: Color(0xFF464646),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      heightSpacer(20),
                      const Text(
                        'Payment Details ',
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      heightSpacer(20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Maintenance charge : ',
                            style: TextStyle(
                              color: const Color(0xFF464646),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Rs. 1245',
                            style: TextStyle(
                              color: const Color(0xFF464646),
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                      heightSpacer(20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Parking charge : ',
                            style: TextStyle(
                              color: const Color(0xFF464646),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Rs. 435',
                            style: TextStyle(
                              color: const Color(0xFF464646),
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                      heightSpacer(20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Room water charge : ',
                            style: TextStyle(
                              color: const Color(0xFF464646),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Rs. 560',
                            style: TextStyle(
                              color: const Color(0xFF464646),
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                      heightSpacer(20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Room charge : ',
                            style: TextStyle(
                              color: const Color(0xFF464646),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Rs. 1560',
                            style: TextStyle(
                              color: const Color(0xFF464646),
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                      heightSpacer(20),
                      const Divider(
                        color: Colors.black,
                      ),
                      heightSpacer(20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount : ',
                            style: TextStyle(
                              color: const Color(0xFF464646),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Rs. 3800',
                            style: TextStyle(
                              color: const Color(0xFF464646),
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                      heightSpacer(30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
