import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'app_chrome.dart';
import '../core/models/app_notification.dart';
import '../core/models/app_user.dart';
import '../core/models/user_role.dart';
import '../core/state/app_state.dart';
import '../core/utils/app_icons.dart';
import '../core/utils/feedback.dart';
import '../core/utils/notification_navigation.dart';
import '../features/auth/screens/bootstrap_admin_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/verify_email_screen.dart';
import '../features/chat/screens/chat_screen.dart';
import '../features/admin/screens/issue_screen.dart';
import '../features/home/screen/home_screen.dart';
import '../features/notice/screens/notice_board_screen.dart';
import '../features/search/screens/search_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/student/screens/hostel_fee_screen.dart';
import '../theme/colors.dart';

part 'app_shell_parts.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (BuildContext context, AppState state, Widget? child) {
        if (state.isLoading && state.rooms.isEmpty) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 380),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            final Animation<Offset> offsetAnimation = Tween<Offset>(
              begin: const Offset(0.014, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: offsetAnimation,
                child: child,
              ),
            );
          },
          layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          child: state.requiresAdminBootstrap
              ? const BootstrapAdminScreen(
                  key: ValueKey<String>('bootstrap-admin'),
                )
              : state.isAuthenticated
                  ? state.requiresEmailVerification
                      ? const VerifyEmailScreen(
                          key: ValueKey<String>('verify-email'),
                        )
                      : const _AuthenticatedShell(
                          key: ValueKey<String>('authenticated-shell'),
                        )
                  : const LoginScreen(key: ValueKey<String>('login')),
        );
      },
    );
  }
}
