import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../app/app_chrome.dart';
import '../../../common/app_bar.dart';
import '../../../common/custom_text_field.dart';
import '../../../common/spacing.dart';
import '../../../core/models/app_user.dart';
import '../../../core/models/mess_models.dart';
import '../../../core/models/user_role.dart';
import '../../../core/services/hostel_repository.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_screen_background.dart';
import '../../../core/widgets/app_section_card.dart';
import '../../../core/widgets/app_top_info_surface.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../features/auth/widgets/custom_button.dart';
import '../../../theme/colors.dart';

part 'mess_screen_parts.dart';
part '../widgets/mess_screen_student_mess_view.dart';
part '../widgets/mess_screen_admin_mess_view.dart';
part '../widgets/mess_screen_student_mess_hero.dart';
part '../widgets/mess_screen_admin_mess_hero.dart';
part '../widgets/mess_screen_menu_section.dart';
part '../widgets/mess_screen_menu_day_card.dart';
part '../widgets/mess_screen_attendance_section.dart';
part '../widgets/mess_screen_attendance_resident_card.dart';
part '../widgets/mess_screen_mess_bill_section.dart';
part '../widgets/mess_screen_feedback_section.dart';
part '../widgets/mess_screen_feedback_card.dart';
part '../widgets/mess_screen_compact_stat_card.dart';
part '../widgets/mess_screen_meal_toggle_chip.dart';
part '../widgets/mess_screen_meal_status_pill.dart';
part '../widgets/mess_screen_menu_item_pill.dart';
part '../widgets/mess_screen_rating_selector.dart';
part '../widgets/mess_screen_star_badge.dart';
part '../widgets/mess_screen_hero_stat.dart';
part '../widgets/mess_screen_hero_pill.dart';
part '../widgets/mess_screen_day_chip.dart';

class MessScreen extends StatefulWidget {
  const MessScreen({super.key});

  @override
  State<MessScreen> createState() => _MessScreenState();
}
