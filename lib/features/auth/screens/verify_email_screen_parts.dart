part of 'verify_email_screen.dart';

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  bool _requestedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requestedOnce) {
      return;
    }
    _requestedOnce = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final AppState appState = context.read<AppState>();
      if (appState.emailVerificationChallenge == null &&
          appState.currentUser != null &&
          !appState.currentUser!.emailVerified) {
        try {
          await appState.requestEmailVerification();
        } on HostelRepositoryException catch (error) {
          if (!mounted) {
            return;
          }
          showAppMessage(context, error.message, isError: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    try {
      await context.read<AppState>().verifyCurrentUserEmail(
            _codeController.text.trim(),
          );
    } on HostelRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    }
  }

  Future<void> _resendCode() async {
    try {
      final AppState appState = context.read<AppState>();
      final challenge = await appState.requestEmailVerification();
      if (!mounted || challenge == null) {
        return;
      }
      showAppMessage(
        context,
        challenge.isEmailDelivered
            ? 'A new verification code was sent to your email.'
            : 'A fresh verification code is ready below.',
      );
    } on HostelRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final AppUser? user = state.currentUser;
    final challenge = state.emailVerificationChallenge;
    final Brightness brightness = Theme.of(context).brightness;
    final Color primaryTextColor = AppColors.primaryTextFor(brightness);
    final Color mutedTextColor = AppColors.mutedTextFor(brightness);

    if (user == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: buildAppBar(
        context,
        'Verify Email',
        actions: <Widget>[
          TextButton(
            onPressed: state.logout,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
      body: AppScreenBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 480.w),
              child: AppSectionCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        user.fullName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      heightSpacer(6),
                      Text(
                        challenge?.isEmailDelivered ?? false
                            ? 'Enter the code sent to ${user.email}.'
                            : 'Email delivery is not configured on this backend yet. Use the demo verification code shown below for ${user.email}.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: mutedTextColor,
                              height: 1.45,
                            ),
                      ),
                      if (challenge != null) ...<Widget>[
                        heightSpacer(12),
                        _CompactInfoTile(
                          title: 'Code expires',
                          value: _formatDateTime(challenge.expiresAt),
                        ),
                        if (challenge.usesLocalCode) ...<Widget>[
                          heightSpacer(8),
                          _CompactInfoTile(
                            title: 'Local demo code',
                            value: challenge.code,
                          ),
                          if (challenge.deliveryError != null &&
                              challenge.deliveryError!
                                  .trim()
                                  .isNotEmpty) ...<Widget>[
                            heightSpacer(8),
                            Text(
                              'Email delivery failed: ${challenge.deliveryError}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ],
                      ],
                      heightSpacer(16),
                      Text(
                        'Verification code',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: primaryTextColor,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      heightSpacer(4),
                      Text(
                        challenge?.usesLocalCode ?? false
                            ? 'Enter the 6 digit demo code shown above.'
                            : 'Enter the 6 digit code from your inbox.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: mutedTextColor,
                            ),
                      ),
                      heightSpacer(6),
                      CustomTextField(
                        controller: _codeController,
                        inputHint: 'Enter 6 digit code',
                        inputKeyBoardType: TextInputType.number,
                        validator: AppValidators.verificationCode,
                        hintStyle:
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: mutedTextColor,
                                ),
                      ),
                      heightSpacer(16),
                      CustomButton(
                        buttonText: 'Verify',
                        onTap: _verify,
                      ),
                      heightSpacer(8),
                      Center(
                        child: TextButton(
                          onPressed: _resendCode,
                          child: const Text('Resend code'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    final DateTime local = value.toLocal();
    final String hour = local.hour.toString().padLeft(2, '0');
    final String minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} $hour:$minute';
  }
}
