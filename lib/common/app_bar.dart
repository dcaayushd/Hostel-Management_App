import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/colors.dart';
import '../theme/text_theme.dart';

const double _kAppBarBottomRadius = 24;
const double _kAppBarToolbarHeight = 62;

PreferredSizeWidget buildAppBar(
  BuildContext context,
  String title, {
  List<Widget>? actions,
}) {
  final ThemeData theme = Theme.of(context);
  final Brightness brightness = theme.brightness;
  final Color foregroundColor =
      theme.appBarTheme.foregroundColor ?? Colors.white;
  final SystemUiOverlayStyle overlayStyle =
      theme.appBarTheme.systemOverlayStyle ?? SystemUiOverlayStyle.light;
  final double preferredHeight =
      MediaQuery.of(context).padding.top + _kAppBarToolbarHeight.h;
  final ModalRoute<dynamic>? route = ModalRoute.of(context);
  final bool canNavigateBack =
      route?.impliesAppBarDismissal ?? Navigator.of(context).canPop();
  final Widget? leading = canNavigateBack
      ? IconButton(
          onPressed: () {
            Navigator.of(context).maybePop();
          },
          icon: Icon(
            CupertinoIcons.back,
            color: foregroundColor,
          ),
        )
      : null;
  final Widget? trailing = actions == null
      ? null
      : Row(
          mainAxisSize: MainAxisSize.min,
          children: actions,
        );

  return PreferredSize(
    preferredSize: Size.fromHeight(preferredHeight),
    child: AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Material(
        color: AppColors.appBarColor(brightness),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: _kAppBarToolbarHeight.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.appBarColor(brightness),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(_kAppBarBottomRadius),
                  bottomRight: Radius.circular(_kAppBarBottomRadius),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: leading == null ? 14.w : 4.w,
                  right: 6.w,
                ),
                child: NavigationToolbar(
                  leading: leading,
                  middle: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: (theme.appBarTheme.titleTextStyle ??
                            AppTextTheme.kLabelStyle)
                        .copyWith(
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w800,
                      color: foregroundColor,
                    ),
                  ),
                  trailing: trailing,
                  centerMiddle: true,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
