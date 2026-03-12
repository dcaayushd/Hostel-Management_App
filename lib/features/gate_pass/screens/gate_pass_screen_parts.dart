part of 'gate_pass_screen.dart';

class _GatePassScreenState extends State<GatePassScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passCodeController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _emergencyController = TextEditingController();
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _returnController = TextEditingController();

  DateTime? _departureAt;
  DateTime? _expectedReturnAt;

  @override
  void dispose() {
    _passCodeController.dispose();
    _destinationController.dispose();
    _reasonController.dispose();
    _emergencyController.dispose();
    _departureController.dispose();
    _returnController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({
    required bool isReturn,
  }) async {
    final DateTime initial = isReturn
        ? (_expectedReturnAt ?? _departureAt ?? DateTime.now())
        : (_departureAt ?? DateTime.now());
    final DateTime firstDate = DateTime.now().subtract(const Duration(days: 1));
    final DateTime lastDate = DateTime.now().add(const Duration(days: 30));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
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
    if (!mounted || pickedDate == null) {
      return;
    }

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (!mounted || pickedTime == null) {
      return;
    }

    final DateTime resolved = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      if (isReturn) {
        _expectedReturnAt = resolved;
        _returnController.text = _formatDateTime(resolved);
      } else {
        _departureAt = resolved;
        _departureController.text = _formatDateTime(resolved);
        if (_expectedReturnAt != null &&
            !_expectedReturnAt!.isAfter(_departureAt!)) {
          _expectedReturnAt = null;
          _returnController.clear();
        }
      }
    });
  }

  Future<void> _submitGatePass() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final DateTime? departureAt = _departureAt;
    final DateTime? expectedReturnAt = _expectedReturnAt;
    if (departureAt == null || expectedReturnAt == null) {
      showAppMessage(context, 'Select both departure and return times.',
          isError: true);
      return;
    }
    if (!expectedReturnAt.isAfter(departureAt)) {
      showAppMessage(context, 'Return time must be after departure time.',
          isError: true);
      return;
    }
    try {
      await context.read<AppState>().createGatePass(
            destination: _destinationController.text,
            reason: _reasonController.text,
            emergencyContact: _emergencyController.text,
            departureAt: departureAt,
            expectedReturnAt: expectedReturnAt,
          );
      if (!mounted) {
        return;
      }
      _destinationController.clear();
      _reasonController.clear();
      _emergencyController.clear();
      _departureController.clear();
      _returnController.clear();
      setState(() {
        _departureAt = null;
        _expectedReturnAt = null;
      });
      showAppMessage(context, 'Gate pass request submitted.');
    } on HostelRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, 'Unable to submit gate pass.', isError: true);
    }
  }

  Future<void> _reviewPass(
    String gatePassId,
    GatePassStatus status,
  ) async {
    try {
      await context.read<AppState>().reviewGatePass(
            gatePassId: gatePassId,
            status: status,
          );
      if (!mounted) {
        return;
      }
      showAppMessage(context, 'Gate pass ${status.label.toLowerCase()}.');
    } on HostelRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, 'Unable to review gate pass.', isError: true);
    }
  }

  Future<void> _markDeparture(String gatePassId) async {
    try {
      await context.read<AppState>().markGatePassDeparture(gatePassId);
      if (!mounted) {
        return;
      }
      showAppMessage(context, 'Resident checked out.');
    } on HostelRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, 'Unable to mark checkout.', isError: true);
    }
  }

  Future<void> _markReturn(String gatePassId) async {
    try {
      await context.read<AppState>().markGatePassReturn(gatePassId);
      if (!mounted) {
        return;
      }
      showAppMessage(context, 'Resident marked as returned.');
    } on HostelRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, 'Unable to mark return.', isError: true);
    }
  }

  GatePassRequest? _findPassByCode(
    List<GatePassRequest> passes,
    String rawInput,
  ) {
    final String value = rawInput.trim();
    if (value.isEmpty) {
      return null;
    }
    final List<String> parts = value.split(':');
    final String passCode =
        parts.length >= 2 && parts.first == 'HOSTEL' ? parts[1] : value;
    for (final GatePassRequest item in passes) {
      if (item.passCode.toLowerCase() == passCode.toLowerCase()) {
        return item;
      }
    }
    return null;
  }

  Future<void> _processDeskCode(AppState state) async {
    final GatePassRequest? gatePass = _findPassByCode(
      state.visibleGatePasses,
      _passCodeController.text,
    );
    if (gatePass == null) {
      showAppMessage(context, 'Pass code not found.', isError: true);
      return;
    }

    if (gatePass.canCheckOut) {
      await _markDeparture(gatePass.id);
      if (mounted) {
        _passCodeController.clear();
      }
      return;
    }
    if (gatePass.canMarkReturned || gatePass.isLateNow) {
      await _markReturn(gatePass.id);
      if (mounted) {
        _passCodeController.clear();
      }
      return;
    }
    if (gatePass.status.isPending) {
      showAppMessage(
        context,
        'Pass is still pending approval.',
        isError: true,
      );
      return;
    }
    if (gatePass.status.isRejected) {
      showAppMessage(
        context,
        'Rejected passes cannot be processed.',
        isError: true,
      );
      return;
    }
    showAppMessage(
      context,
      'This pass is already closed.',
      isError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final AppUser? user = state.currentUser;
    if (user == null) {
      return const Scaffold(body: SizedBox.shrink());
    }
    if (user.role.isGuest) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: buildAppBar(context, 'Gate Pass'),
        body: const AppEmptyState(
          icon: Icons.lock_outline,
          title: 'Access restricted',
          message:
              'Gate pass requests are available only for resident accounts.',
        ),
      );
    }

    final bool canManage = user.canManageGatePass;
    final GatePassScreenFilter? activeFilter =
        canManage ? widget.routeArgs?.filter : null;
    final List<GatePassRequest> passes = state.visibleGatePasses;
    final List<GatePassRequest> filteredPasses = switch (activeFilter) {
      GatePassScreenFilter.pendingOnly => passes
          .where((GatePassRequest item) => item.status.isPending)
          .toList(growable: false),
      GatePassScreenFilter.activeOnly => passes
          .where(
            (GatePassRequest item) => item.canMarkReturned || item.isLateNow,
          )
          .toList(growable: false),
      null => passes,
    };
    final String queueTitle = switch (activeFilter) {
      GatePassScreenFilter.pendingOnly => 'Students in gate queue',
      GatePassScreenFilter.activeOnly => 'Residents currently out',
      null => 'Gate pass queue',
    };
    final String queueDescription = switch (activeFilter) {
      GatePassScreenFilter.pendingOnly =>
        'Pending gate-pass requests waiting for review.',
      GatePassScreenFilter.activeOnly =>
        'Checked-out and late residents who still need to be marked as returned.',
      null => 'Approvals, departures, returns, and late entries.',
    };
    final GatePassRequest activePass = passes.firstWhere(
      (GatePassRequest item) =>
          item.status == GatePassStatus.approved ||
          item.status == GatePassStatus.checkedOut ||
          item.status == GatePassStatus.late,
      orElse: () => _emptyGatePass,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: buildAppBar(
        context,
        switch (activeFilter) {
          GatePassScreenFilter.pendingOnly => 'Gate Queue',
          GatePassScreenFilter.activeOnly => 'Active Gate Passes',
          null => 'Gate Pass',
        },
      ),
      body: AppScreenBackground(
        child: ListView(
          padding:
              appPagePadding(context, horizontal: 14, top: 8, bottomExtra: 18),
          children: canManage
              ? activeFilter != null
                  ? <Widget>[
                      _GatePassListSection(
                        title: queueTitle,
                        description: queueDescription,
                        passes: filteredPasses,
                        state: state,
                        showResident: true,
                        onApprove: (String gatePassId) {
                          _reviewPass(gatePassId, GatePassStatus.approved);
                        },
                        onReject: (String gatePassId) {
                          _reviewPass(gatePassId, GatePassStatus.rejected);
                        },
                        onCheckOut: _markDeparture,
                        onReturn: _markReturn,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed(AppRoutes.gatePass);
                          },
                          icon: const Icon(Icons.view_list_rounded),
                          label: const Text('View full queue'),
                        ),
                      ),
                    ]
                  : <Widget>[
                      _GatePassSummary(
                        title: 'Security desk',
                        firstLabel: 'Pending',
                        firstValue: state.pendingGatePassCount.toString(),
                        secondLabel: 'Late',
                        secondValue: state.activeLateEntryCount.toString(),
                      ),
                      heightSpacer(12),
                      _GateReminderSection(
                        passes: passes,
                        state: state,
                      ),
                      heightSpacer(12),
                      _GateDeskProcessor(
                        controller: _passCodeController,
                        onProcess: () => _processDeskCode(state),
                      ),
                      heightSpacer(12),
                      _GatePassListSection(
                        title: queueTitle,
                        description: queueDescription,
                        passes: filteredPasses,
                        state: state,
                        showResident: true,
                        onApprove: (String gatePassId) {
                          _reviewPass(gatePassId, GatePassStatus.approved);
                        },
                        onReject: (String gatePassId) {
                          _reviewPass(gatePassId, GatePassStatus.rejected);
                        },
                        onCheckOut: _markDeparture,
                        onReturn: _markReturn,
                      ),
                      heightSpacer(12),
                      _GateMovementSection(
                        passes: passes,
                        state: state,
                      ),
                    ]
              : <Widget>[
                  _GatePassSummary(
                    title: 'Leave pass',
                    firstLabel: 'Pending',
                    firstValue: state.pendingGatePassCount.toString(),
                    secondLabel: 'Late',
                    secondValue: state.activeLateEntryCount.toString(),
                  ),
                  if (activePass.id.isNotEmpty) ...<Widget>[
                    heightSpacer(12),
                    _DigitalPassCard(pass: activePass),
                  ],
                  heightSpacer(12),
                  AppSectionCard(
                    padding: EdgeInsets.all(12.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Request gate pass',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppColors.primaryTextFor(
                                    Theme.of(context).brightness,
                                  ),
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          heightSpacer(10),
                          CustomTextField(
                            controller: _destinationController,
                            inputHint: 'Destination',
                            validator: _requiredField,
                          ),
                          CustomTextField(
                            controller: _reasonController,
                            inputHint: 'Reason',
                            maxLines: 3,
                            minLines: 3,
                            inputCapitalization: TextCapitalization.sentences,
                            validator: _requiredField,
                          ),
                          CustomTextField(
                            controller: _emergencyController,
                            inputHint: 'Emergency contact',
                            inputKeyBoardType: TextInputType.phone,
                            validator: _requiredField,
                          ),
                          CustomTextField(
                            controller: _departureController,
                            inputHint: 'Departure time',
                            readOnly: true,
                            onTap: () {
                              _pickDateTime(isReturn: false);
                            },
                            validator: _requiredField,
                          ),
                          CustomTextField(
                            controller: _returnController,
                            inputHint: 'Expected return time',
                            readOnly: true,
                            onTap: () {
                              _pickDateTime(isReturn: true);
                            },
                            validator: _requiredField,
                          ),
                          heightSpacer(6),
                          CustomButton(
                            buttonText: 'Submit Gate Pass',
                            onTap: _submitGatePass,
                          ),
                        ],
                      ),
                    ),
                  ),
                  heightSpacer(12),
                  _GatePassListSection(
                    title: 'My requests',
                    description:
                        'Approvals, departures, returns, and late entries.',
                    passes: passes,
                    state: state,
                  ),
                ],
        ),
      ),
    );
  }
}
