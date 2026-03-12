import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../app/app_chrome.dart';
import '../../../app/routes.dart';
import '../../../app/route_args.dart';
import '../../../common/app_bar.dart';
import '../../../common/custom_text_field.dart';
import '../../../common/spacing.dart';
import '../../../core/models/admin_catalog.dart';
import '../../../core/models/app_notification.dart';
import '../../../core/models/app_user.dart';
import '../../../core/models/hostel_room.dart';
import '../../../core/models/issue_ticket.dart';
import '../../../core/models/laundry_models.dart';
import '../../../core/models/notice_item.dart';
import '../../../core/models/room_change_request.dart';
import '../../../core/models/user_role.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/app_icons.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_screen_background.dart';
import '../../../core/widgets/app_section_card.dart';
import '../../notice/providers/notice_provider.dart';
import '../../../theme/colors.dart';

part 'search_screen_parts.dart';
part '../widgets/search_screen_search_result_tile.dart';
part '../widgets/search_screen_search_stat_chip.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}
