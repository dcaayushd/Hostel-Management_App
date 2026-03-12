import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../app/route_args.dart';
import '../../../common/app_bar.dart';
import '../../../common/custom_text_field.dart';
import '../../../common/spacing.dart';
import '../../../core/models/app_user.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/models/user_role.dart';
import '../../../core/services/hostel_repository.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/utils/app_icons.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_screen_background.dart';
import '../../../core/widgets/app_section_card.dart';
import '../../../features/auth/widgets/custom_button.dart';
import '../../../theme/colors.dart';

part 'chat_screen_parts.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    this.routeArgs,
  });

  final ChatRouteArgs? routeArgs;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}
