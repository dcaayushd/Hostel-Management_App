import 'package:flutter/material.dart';
import 'my_form_field.dart';
import '../theme/colors.dart';
import '../theme/text_theme.dart';

class CustomTextField extends StatelessWidget {
  final int? maxLines, minLines;
  final String? inputHint;
  final Widget? suffixIcon, prefixIcon;
  final bool? obscureText;
  final TextInputType? inputKeyBoardType;
  final Color? inputFillColor;
  final InputBorder? border, focusedBorder, enabledBorder;
  final Function()? pressMe;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final TextStyle? hintStyle;
  final Function(String)? onChanged;
  final bool? readOnly;
  final int? maxLength;
  final TextInputAction? inputAction;
  final TextCapitalization? inputCapitalization;
  final Iterable<String>? autofillHints;
  final VoidCallback? onTap;
  final bool? enabled;

  const CustomTextField({
    super.key,
    this.inputHint,
    this.suffixIcon,
    this.obscureText,
    this.inputKeyBoardType,
    this.inputFillColor,
    this.prefixIcon,
    this.border,
    this.pressMe,
    this.validator,
    this.controller,
    this.maxLines,
    this.minLines,
    this.hintStyle,
    this.focusedBorder,
    this.enabledBorder,
    this.onChanged,
    this.readOnly,
    this.maxLength,
    this.inputAction,
    this.inputCapitalization,
    this.autofillHints,
    this.onTap,
    this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final decorationTheme = theme.inputDecorationTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MyFormField(
            enabledBorder: enabledBorder ?? decorationTheme.enabledBorder,
            maxLines: maxLines ?? 1,
            minLines: minLines ?? 1,
            controller: controller,
            validator: validator,
            inputFilled: true,
            inputFillColor: inputFillColor ??
                decorationTheme.fillColor ??
                AppColors.tonalSurfaceFor(theme.brightness),
            inputHint: inputHint,
            readOnly: readOnly,
            obscureText: obscureText,
            inputKeyboardType: inputKeyBoardType,
            maxLength: maxLength,
            inputAction: inputAction,
            inputCapitalization: inputCapitalization,
            autofillHints: autofillHints,
            onTap: onTap,
            enabled: enabled,
            contentPadding: const EdgeInsets.only(
              top: 14,
              left: 16,
              right: 18,
              bottom: 14,
            ),
            border: border ?? decorationTheme.border,
            focusedBorder: focusedBorder ?? decorationTheme.focusedBorder,
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: suffixIcon,
            ),
            onChanged: onChanged,
            prefixIcon: prefixIcon,
            inputTextStyle:
                theme.textTheme.bodyLarge ?? AppTextTheme.kPrimaryStyle,
            inputHintStyle: hintStyle ??
                decorationTheme.hintStyle ??
                AppTextTheme.kHintStyle,
          ),
        ],
      ),
    );
  }
}
