import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/colors.dart';
import '../../../theme/text_theme.dart';

part 'custom_button_parts.dart';

class CustomButton extends StatefulWidget {
  final String buttonText;
  final Color? buttonColor;
  final FutureOr<void> Function()? onTap;
  final double? size;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.buttonText,
    this.buttonColor,
    required this.onTap,
    this.size,
    this.isLoading = false,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}
