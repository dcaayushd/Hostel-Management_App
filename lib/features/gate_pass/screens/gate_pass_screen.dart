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
import '../../../core/models/gate_pass_models.dart';
import '../../../core/models/user_role.dart';
import '../../../core/services/hostel_repository.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_feature_banner.dart';
import '../../../core/widgets/app_screen_background.dart';
import '../../../core/widgets/app_section_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../features/auth/widgets/custom_button.dart';
import '../../../theme/button_styles.dart';
import '../../../theme/colors.dart';

part 'gate_pass_screen_parts.dart';
part '../widgets/gate_pass_screen_gate_pass_summary.dart';
part '../widgets/gate_pass_screen_gate_desk_processor.dart';
part '../widgets/gate_pass_screen_digital_pass_card.dart';
part '../widgets/gate_pass_screen_gate_reminder_section.dart';
part '../widgets/gate_pass_screen_gate_movement_section.dart';
part '../widgets/gate_pass_screen_gate_pass_list_section.dart';
part '../widgets/gate_pass_screen_gate_movement_tile.dart';
part '../widgets/gate_pass_screen_gate_pass_card.dart';
part '../widgets/gate_pass_screen_inline_action.dart';
part '../widgets/gate_pass_screen_pseudo_qr_block.dart';

class GatePassScreen extends StatefulWidget {
  const GatePassScreen({
    super.key,
    this.routeArgs,
  });

  final GatePassRouteArgs? routeArgs;

  @override
  State<GatePassScreen> createState() => _GatePassScreenState();
}
