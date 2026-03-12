import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/colors.dart';

class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.items,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.hintText,
    this.labelText,
    this.isExpanded = true,
    this.menuMaxHeight,
    this.decoration,
    this.selectedItemBuilder,
  });

  final List<DropdownMenuItem<T>> items;
  final T? initialValue;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final String? hintText;
  final String? labelText;
  final bool isExpanded;
  final double? menuMaxHeight;
  final InputDecoration? decoration;
  final DropdownButtonBuilder? selectedItemBuilder;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Brightness brightness = theme.brightness;
    final Color textColor = AppColors.primaryTextFor(brightness);
    final Color fillColor = AppColors.tonalSurfaceFor(brightness);

    final InputDecoration resolvedDecoration =
        (decoration ?? const InputDecoration()).copyWith(
      labelText: labelText ?? decoration?.labelText,
      hintText: hintText ?? decoration?.hintText,
      filled: true,
      fillColor: fillColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18.r),
        borderSide: BorderSide(color: AppColors.outlineFor(brightness)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18.r),
        borderSide: const BorderSide(
          color: AppColors.kGreenColor,
          width: 1.5,
        ),
      ),
    );

    return DropdownButtonFormField<T>(
      initialValue: initialValue,
      isExpanded: isExpanded,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.mutedIconFor(brightness),
      ),
      decoration: resolvedDecoration,
      dropdownColor: AppColors.surfaceColor(brightness),
      borderRadius: BorderRadius.circular(20.r),
      menuMaxHeight: menuMaxHeight,
      selectedItemBuilder: selectedItemBuilder,
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }
}
