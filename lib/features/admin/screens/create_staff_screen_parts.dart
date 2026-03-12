part of 'create_staff_screen.dart';

class _CreateStaffScreenState extends State<CreateStaffScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _jobTitleController.dispose();
    super.dispose();
  }

  Future<void> _createStaff() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await context.read<AppState>().createStaff(
            username: _usernameController.text,
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            phoneNumber: _phoneController.text,
            jobTitle: _jobTitleController.text,
          );
      if (!mounted) {
        return;
      }
      showAppMessage(context, 'Staff account created successfully.');
      Navigator.of(context).pop();
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
        'Something went wrong while creating the staff account.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final bool canManageStaff = state.currentUser?.canManageStaff ?? false;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: buildAppBar(context, 'Create Staff'),
      body: AppScreenBackground(
        child: canManageStaff
            ? SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 24.h),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 560.w),
                    child: AppSectionCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Create a new staff login',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            heightSpacer(18),
                            Text('Username', style: AppTextTheme.kLabelStyle),
                            heightSpacer(10),
                            CustomTextField(
                              controller: _usernameController,
                              inputHint: 'Choose a username',
                              validator: (String? value) =>
                                  AppValidators.requiredField(
                                      value, 'Username'),
                            ),
                            heightSpacer(14),
                            Text('First name', style: AppTextTheme.kLabelStyle),
                            heightSpacer(10),
                            CustomTextField(
                              controller: _firstNameController,
                              inputHint: 'Enter first name',
                              validator: (String? value) =>
                                  AppValidators.requiredField(
                                      value, 'First name'),
                              inputCapitalization: TextCapitalization.words,
                            ),
                            heightSpacer(14),
                            Text('Last name', style: AppTextTheme.kLabelStyle),
                            heightSpacer(10),
                            CustomTextField(
                              controller: _lastNameController,
                              inputHint: 'Enter last name',
                              validator: (String? value) =>
                                  AppValidators.requiredField(
                                      value, 'Last name'),
                              inputCapitalization: TextCapitalization.words,
                            ),
                            heightSpacer(14),
                            Text('Job title', style: AppTextTheme.kLabelStyle),
                            heightSpacer(10),
                            CustomTextField(
                              controller: _jobTitleController,
                              inputHint: 'Hostel Warden, Reception Lead, etc.',
                              validator: (String? value) =>
                                  AppValidators.requiredField(
                                      value, 'Job title'),
                              inputCapitalization: TextCapitalization.words,
                            ),
                            heightSpacer(14),
                            Text('Email', style: AppTextTheme.kLabelStyle),
                            heightSpacer(10),
                            CustomTextField(
                              controller: _emailController,
                              inputHint: 'staff@hostelhub.edu',
                              validator: AppValidators.email,
                              inputKeyBoardType: TextInputType.emailAddress,
                            ),
                            heightSpacer(14),
                            Text('Password', style: AppTextTheme.kLabelStyle),
                            heightSpacer(10),
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
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            heightSpacer(14),
                            Text('Phone number',
                                style: AppTextTheme.kLabelStyle),
                            heightSpacer(10),
                            CustomTextField(
                              controller: _phoneController,
                              inputHint: '98XXXXXXXX',
                              validator: AppValidators.phoneNumber,
                              inputKeyBoardType: TextInputType.phone,
                              maxLength: 10,
                            ),
                            heightSpacer(24),
                            CustomButton(
                              buttonText: 'Create Staff',
                              onTap: _createStaff,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : const AppEmptyState(
                icon: Icons.lock_outline,
                title: 'Access restricted',
                message: 'Only admin accounts can create staff users.',
              ),
      ),
    );
  }
}
