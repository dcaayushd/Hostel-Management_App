import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const double kFloatingBottomNavHeight = 68;
const double kFloatingBottomNavBottomGap = 2;
const double kFloatingBottomNavHorizontalInset = 18;
const double kFloatingBottomNavOuterRadius = 26;
const double kFloatingBottomNavItemRadius = 18;

double appBottomNavClearance(
  BuildContext context, {
  double extra = 18,
}) {
  final MediaQueryData mediaQuery = MediaQuery.of(context);
  final ModalRoute<dynamic>? route = ModalRoute.of(context);
  final bool hasFloatingShellNav =
      !(route?.impliesAppBarDismissal ?? Navigator.of(context).canPop());
  if (!hasFloatingShellNav) {
    return mediaQuery.padding.bottom + extra.h + 16.h;
  }
  return mediaQuery.padding.bottom +
      kFloatingBottomNavBottomGap.h +
      kFloatingBottomNavHeight.h +
      extra.h;
}

EdgeInsets appPagePadding(
  BuildContext context, {
  double horizontal = 14,
  double top = 8,
  double bottomExtra = 18,
}) {
  return EdgeInsets.fromLTRB(
    horizontal.w,
    top.h,
    horizontal.w,
    appBottomNavClearance(context, extra: bottomExtra),
  );
}
