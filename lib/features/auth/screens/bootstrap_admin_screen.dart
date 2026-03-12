import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../common/custom_text_field.dart';
import '../../../common/spacing.dart';
import '../../../core/config/app_environment.dart';
import '../../../core/services/hostel_repository.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/app_icons.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/widgets/app_section_card.dart';
import '../../../core/widgets/backend_endpoint_sheet.dart';
import '../../../theme/colors.dart';
import '../widgets/custom_button.dart';

part 'bootstrap_admin_screen_parts.dart';

class BootstrapAdminScreen extends StatefulWidget {
  const BootstrapAdminScreen({super.key});

  @override
  State<BootstrapAdminScreen> createState() => _BootstrapAdminScreenState();
}
