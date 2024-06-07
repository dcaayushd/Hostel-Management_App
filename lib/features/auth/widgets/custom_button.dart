import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_theme.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final Color? buttonColor;
  final VoidCallback onTap;
  final double? size;
  const CustomButton({
    super.key,
    required this.buttonText,
    this.buttonColor,
    required this.onTap,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.maxFinite,
        height: 50.h,
        decoration: BoxDecoration(
          color: const Color(0xFF2e8b57),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Center(
          child: Text(
            buttonText,
            style: AppTextTheme.kLabelStyle.copyWith(
                color: buttonColor ?? AppColors.kLight, fontSize: size ?? 16),
          ),
        ),
      ),
    );
  }
}
