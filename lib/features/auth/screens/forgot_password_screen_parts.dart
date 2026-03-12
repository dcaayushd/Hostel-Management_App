part of 'forgot_password_screen.dart';

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _requestFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _resetFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  AuthChallenge? _challenge;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.initialEmail ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _requestReset() async {
    if (!_requestFormKey.currentState!.validate()) {
      return;
    }
    try {
      final AuthChallenge challenge =
          await context.read<AppState>().requestPasswordReset(
                email: _emailController.text.trim(),
              );
      if (!mounted) {
        return;
      }
      setState(() {
        _challenge = challenge;
      });
      showAppMessage(
        context,
        challenge.isEmailDelivered
            ? 'Reset code sent to your email.'
            : 'Reset code is ready below.',
      );
    } on HostelRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    }
  }

  Future<void> _resetPassword() async {
    if (!_resetFormKey.currentState!.validate()) {
      return;
    }
    try {
      await context.read<AppState>().resetPassword(
            email: _emailController.text.trim(),
            code: _codeController.text.trim(),
            newPassword: _passwordController.text.trim(),
          );
      if (!mounted) {
        return;
      }
      showAppMessage(
          context, 'Password updated. Sign in with the new password.');
      Navigator.of(context).pop();
    } on HostelRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthChallenge? challenge = _challenge;

    return Scaffold(
      appBar: buildAppBar(context, 'Reset Password'),
      body: AppScreenBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 480.w),
              child: Column(
                children: <Widget>[
                  AppSectionCard(
                    child: Form(
                      key: _requestFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Send reset code',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          heightSpacer(6),
                          Text(
                            'Use the email address linked to the account.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          heightSpacer(14),
                          Text('Email',
                              style: Theme.of(context).textTheme.labelLarge),
                          heightSpacer(6),
                          CustomTextField(
                            controller: _emailController,
                            inputHint: 'name@example.com',
                            inputKeyBoardType: TextInputType.emailAddress,
                            validator: AppValidators.email,
                          ),
                          heightSpacer(16),
                          CustomButton(
                            buttonText: 'Send code',
                            onTap: _requestReset,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (challenge != null) ...<Widget>[
                    heightSpacer(12),
                    AppSectionCard(
                      child: Form(
                        key: _resetFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Confirm reset',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            heightSpacer(10),
                            _ResetInfoRow(
                              label: 'Expires',
                              value: _formatDateTime(challenge.expiresAt),
                            ),
                            if (challenge.usesLocalCode) ...<Widget>[
                              heightSpacer(8),
                              _ResetInfoRow(
                                label: 'Local demo code',
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
                                        color:
                                            Theme.of(context).colorScheme.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ] else ...<Widget>[
                              heightSpacer(8),
                              Text(
                                'Check your inbox for the reset code sent to ${challenge.email}.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                            heightSpacer(14),
                            Text('Verification code',
                                style: Theme.of(context).textTheme.labelLarge),
                            heightSpacer(6),
                            CustomTextField(
                              controller: _codeController,
                              inputHint: '6 digit code',
                              inputKeyBoardType: TextInputType.number,
                              validator: AppValidators.verificationCode,
                            ),
                            heightSpacer(12),
                            Text('New password',
                                style: Theme.of(context).textTheme.labelLarge),
                            heightSpacer(6),
                            CustomTextField(
                              controller: _passwordController,
                              inputHint: 'Create a new password',
                              obscureText: _obscurePassword,
                              validator: AppValidators.password,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? AppIcons.visibility
                                      : AppIcons.visibilityOff,
                                ),
                              ),
                            ),
                            heightSpacer(16),
                            CustomButton(
                              buttonText: 'Update password',
                              onTap: _resetPassword,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
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
