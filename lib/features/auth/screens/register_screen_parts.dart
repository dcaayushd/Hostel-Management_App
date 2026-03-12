part of 'register_screen.dart';

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedBlock;
  String? _selectedRoomId;
  UserRole _selectedRole = UserRole.student;
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

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedRole.isStudent && _selectedRoomId == null) {
      showAppMessage(context, 'Select an available room.', isError: true);
      return;
    }

    try {
      if (_selectedRole.isStudent) {
        await context.read<AppState>().registerStudent(
              username: _usernameController.text,
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              email: _emailController.text,
              password: _passwordController.text,
              phoneNumber: _phoneController.text,
              roomId: _selectedRoomId!,
            );
      } else {
        await context.read<AppState>().registerGuest(
              username: _usernameController.text,
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              email: _emailController.text,
              password: _passwordController.text,
              phoneNumber: _phoneController.text,
            );
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.root,
        (Route<dynamic> route) => false,
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
        'Something went wrong while creating the account.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final Brightness brightness = Theme.of(context).brightness;
    final Color primaryTextColor = AppColors.primaryTextFor(brightness);
    final Color mutedTextColor = AppColors.mutedTextFor(brightness);
    final List<HostelBlock> blocks = _uniqueBlocks(state.blocks);
    final TextStyle? labelStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: primaryTextColor,
              fontWeight: FontWeight.w700,
            );
    final String? selectedBlock = blocks.any(
      (HostelBlock block) => block.code == _selectedBlock,
    )
        ? _selectedBlock
        : null;
    final List<HostelRoom> availableRooms = _uniqueRooms(
      state.availableRoomsFor(
        block: selectedBlock,
      ),
    );
    final String? selectedRoomId = availableRooms.any(
      (HostelRoom room) => room.id == _selectedRoomId,
    )
        ? _selectedRoomId
        : null;
    final String blockDropdownIdentity =
        blocks.map((HostelBlock block) => block.code).join('|');
    final String roomDropdownIdentity =
        availableRooms.map((HostelRoom room) => room.id).join('|');
    if (selectedBlock != _selectedBlock || selectedRoomId != _selectedRoomId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _selectedBlock = selectedBlock;
          _selectedRoomId = selectedRoomId;
        });
      });
    }

    return Scaffold(
      appBar: buildAppBar(context, 'Create Account'),
      body: AppScreenBackground(
        child: state.rooms.isEmpty && state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
                              'Personal details',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            heightSpacer(6),
                            Text(
                              'You will verify the email after account creation.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: mutedTextColor),
                            ),
                            heightSpacer(16),
                            Text('Account type', style: labelStyle),
                            heightSpacer(10),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: <UserRole>[
                                UserRole.student,
                                UserRole.guest,
                              ].map((UserRole role) {
                                final bool selected = _selectedRole == role;
                                final String detail = role.isStudent
                                    ? 'Hostel resident'
                                    : 'Visitor access';
                                return ChoiceChip(
                                  label: Text('${role.label} • $detail'),
                                  selected: selected,
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedRole = role;
                                      if (!role.isStudent) {
                                        _selectedBlock = null;
                                        _selectedRoomId = null;
                                      }
                                    });
                                  },
                                );
                              }).toList(growable: false),
                            ),
                            heightSpacer(20),
                            Text('Username', style: labelStyle),
                            heightSpacer(10),
                            CustomTextField(
                              controller: _usernameController,
                              inputHint: 'Choose a username',
                              validator: (String? value) =>
                                  AppValidators.requiredField(
                                      value, 'Username'),
                            ),
                            heightSpacer(14),
                            Text('First name', style: labelStyle),
                            heightSpacer(10),
                            CustomTextField(
                              controller: _firstNameController,
                              inputHint: 'Enter your first name',
                              validator: (String? value) =>
                                  AppValidators.requiredField(
                                      value, 'First name'),
                              inputCapitalization: TextCapitalization.words,
                            ),
                            heightSpacer(14),
                            Text('Last name', style: labelStyle),
                            heightSpacer(10),
                            CustomTextField(
                              controller: _lastNameController,
                              inputHint: 'Enter your last name',
                              validator: (String? value) =>
                                  AppValidators.requiredField(
                                      value, 'Last name'),
                              inputCapitalization: TextCapitalization.words,
                            ),
                            heightSpacer(14),
                            Text('Email', style: labelStyle),
                            heightSpacer(10),
                            CustomTextField(
                              controller: _emailController,
                              inputHint: 'name@example.com',
                              inputKeyBoardType: TextInputType.emailAddress,
                              validator: AppValidators.email,
                            ),
                            heightSpacer(14),
                            Text('Password', style: labelStyle),
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
                            Text('Phone number', style: labelStyle),
                            heightSpacer(10),
                            CustomTextField(
                              controller: _phoneController,
                              inputHint: '98XXXXXXXX',
                              inputKeyBoardType: TextInputType.phone,
                              validator: AppValidators.phoneNumber,
                              maxLength: 10,
                            ),
                            if (_selectedRole.isStudent) ...<Widget>[
                              heightSpacer(18),
                              Text(
                                'Room assignment',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              heightSpacer(20),
                              Text('Block', style: labelStyle),
                              heightSpacer(10),
                              _PickerField<String>(
                                key: ValueKey<String>(
                                  'block:$blockDropdownIdentity:${selectedBlock ?? 'none'}',
                                ),
                                value: selectedBlock,
                                displayText: selectedBlock == null
                                    ? null
                                    : blocks
                                        .firstWhere(
                                          (HostelBlock block) =>
                                              block.code == selectedBlock,
                                        )
                                        .label,
                                hintText: 'Select a hostel block',
                                validator: (_) => AppValidators.requiredField(
                                  selectedBlock,
                                  'Block',
                                ),
                                onPick: () {
                                  return _showPickerSheet(
                                    context,
                                    title: 'Select Block',
                                    options: blocks
                                        .map(
                                          (HostelBlock block) =>
                                              _PickerOption<String>(
                                            value: block.code,
                                            title: block.label,
                                            subtitle: block.description,
                                          ),
                                        )
                                        .toList(growable: false),
                                  );
                                },
                                onChanged: (String? value) {
                                  if (value == null) {
                                    return;
                                  }
                                  setState(() {
                                    _selectedBlock = value;
                                    final List<HostelRoom> roomsForBlock =
                                        _uniqueRooms(
                                      state.availableRoomsFor(block: value),
                                    );
                                    final bool stillValid = roomsForBlock.any(
                                      (HostelRoom room) =>
                                          room.id == _selectedRoomId,
                                    );
                                    if (!stillValid) {
                                      _selectedRoomId = null;
                                    }
                                  });
                                },
                              ),
                              heightSpacer(14),
                              Text('Room', style: labelStyle),
                              heightSpacer(10),
                              _PickerField<String>(
                                key: ValueKey<String>(
                                  'room:${selectedBlock ?? 'all'}:$roomDropdownIdentity:${selectedRoomId ?? 'none'}',
                                ),
                                value: selectedRoomId,
                                enabled: availableRooms.isNotEmpty,
                                displayText: selectedRoomId == null
                                    ? null
                                    : availableRooms
                                        .firstWhere(
                                          (HostelRoom room) =>
                                              room.id == selectedRoomId,
                                        )
                                        .label,
                                hintText: availableRooms.isEmpty
                                    ? 'No rooms available in this block'
                                    : 'Choose an available room',
                                validator: (_) => AppValidators.requiredField(
                                  selectedRoomId,
                                  'Room',
                                ),
                                onPick: availableRooms.isEmpty
                                    ? null
                                    : () {
                                        return _showPickerSheet(
                                          context,
                                          title: 'Select Room',
                                          options: availableRooms
                                              .map(
                                                (HostelRoom room) =>
                                                    _PickerOption<String>(
                                                  value: room.id,
                                                  title: room.label,
                                                  subtitle:
                                                      '${room.availableBeds} bed(s) left • ${room.roomType}',
                                                ),
                                              )
                                              .toList(growable: false),
                                        );
                                      },
                                onChanged: (String? value) {
                                  if (value == null) {
                                    return;
                                  }
                                  setState(() {
                                    _selectedRoomId = value;
                                  });
                                },
                              ),
                              if (_selectedBlock != null &&
                                  availableRooms.isEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 10.h),
                                  child: Text(
                                    'No rooms with free capacity are available in this block.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: mutedTextColor),
                                  ),
                                )
                              else
                                Padding(
                                  padding: EdgeInsets.only(top: 10.h),
                                  child: Text(
                                    'Only rooms with open beds are listed here.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: mutedTextColor),
                                  ),
                                ),
                            ] else
                              Padding(
                                padding: EdgeInsets.only(top: 6.h),
                                child: Text(
                                  'Guest accounts are created without room assignment.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: mutedTextColor),
                                ),
                              ),
                            heightSpacer(24),
                            CustomButton(
                              buttonText: 'Register',
                              onTap: _register,
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

  List<HostelBlock> _uniqueBlocks(Iterable<HostelBlock> blocks) {
    final Set<String> seenCodes = <String>{};
    final List<HostelBlock> uniqueBlocks = <HostelBlock>[];
    for (final HostelBlock block in blocks) {
      if (seenCodes.add(block.code)) {
        uniqueBlocks.add(block);
      }
    }
    return uniqueBlocks;
  }

  List<HostelRoom> _uniqueRooms(Iterable<HostelRoom> rooms) {
    final Set<String> seenIds = <String>{};
    final List<HostelRoom> uniqueRooms = <HostelRoom>[];
    for (final HostelRoom room in rooms) {
      if (seenIds.add(room.id)) {
        uniqueRooms.add(room);
      }
    }
    return uniqueRooms;
  }
}

Future<T?> _showPickerSheet<T>(
  BuildContext context, {
  required String title,
  required List<_PickerOption<T>> options,
}) {
  final Brightness brightness = Theme.of(context).brightness;
  final Color surfaceColor = AppColors.surfaceColor(brightness);
  final Color borderColor = AppColors.borderFor(brightness);
  final Color primaryTextColor = AppColors.primaryTextFor(brightness);
  final Color mutedTextColor = AppColors.mutedTextFor(brightness);
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 18.h),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 42.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
              heightSpacer(14),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: primaryTextColor,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              heightSpacer(12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: options.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: borderColor.withValues(alpha: 0.75),
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final _PickerOption<T> option = options[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        option.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: primaryTextColor,
                            ),
                      ),
                      subtitle: option.subtitle == null
                          ? null
                          : Text(
                              option.subtitle!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: mutedTextColor,
                                  ),
                            ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: mutedTextColor,
                      ),
                      onTap: () {
                        Navigator.of(context).pop(option.value);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _PickerOption<T> {
  const _PickerOption({
    required this.value,
    required this.title,
    this.subtitle,
  });

  final T value;
  final String title;
  final String? subtitle;
}
