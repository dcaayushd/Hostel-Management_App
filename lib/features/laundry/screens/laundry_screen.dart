import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../app/app_chrome.dart';
import '../../../common/app_bar.dart';
import '../../../common/custom_text_field.dart';
import '../../../common/spacing.dart';
import '../../../core/models/app_user.dart';
import '../../../core/models/laundry_models.dart';
import '../../../core/models/user_role.dart';
import '../../../core/services/hostel_repository.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_feature_banner.dart';
import '../../../core/widgets/app_screen_background.dart';
import '../../../core/widgets/app_section_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../features/auth/widgets/custom_button.dart';
import '../../../theme/colors.dart';

part 'laundry_screen_parts.dart';
part '../widgets/laundry_screen_laundry_booking_card.dart';
part '../widgets/laundry_screen_summary_pill.dart';

class LaundryScreen extends StatefulWidget {
  const LaundryScreen({super.key});

  @override
  State<LaundryScreen> createState() => _LaundryScreenState();
}
