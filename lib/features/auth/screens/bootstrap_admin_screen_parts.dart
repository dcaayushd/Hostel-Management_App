part of 'bootstrap_admin_screen.dart';

class _BootstrapAdminScreenState extends State<BootstrapAdminScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await context.read<AppState>().bootstrapAdmin(
            username: _usernameController.text,
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            phoneNumber: _phoneController.text,
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
        'Unable to create the admin workspace.',
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
                    Text(
                      'Set Up Admin Workspace',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    heightSpacer(8),
                    Text(
                      'Start with a clean hostel database and create the first admin account.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.mutedTextFor(brightness),
                            height: 1.45,
                          ),
                    ),
                    heightSpacer(4),
                    TextButton.icon(
                      onPressed: _configureBackendConnection,
                      icon: const Icon(AppIcons.backend),
                      label: const Text('Backend connection'),
                    ),
                    heightSpacer(14),
                    AppSectionCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Username', style: labelStyle),
                            heightSpacer(6),
                            CustomTextField(
                              controller: _usernameController,
                              inputHint: 'Choose an admin username',
                              validator: (String? value) =>
                                  AppValidators.requiredField(
                                value,
                                'Username',
                              ),
                            ),
                            heightSpacer(10),
                            Text('First name', style: labelStyle),
                            heightSpacer(6),
                            CustomTextField(
                              controller: _firstNameController,
                              inputHint: 'Admin first name',
                              inputCapitalization: TextCapitalization.words,
                              validator: (String? value) =>
                                  AppValidators.requiredField(
                                value,
                                'First name',
                              ),
                            ),
                            heightSpacer(10),
                            Text('Last name', style: labelStyle),
                            heightSpacer(6),
                            CustomTextField(
                              controller: _lastNameController,
                              inputHint: 'Admin last name',
                              inputCapitalization: TextCapitalization.words,
                              validator: (String? value) =>
                                  AppValidators.requiredField(
                                value,
                                'Last name',
                              ),
                            ),
                            heightSpacer(10),
                            Text('Email', style: labelStyle),
                            heightSpacer(6),
                            CustomTextField(
                              controller: _emailController,
                              inputHint: 'admin@yourhostel.com',
                              inputKeyBoardType: TextInputType.emailAddress,
                              validator: AppValidators.email,
                            ),
                            heightSpacer(10),
                            Text('Phone', style: labelStyle),
                            heightSpacer(6),
                            CustomTextField(
                              controller: _phoneController,
                              inputHint: '98XXXXXXXX',
                              inputKeyBoardType: TextInputType.phone,
                              validator: AppValidators.phoneNumber,
                              maxLength: 10,
                            ),
                            heightSpacer(10),
                            Text('Password', style: labelStyle),
                            heightSpacer(6),
                            CustomTextField(
                              controller: _passwordController,
                              inputHint: 'Create a strong password',
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
                                  color: mutedTextColor,
                                ),
                              ),
                            ),
                            heightSpacer(16),
                            CustomButton(
                              buttonText: state.isLoading
                                  ? 'Preparing'
                                  : 'Create Admin',
                              onTap: _bootstrap,
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
