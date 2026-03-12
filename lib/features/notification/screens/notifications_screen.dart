import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../app/app_chrome.dart';
import '../../../common/app_bar.dart';
import '../../../common/spacing.dart';
import '../../../core/models/app_notification.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/app_icons.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/utils/notification_navigation.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_screen_background.dart';
import '../../../core/widgets/app_section_card.dart';
import '../../../core/widgets/app_top_info_surface.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../theme/colors.dart';

part 'notifications_screen_parts.dart';
part '../widgets/notifications_screen_notification_tile.dart';
part '../widgets/notifications_screen_filter_chip.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}
