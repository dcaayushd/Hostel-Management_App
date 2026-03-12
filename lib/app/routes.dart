import 'package:flutter/material.dart';

import 'route_args.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/admin/screens/create_staff_screen.dart';
import '../features/admin/screens/admin_catalog_screen.dart';
import '../features/admin/screens/issue_screen.dart';
import '../features/admin/screens/resident_directory_screen.dart';
import '../features/admin/screens/room_change_request_screen.dart';
import '../features/admin/screens/staff_display_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/verify_email_screen.dart';
import '../features/chat/screens/chat_screen.dart';
import '../features/gate_pass/screens/gate_pass_screen.dart';
import '../features/laundry/screens/laundry_screen.dart';
import '../features/mess/screens/mess_screen.dart';
import '../features/notification/screens/notifications_screen.dart';
import '../features/notice/screens/notice_board_screen.dart';
import '../features/parcel/screens/parcel_desk_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/search/screens/search_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/student/screens/create_issue_screen.dart';
import '../features/student/screens/hostel_fee_screen.dart';
import '../features/student/screens/room_availability_screen.dart';
import 'app_shell.dart';

class AppRoutes {
  const AppRoutes._();

  static const String root = '/';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyEmail = '/verify-email';
  static const String createIssue = '/create-issue';
  static const String chat = '/chat';
  static const String issues = '/issues';
  static const String createStaff = '/create-staff';
  static const String adminCatalog = '/admin-catalog';
  static const String staff = '/staff';
  static const String residents = '/residents';
  static const String fees = '/fees';
  static const String gatePass = '/gate-pass';
  static const String laundry = '/laundry';
  static const String mess = '/mess';
  static const String notifications = '/notifications';
  static const String notices = '/notices';
  static const String parcelDesk = '/parcel-desk';
  static const String profile = '/profile';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String roomAvailability = '/room-availability';
  static const String roomChangeRequests = '/room-change-requests';

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case register:
        return MaterialPageRoute<void>(
          builder: (_) => const RegisterScreen(),
          settings: routeSettings,
        );
      case forgotPassword:
        final Object? arguments = routeSettings.arguments;
        final String? initialEmail =
            arguments is String && arguments.trim().isNotEmpty
                ? arguments
                : null;
        return MaterialPageRoute<void>(
          builder: (_) => ForgotPasswordScreen(initialEmail: initialEmail),
          settings: routeSettings,
        );
      case verifyEmail:
        return MaterialPageRoute<void>(
          builder: (_) => const VerifyEmailScreen(),
          settings: routeSettings,
        );
      case createIssue:
        return MaterialPageRoute<void>(
          builder: (_) => const StudentCreateIssueScreen(),
          settings: routeSettings,
        );
      case chat:
        final Object? chatArguments = routeSettings.arguments;
        final ChatRouteArgs? chatRouteArgs =
            chatArguments is ChatRouteArgs ? chatArguments : null;
        return MaterialPageRoute<void>(
          builder: (_) => ChatScreen(routeArgs: chatRouteArgs),
          settings: routeSettings,
        );
      case issues:
        return MaterialPageRoute<void>(
          builder: (_) => const IssueScreen(),
          settings: routeSettings,
        );
      case createStaff:
        return MaterialPageRoute<void>(
          builder: (_) => const CreateStaffScreen(),
          settings: routeSettings,
        );
      case adminCatalog:
        return MaterialPageRoute<void>(
          builder: (_) => const AdminCatalogScreen(),
          settings: routeSettings,
        );
      case staff:
        return MaterialPageRoute<void>(
          builder: (_) => const StaffDisplayScreen(),
          settings: routeSettings,
        );
      case residents:
        return MaterialPageRoute<void>(
          builder: (_) => const ResidentDirectoryScreen(),
          settings: routeSettings,
        );
      case fees:
        final Object? feeArguments = routeSettings.arguments;
        final FeeScreenRouteArgs? feeRouteArgs =
            feeArguments is FeeScreenRouteArgs ? feeArguments : null;
        return MaterialPageRoute<void>(
          builder: (_) => HostelFeeScreen(routeArgs: feeRouteArgs),
          settings: routeSettings,
        );
      case gatePass:
        final Object? gatePassArguments = routeSettings.arguments;
        final GatePassRouteArgs? gatePassRouteArgs =
            gatePassArguments is GatePassRouteArgs ? gatePassArguments : null;
        return MaterialPageRoute<void>(
          builder: (_) => GatePassScreen(routeArgs: gatePassRouteArgs),
          settings: routeSettings,
        );
      case laundry:
        return MaterialPageRoute<void>(
          builder: (_) => const LaundryScreen(),
          settings: routeSettings,
        );
      case mess:
        return MaterialPageRoute<void>(
          builder: (_) => const MessScreen(),
          settings: routeSettings,
        );
      case notifications:
        return MaterialPageRoute<void>(
          builder: (_) => const NotificationsScreen(),
          settings: routeSettings,
        );
      case notices:
        return MaterialPageRoute<void>(
          builder: (_) => const NoticeBoardScreen(),
          settings: routeSettings,
        );
      case parcelDesk:
        return MaterialPageRoute<void>(
          builder: (_) => const ParcelDeskScreen(),
          settings: routeSettings,
        );
      case profile:
        return MaterialPageRoute<void>(
          builder: (_) => const ProfileScreen(),
          settings: routeSettings,
        );
      case search:
        return MaterialPageRoute<void>(
          builder: (_) => const SearchScreen(),
          settings: routeSettings,
        );
      case settings:
        return MaterialPageRoute<void>(
          builder: (_) => const SettingsScreen(),
          settings: routeSettings,
        );
      case roomAvailability:
        final Object? arguments = routeSettings.arguments;
        final RoomAvailabilityRouteArgs? routeArgs =
            arguments is RoomAvailabilityRouteArgs ? arguments : null;
        return MaterialPageRoute<void>(
          builder: (_) => RoomAvailabilityScreen(routeArgs: routeArgs),
          settings: routeSettings,
        );
      case roomChangeRequests:
        final Object? roomRequestArguments = routeSettings.arguments;
        final RoomChangeRequestRouteArgs? roomRequestRouteArgs =
            roomRequestArguments is RoomChangeRequestRouteArgs
                ? roomRequestArguments
                : null;
        return MaterialPageRoute<void>(
          builder: (_) =>
              RoomChangeRequestScreen(routeArgs: roomRequestRouteArgs),
          settings: routeSettings,
        );
      case root:
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const AppShell(),
          settings: routeSettings,
        );
    }
  }
}
