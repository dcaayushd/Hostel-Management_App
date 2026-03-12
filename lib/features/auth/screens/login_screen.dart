import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../common/constants.dart';
import '../../../common/custom_text_field.dart';
import '../../../common/spacing.dart';
import '../../../core/services/hostel_repository.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/app_icons.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/widgets/app_section_card.dart';
import '../../../theme/colors.dart';
import '../widgets/custom_button.dart';

part 'login_screen_parts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
