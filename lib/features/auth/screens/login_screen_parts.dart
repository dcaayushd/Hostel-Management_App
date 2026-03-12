part of 'login_screen.dart';

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await context.read<AppState>().login(
            identifier: _identifierController.text,
            password: _passwordController.text,
          );
    } on HostelRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      showAppMessage(
        context,
        'Something went wrong while signing you in.',
        isError: true,
      );
    }
  }

  Future<void> _configureBackendConnection() async {
    final AppState state = context.read<AppState>();
    final String? result = await showBackendEndpointSheet(
      context: context,
      initialOverride: state.backendBaseUrlOverride,
      activeUrl: state.activeBackendBaseUrl,
      defaultUrlHint: state.backendBaseUrlLockedByBuild
          ? null
          : AppEnvironment.defaultDeviceApiBaseUrl,
      lockedByBuild: state.backendBaseUrlLockedByBuild,
    );
    if (!mounted || result == null) {
      return;
    }
    await state.setBackendBaseUrlOverride(result.isEmpty ? null : result);
    if (!mounted) {
      return;
    }
    showAppMessage(
      context,
      result.isEmpty
          ? 'Backend override cleared. Reopen the app to use the default server.'
          : 'Backend URL saved. Reopen the app to connect to the new server.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final Brightness brightness = Theme.of(context).brightness;
    final Color primaryTextColor = AppColors.primaryTextFor(brightness);
    final Color mutedTextColor = AppColors.mutedTextFor(brightness);
    final TextStyle? labelStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: primaryTextColor,
              fontWeight: FontWeight.w700,
            );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.screenBackgroundGradient(brightness),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 460.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28.r),
                        child: Image.asset(
                          AppConstants.logo,
                          height: 96.h,
                          width: 96.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    heightSpacer(18),
                    Text(
                      'Hostel Hub',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    heightSpacer(14),
                    AppSectionCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Email or phone', style: labelStyle),
                            heightSpacer(6),
                            CustomTextField(
                              controller: _identifierController,
                              inputHint: 'Email or phone',
                              inputKeyBoardType: TextInputType.emailAddress,
                              validator: AppValidators.emailOrPhone,
                              autofillHints: const <String>[
                                AutofillHints.username,
                                AutofillHints.email,
                                AutofillHints.telephoneNumber,
                              ],
                            ),
                            heightSpacer(10),
                            Text('Password', style: labelStyle),
                            heightSpacer(6),
                            CustomTextField(
                              controller: _passwordController,
                              inputHint: 'Password',
                              obscureText: _obscurePassword,
                              validator: AppValidators.password,
                              autofillHints: const <String>[
                                AutofillHints.password
                              ],
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
                                  color: mutedTextColor,
                                ),
                              ),
                            ),
                            heightSpacer(16),
                            CustomButton(
                              buttonText: 'Login',
                              onTap: _login,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: state.isLoading
                                    ? null
                                    : () {
                                        Navigator.of(context).pushNamed(
                                          AppRoutes.forgotPassword,
                                        );
                                      },
                                child: const Text('Forgot password?'),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('New here?',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                                TextButton(
                                  onPressed: state.isLoading
                                      ? null
                                      : () {
                                          Navigator.of(context).pushNamed(
                                            AppRoutes.register,
                                          );
                                        },
                                  child: const Text('Register'),
                                ),
                              ],
                            ),
                            heightSpacer(4),
                            Center(
                              child: TextButton.icon(
                                onPressed: _configureBackendConnection,
                                icon: const Icon(AppIcons.backend),
                                label: const Text('Backend connection'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
