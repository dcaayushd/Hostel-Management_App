part of 'laundry_screen.dart';

class _LaundryScreenState extends State<LaundryScreen> {
  static const List<String> _slotOptions = <String>[
    '07:00 - 08:00',
    '08:00 - 09:00',
    '17:00 - 18:00',
    '18:00 - 19:00',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedSlot = _slotOptions.first;
  String? _selectedMachine;

  @override
  void dispose() {
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 14)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.kGreenColor,
                ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (!mounted || picked == null) {
      return;
    }
    setState(() {
      _selectedDate = picked;
      _dateController.text = _formatDate(picked);
    });
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final DateTime? selectedDate = _selectedDate;
    if (selectedDate == null) {
      showAppMessage(context, 'Select a laundry date.', isError: true);
      return;
    }
    final String? selectedMachine = _selectedMachine;
    if (selectedMachine == null || selectedMachine.trim().isEmpty) {
      showAppMessage(context, 'Select a laundry machine.', isError: true);
      return;
    }
    try {
      final DateTime scheduledAt = _scheduledAtFor(
        selectedDate,
        _selectedSlot,
      );
      await context.read<AppState>().createLaundryBooking(
            scheduledAt: scheduledAt,
            slotLabel: _selectedSlot,
            machineLabel: selectedMachine,
            notes: _notesController.text,
          );
      if (!mounted) {
        return;
      }
      _dateController.clear();
      _notesController.clear();
      setState(() {
        _selectedDate = null;
        _selectedSlot = _slotOptions.first;
        _selectedMachine = null;
      });
      showAppMessage(context, 'Laundry slot booked.');
    } on HostelRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, 'Unable to book laundry slot.', isError: true);
    }
  }

  Future<void> _updateStatus(
    String bookingId,
    LaundryBookingStatus status,
  ) async {
    try {
      await context.read<AppState>().updateLaundryBookingStatus(
            bookingId: bookingId,
            status: status,
          );
      if (!mounted) {
        return;
      }
      showAppMessage(
        context,
        'Laundry booking ${status.label.toLowerCase()}.',
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
      showAppMessage(context, 'Unable to update laundry booking.',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final AppUser? user = state.currentUser;
    final Brightness brightness = Theme.of(context).brightness;
    final Color primaryText = AppColors.primaryTextFor(brightness);
    if (user?.role.isGuest ?? false) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: buildAppBar(context, 'Laundry'),
        body: const AppEmptyState(
          icon: Icons.lock_outline,
          title: 'Access restricted',
          message:
              'Laundry booking is available only for resident and staff accounts.',
        ),
      );
    }
    if (!(user?.role.isStudent ?? false) &&
        !(user?.canManageLaundry ?? false)) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: buildAppBar(context, 'Laundry'),
        body: const AppEmptyState(
          icon: Icons.lock_outline,
          title: 'Access restricted',
          message:
              'Only students, wardens, and admin accounts can access laundry operations.',
        ),
      );
    }
    final bool canManageLaundry = user?.canManageLaundry ?? false;
    final List<String> machineOptions = state.adminCatalog.laundryMachines;
    if (_selectedMachine == null && machineOptions.isNotEmpty) {
      _selectedMachine = machineOptions.first;
    } else if (_selectedMachine != null &&
        !machineOptions.contains(_selectedMachine)) {
      _selectedMachine = machineOptions.isEmpty ? null : machineOptions.first;
    }
    final List<LaundryBooking> bookings = state.visibleLaundryBookings;
    final int activeCount =
        bookings.where((LaundryBooking booking) => booking.isActive).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: buildAppBar(context, 'Laundry'),
      body: AppScreenBackground(
        child: ListView(
          padding:
              appPagePadding(context, horizontal: 14, top: 8, bottomExtra: 18),
          children: <Widget>[
            AppFeatureBanner(
              title: canManageLaundry ? 'Laundry queue' : 'Book a washing slot',
              description: canManageLaundry
                  ? 'Track today\'s machine usage and close completed bookings.'
                  : 'Reserve a machine, track bookings, and avoid slot clashes.',
              icon: Icons.local_laundry_service_outlined,
              accentColor: AppColors.kTopInfoAccentColor,
              statusLabel: '$activeCount active',
            ),
            heightSpacer(10),
            if (!(user?.role.isStudent ?? false))
              AppSectionCard(
                child: Row(
                  children: <Widget>[
                    _SummaryPill(
                      label: 'Bookings',
                      value: bookings.length.toString(),
                    ),
                    widthSpacer(8),
                    _SummaryPill(
                      label: 'Active',
                      value: activeCount.toString(),
                    ),
                  ],
                ),
              ),
            if (user?.role.isStudent ?? false)
              AppSectionCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Book Slot',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: primaryText,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      heightSpacer(10),
                      CustomTextField(
                        controller: _dateController,
                        inputHint: 'Laundry date',
                        readOnly: true,
                        onTap: _pickDate,
                        suffixIcon: const Icon(Icons.calendar_today_outlined),
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Select a date';
                          }
                          return null;
                        },
                      ),
                      heightSpacer(6),
                      AppDropdownField<String>(
                        initialValue: _selectedMachine,
                        items: machineOptions
                            .map(
                              (String machine) => DropdownMenuItem<String>(
                                value: machine,
                                child: Text(machine),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (String? value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedMachine = value;
                          });
                        },
                      ),
                      heightSpacer(6),
                      AppDropdownField<String>(
                        initialValue: _selectedSlot,
                        items: _slotOptions
                            .map(
                              (String slot) => DropdownMenuItem<String>(
                                value: slot,
                                child: Text(slot),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (String? value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedSlot = value;
                          });
                        },
                      ),
                      heightSpacer(6),
                      CustomTextField(
                        controller: _notesController,
                        inputHint: 'Notes',
                        maxLines: 3,
                        minLines: 3,
                        inputCapitalization: TextCapitalization.sentences,
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Add a short note';
                          }
                          return null;
                        },
                      ),
                      heightSpacer(8),
                      CustomButton(
                        buttonText: 'Book Laundry Slot',
                        onTap: _submitBooking,
                      ),
                    ],
                  ),
                ),
              ),
            if (bookings.isEmpty)
              const AppSectionCard(
                child: AppEmptyState(
                  icon: Icons.local_laundry_service_outlined,
                  title: 'No bookings',
                  message: 'Laundry reservations will appear here.',
                ),
              )
            else
              ...bookings.map(
                (LaundryBooking booking) => AppSectionCard(
                  margin: EdgeInsets.only(bottom: 10.h),
                  child: _LaundryBookingCard(
                    booking: booking,
                    resident: state.findUser(booking.userId),
                    canManage: canManageLaundry,
                    onComplete: canManageLaundry &&
                            booking.status == LaundryBookingStatus.scheduled
                        ? () => _updateStatus(
                              booking.id,
                              LaundryBookingStatus.completed,
                            )
                        : null,
                    onCancel: booking.status == LaundryBookingStatus.scheduled
                        ? () => _updateStatus(
                              booking.id,
                              LaundryBookingStatus.cancelled,
                            )
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final String day = value.day.toString().padLeft(2, '0');
    final String month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  DateTime _scheduledAtFor(DateTime date, String slotLabel) {
    final List<String> parts = slotLabel.split(' - ');
    final List<String> timeParts = parts.first.split(':');
    final int hour = int.parse(timeParts[0]);
    final int minute = int.parse(timeParts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}
