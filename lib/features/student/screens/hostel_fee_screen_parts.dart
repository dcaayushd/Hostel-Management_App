part of 'hostel_fee_screen.dart';

class _HostelFeeScreenState extends State<HostelFeeScreen> {
  static const String _electricityChargeLabel = 'Electricity';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _electricityController = TextEditingController();
  final TextEditingController _waterController = TextEditingController();

  final TextEditingController _maintenanceController = TextEditingController();
  final TextEditingController _parkingController = TextEditingController();
  final TextEditingController _singleController = TextEditingController();
  final TextEditingController _doubleController = TextEditingController();
  final TextEditingController _tripleController = TextEditingController();
  List<FeeChargeItem> _customCharges = <FeeChargeItem>[];

  FeeSettings? _syncedSettings;

  @override
  void dispose() {
    _electricityController.dispose();
    _maintenanceController.dispose();
    _parkingController.dispose();
    _waterController.dispose();
    _singleController.dispose();
    _doubleController.dispose();
    _tripleController.dispose();
    super.dispose();
  }

  void _syncControllers(FeeSettings? settings) {
    if (settings == null || _matchesSyncedSettings(settings)) {
      return;
    }
    _electricityController.text =
        _electricityAmountFor(settings.customCharges).toString();
    _maintenanceController.text = settings.maintenanceCharge.toString();
    _parkingController.text = settings.parkingCharge.toString();
    _waterController.text = settings.waterCharge.toString();
    _singleController.text = settings.singleOccupancyCharge.toString();
    _doubleController.text = settings.doubleSharingCharge.toString();
    _tripleController.text = settings.tripleSharingCharge.toString();
    _customCharges = _customChargesWithoutElectricity(settings.customCharges);
    _syncedSettings = settings;
  }

  bool _matchesSyncedSettings(FeeSettings settings) {
    final FeeSettings? synced = _syncedSettings;
    if (synced == null) {
      return false;
    }
    return synced.maintenanceCharge == settings.maintenanceCharge &&
        synced.parkingCharge == settings.parkingCharge &&
        synced.waterCharge == settings.waterCharge &&
        synced.singleOccupancyCharge == settings.singleOccupancyCharge &&
        synced.doubleSharingCharge == settings.doubleSharingCharge &&
        synced.tripleSharingCharge == settings.tripleSharingCharge &&
        _sameCustomCharges(synced.customCharges, settings.customCharges);
  }

  bool _sameCustomCharges(
    List<FeeChargeItem> a,
    List<FeeChargeItem> b,
  ) {
    if (a.length != b.length) {
      return false;
    }
    for (int index = 0; index < a.length; index += 1) {
      if (a[index].label != b[index].label ||
          a[index].amount != b[index].amount) {
        return false;
      }
    }
    return true;
  }

  bool _isElectricityChargeLabel(String label) {
    return label.trim().toLowerCase() == _electricityChargeLabel.toLowerCase();
  }

  bool _isElectricityCharge(FeeChargeItem item) {
    return _isElectricityChargeLabel(item.label);
  }

  int _electricityAmountFor(Iterable<FeeChargeItem> charges) {
    for (final FeeChargeItem item in charges) {
      if (_isElectricityCharge(item)) {
        return item.amount;
      }
    }
    return 0;
  }

  List<FeeChargeItem> _customChargesWithoutElectricity(
    Iterable<FeeChargeItem> charges,
  ) {
    return charges
        .where((FeeChargeItem item) => !_isElectricityCharge(item))
        .map(
          (FeeChargeItem item) => FeeChargeItem(
            label: item.label,
            amount: item.amount,
          ),
        )
        .toList(growable: false);
  }

  Future<void> _addOrEditCustomCharge({
    FeeChargeItem? existing,
    int? index,
  }) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController labelController = TextEditingController(
      text: existing?.label ?? '',
    );
    final TextEditingController amountController = TextEditingController(
      text: existing?.amount.toString() ?? '',
    );

    final FeeChargeItem? result = await showModalBottomSheet<FeeChargeItem>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 14.w,
            right: 14.w,
            top: 24.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 14.h,
          ),
          child: Material(
            color: _surfaceColor(context),
            borderRadius: BorderRadius.circular(26.r),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      existing == null
                          ? 'Add fee category'
                          : 'Edit fee category',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _primaryTextColor(context),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    heightSpacer(12),
                    CustomTextField(
                      controller: labelController,
                      inputHint: 'Category label',
                      validator: (String? value) =>
                          AppValidators.requiredField(value, 'Category label'),
                    ),
                    CustomTextField(
                      controller: amountController,
                      inputHint: 'Amount',
                      inputKeyBoardType: TextInputType.number,
                      validator: (String? value) =>
                          AppValidators.requiredField(value, 'Amount'),
                    ),
                    heightSpacer(8),
                    CustomButton(
                      buttonText:
                          existing == null ? 'Add Category' : 'Save Category',
                      onTap: () {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }
                        final int? amount =
                            int.tryParse(amountController.text.trim());
                        if (amount == null || amount < 0) {
                          showAppMessage(
                            context,
                            'Enter a valid amount greater than or equal to zero.',
                            isError: true,
                          );
                          return;
                        }
                        final String label = labelController.text.trim();
                        if (_isElectricityChargeLabel(label)) {
                          showAppMessage(
                            context,
                            'Electricity is managed from the field above.',
                            isError: true,
                          );
                          return;
                        }
                        Navigator.of(context).pop(
                          FeeChargeItem(
                            label: label,
                            amount: amount,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    labelController.dispose();
    amountController.dispose();

    if (!mounted || result == null) {
      return;
    }
    setState(() {
      final List<FeeChargeItem> next = List<FeeChargeItem>.from(_customCharges);
      if (index == null) {
        next.add(result);
      } else {
        next[index] = result;
      }
      _customCharges = next;
    });
  }

  void _removeCustomCharge(int index) {
    setState(() {
      final List<FeeChargeItem> next = List<FeeChargeItem>.from(_customCharges);
      next.removeAt(index);
      _customCharges = next;
    });
  }

  Future<void> _saveFeeSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final List<int?> values = <int?>[
      int.tryParse(_electricityController.text.trim()),
      int.tryParse(_maintenanceController.text.trim()),
      int.tryParse(_parkingController.text.trim()),
      int.tryParse(_waterController.text.trim()),
      int.tryParse(_singleController.text.trim()),
      int.tryParse(_doubleController.text.trim()),
      int.tryParse(_tripleController.text.trim()),
    ];
    if (values.any((int? value) => value == null || value < 0)) {
      showAppMessage(
        context,
        'All fee values must be valid numbers greater than or equal to zero.',
        isError: true,
      );
      return;
    }

    final List<FeeChargeItem> customCharges = <FeeChargeItem>[
      FeeChargeItem(
        label: _electricityChargeLabel,
        amount: values[0]!,
      ),
      ..._customCharges.where(
        (FeeChargeItem item) => !_isElectricityCharge(item),
      ),
    ];

    try {
      await context.read<AppState>().updateFeeSettings(
            maintenanceCharge: values[1]!,
            parkingCharge: values[2]!,
            waterCharge: values[3]!,
            singleOccupancyCharge: values[4]!,
            doubleSharingCharge: values[5]!,
            tripleSharingCharge: values[6]!,
            customCharges: customCharges,
          );
      if (!mounted) {
        return;
      }
      showAppMessage(context, 'Fee settings updated.');
    } on HostelRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, 'Unable to update fee settings.', isError: true);
    }
  }

  Future<void> _payFee(PaymentMethod method) async {
    final AppState appState = context.read<AppState>();
    final FeeSummary? summary = appState.currentFeeSummary;
    final AppUser? user = appState.currentUser;
    if (summary == null || user == null) {
      showAppMessage(context, 'Fee summary is unavailable.', isError: true);
      return;
    }
    final bool shouldContinue = await _reviewPayment(
      residentName: user.fullName,
      billingMonth: summary.billingMonth,
      amount: summary.balance,
      method: method,
      roomLabel: appState.currentRoom?.label,
    );
    if (!shouldContinue) {
      return;
    }

    try {
      final PaymentRecord? payment = await _runWithProcessing<PaymentRecord?>(
        method: method,
        action: () => appState.payCurrentFee(method: method),
      );
      if (!mounted || payment == null) {
        return;
      }
      showAppMessage(
        context,
        'Payment verified. Receipt ${payment.receiptId} generated.',
      );
      _showReceipt(payment);
    } on HostelRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, 'Unable to process the payment.', isError: true);
    }
  }

  Future<void> _collectFeeForResident(String userId) async {
    final AppState appState = context.read<AppState>();
    final PaymentMethod? method = await _chooseCollectionMethod();
    if (!mounted || method == null) {
      return;
    }
    final AppUser? resident = appState.findUser(userId);
    final FeeSummary? summary = appState.feeSummaryFor(userId);
    if (resident == null || summary == null) {
      showAppMessage(context, 'Resident fee summary is unavailable.',
          isError: true);
      return;
    }
    final bool shouldContinue = await _reviewPayment(
      residentName: resident.fullName,
      billingMonth: summary.billingMonth,
      amount: summary.balance,
      method: method,
      roomLabel: appState.findRoom(resident.roomId ?? '')?.label,
      isCollection: true,
    );
    if (!shouldContinue) {
      return;
    }
    try {
      final PaymentRecord? payment = await _runWithProcessing<PaymentRecord?>(
        method: method,
        isCollection: true,
        action: () => appState.collectFeeForResident(
          userId: userId,
          method: method,
        ),
      );
      if (!mounted || payment == null) {
        return;
      }
      showAppMessage(
        context,
        'Collection verified. Receipt ${payment.receiptId} generated.',
      );
      _showReceipt(payment);
    } on HostelRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, 'Unable to collect the payment.', isError: true);
    }
  }

  Future<bool> _reviewPayment({
    required String residentName,
    required String billingMonth,
    required int amount,
    required PaymentMethod method,
    String? roomLabel,
    bool isCollection = false,
  }) async {
    final String referenceId = _checkoutReference();
    final bool? confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _PaymentReviewSheet(
          residentName: residentName,
          billingMonth: billingMonth,
          amount: amount,
          method: method,
          referenceId: referenceId,
          roomLabel: roomLabel,
          isCollection: isCollection,
        );
      },
    );
    return confirmed ?? false;
  }

  Future<T> _runWithProcessing<T>({
    required PaymentMethod method,
    required Future<T> Function() action,
    bool isCollection = false,
  }) async {
    final NavigatorState navigator = Navigator.of(context, rootNavigator: true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: _PaymentProgressDialog(
            method: method,
            isCollection: isCollection,
          ),
        );
      },
    );
    try {
      await Future<void>.delayed(const Duration(milliseconds: 850));
      return await action();
    } finally {
      if (mounted) {
        navigator.pop();
      }
    }
  }

  Future<void> _sendReminder(String userId) async {
    try {
      final FeeSummary? summary =
          await context.read<AppState>().sendFeeReminder(userId);
      if (!mounted || summary == null) {
        return;
      }
      showAppMessage(
        context,
        'Reminder sent for ${summary.billingMonth}.',
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
      showAppMessage(context, 'Unable to send reminder.', isError: true);
    }
  }

  void _showReceipt(PaymentRecord payment) {
    final AppUser? user = context.read<AppState>().findUser(payment.userId);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _ReceiptSheet(
          payment: payment,
          residentName: user?.fullName ?? 'Resident',
        );
      },
    );
  }

  Future<PaymentMethod?> _chooseCollectionMethod() {
    final List<PaymentMethod> methods = PaymentMethod.values.toList();
    return showModalBottomSheet<PaymentMethod>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: _surfaceColor(context),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 22.h),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Select collection method',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _primaryTextColor(context),
                        fontWeight: FontWeight.w800,
                      ),
                ),
                heightSpacer(12),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: methods
                      .map(
                        (PaymentMethod method) => SizedBox(
                          width: (MediaQuery.of(context).size.width - 48.w) / 2,
                          child: _PaymentMethodTile(
                            method: method,
                            onTap: () {
                              Navigator.of(context).pop(method);
                            },
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _checkoutReference() {
    final int value = DateTime.now().millisecondsSinceEpoch % 1000000;
    return 'HX-${value.toString().padLeft(6, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final bool canManageFeeSettings =
        state.currentUser?.canManageFeeSettings ?? false;
    final bool canCollectFees = state.currentUser?.canCollectFees ?? false;
    final FeeScreenFilter? feeFilter = widget.routeArgs?.filter;
    final bool duesOnly =
        feeFilter == FeeScreenFilter.duesOnly && canCollectFees;
    final List<AppUser> dueStudents = state.students.where((AppUser student) {
      final FeeSummary? summary = state.feeSummaryFor(student.id);
      return summary != null && !summary.isPaid && summary.balance > 0;
    }).toList(growable: false)
      ..sort((AppUser a, AppUser b) {
        final FeeSummary? summaryA = state.feeSummaryFor(a.id);
        final FeeSummary? summaryB = state.feeSummaryFor(b.id);
        final int balanceCompare =
            (summaryB?.balance ?? 0).compareTo(summaryA?.balance ?? 0);
        if (balanceCompare != 0) {
          return balanceCompare;
        }
        return a.fullName.compareTo(b.fullName);
      });
    final List<AppUser> filteredStudents =
        duesOnly ? dueStudents : state.students;
    final String residentListTitle =
        duesOnly ? 'Residents with dues' : 'All resident balances';
    final String residentListDescription = duesOnly
        ? 'Showing only residents with unpaid balances for the current billing cycle. Use View all to inspect paid balances and continue follow-up from chat.'
        : 'Review resident balances, collect payments, and send reminders.';

    _syncControllers(state.feeSettings);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: buildAppBar(
        context,
        duesOnly
            ? 'Fees Due'
            : canManageFeeSettings
                ? 'Fee Control'
                : canCollectFees
                    ? 'Fee Collection'
                    : 'Fees & Payments',
      ),
      body: AppScreenBackground(
        topChromeHeight: 120,
        child: canCollectFees
            ? _AdminFeeView(
                state: state,
                filteredStudents: filteredStudents,
                showOnlyDues: duesOnly,
                residentListTitle: residentListTitle,
                residentListDescription: residentListDescription,
                canEditSettings: canManageFeeSettings,
                formKey: _formKey,
                electricityController: _electricityController,
                waterController: _waterController,
                maintenanceController: _maintenanceController,
                parkingController: _parkingController,
                singleController: _singleController,
                doubleController: _doubleController,
                tripleController: _tripleController,
                customCharges: _customCharges,
                onAddCustomCharge: () => _addOrEditCustomCharge(),
                onEditCustomCharge: (int index) => _addOrEditCustomCharge(
                  existing: _customCharges[index],
                  index: index,
                ),
                onRemoveCustomCharge: _removeCustomCharge,
                onSave: _saveFeeSettings,
                onSendReminder: _sendReminder,
                onCollectFee: _collectFeeForResident,
                onOpenReceipt: _showReceipt,
              )
            : _StudentFeeView(
                state: state,
                onPay: _payFee,
                onOpenReceipt: _showReceipt,
              ),
      ),
    );
  }
}
