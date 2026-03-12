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
import '../../../core/models/fee_charge_item.dart';
import '../../../core/models/fee_settings.dart';
import '../../../core/models/fee_summary.dart';
import '../../../core/models/payment_record.dart';
import '../../../core/services/hostel_repository.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_screen_background.dart';
import '../../../core/widgets/app_section_card.dart';
import '../../../core/widgets/app_top_info_surface.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../features/auth/widgets/custom_button.dart';
import '../../../theme/colors.dart';

part 'hostel_fee_screen_parts.dart';
part '../widgets/hostel_fee_screen_student_fee_view.dart';
part '../widgets/hostel_fee_screen_admin_fee_view.dart';
part '../widgets/hostel_fee_screen_student_fee_hero.dart';
part '../widgets/hostel_fee_screen_reminder_card.dart';
part '../widgets/hostel_fee_screen_payment_review_sheet.dart';
part '../widgets/hostel_fee_screen_payment_progress_dialog.dart';
part '../widgets/hostel_fee_screen_payment_method_tile.dart';
part '../widgets/hostel_fee_screen_payment_history_tile.dart';
part '../widgets/hostel_fee_screen_admin_resident_fee_tile.dart';
part '../widgets/hostel_fee_screen_admin_payment_tile.dart';
part '../widgets/hostel_fee_screen_receipt_sheet.dart';
part '../widgets/hostel_fee_screen_hero_chip.dart';
part '../widgets/hostel_fee_screen_section_title.dart';
part '../widgets/hostel_fee_screen_progress_strip.dart';
part '../widgets/hostel_fee_screen_fee_field.dart';
part '../widgets/hostel_fee_screen_fee_row.dart';

class HostelFeeScreen extends StatefulWidget {
  const HostelFeeScreen({
    super.key,
    this.routeArgs,
  });

  final FeeScreenRouteArgs? routeArgs;

  @override
  State<HostelFeeScreen> createState() => _HostelFeeScreenState();
}
