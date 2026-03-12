import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../app/app_chrome.dart';
import '../../../app/route_args.dart';
import '../../../app/routes.dart';
import '../../../common/app_bar.dart';
import '../../../common/custom_text_field.dart';
import '../../../common/spacing.dart';
import '../../../core/models/app_user.dart';
import '../../../core/models/hostel_block.dart';
import '../../../core/models/hostel_room.dart';
import '../../../core/models/room_change_request.dart';
import '../../../core/services/hostel_repository.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_screen_background.dart';
import '../../../core/widgets/app_section_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../features/auth/widgets/custom_button.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_theme.dart';

part 'room_change_request_screen_parts.dart';
part '../widgets/room_change_request_screen_student_room_request_view.dart';
part '../widgets/room_change_request_screen_admin_room_request_view.dart';
part '../widgets/room_change_request_screen_room_request_card.dart';
part '../widgets/room_change_request_screen_detail_row.dart';

class RoomChangeRequestScreen extends StatefulWidget {
  const RoomChangeRequestScreen({
    super.key,
    this.routeArgs,
  });

  final RoomChangeRequestRouteArgs? routeArgs;

  @override
  State<RoomChangeRequestScreen> createState() =>
      _RoomChangeRequestScreenState();
}
