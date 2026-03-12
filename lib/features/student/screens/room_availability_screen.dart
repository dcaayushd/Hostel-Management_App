import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../app/app_chrome.dart';
import '../../../app/route_args.dart';
import '../../../app/routes.dart';
import '../../../common/app_bar.dart';
import '../../../common/custom_text_field.dart';
import '../../../common/spacing.dart';
import '../../../core/models/hostel_block.dart';
import '../../../core/models/hostel_room.dart';
import '../../../core/models/user_role.dart';
import '../../../core/services/hostel_repository.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_screen_background.dart';
import '../../../core/widgets/app_section_card.dart';
import '../../../core/widgets/app_top_info_surface.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../features/auth/widgets/custom_button.dart';
import '../../../theme/colors.dart';

part 'room_availability_screen_parts.dart';
part '../widgets/room_availability_screen_admin_inventory_composer.dart';
part '../widgets/room_availability_screen_room_inventory_card.dart';
part '../widgets/room_availability_screen_summary_tile.dart';
part '../widgets/room_availability_screen_meta_pill.dart';

const List<String> _roomTypes = <String>[
  'Single Occupancy',
  'Double Sharing',
  'Triple Sharing',
];

class RoomAvailabilityScreen extends StatefulWidget {
  const RoomAvailabilityScreen({
    super.key,
    this.routeArgs,
  });

  final RoomAvailabilityRouteArgs? routeArgs;

  @override
  State<RoomAvailabilityScreen> createState() => _RoomAvailabilityScreenState();
}
