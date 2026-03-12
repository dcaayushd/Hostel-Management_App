part of 'parcel_desk_screen.dart';

class _ParcelDeskScreenState extends State<ParcelDeskScreen> {
  final GlobalKey<FormState> _parcelFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _visitorFormKey = GlobalKey<FormState>();
  final TextEditingController _carrierController = TextEditingController();
  final TextEditingController _trackingController = TextEditingController();
  final TextEditingController _parcelNoteController = TextEditingController();
  final TextEditingController _visitorNameController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();
  final TextEditingController _visitorNoteController = TextEditingController();

  String? _selectedParcelStudentId;
  String? _selectedVisitorStudentId;

  @override
  void dispose() {
    _carrierController.dispose();
    _trackingController.dispose();
    _parcelNoteController.dispose();
    _visitorNameController.dispose();
    _relationController.dispose();
    _visitorNoteController.dispose();
    super.dispose();
  }

  void _syncStudents(List<AppUser> students) {
    if (students.isEmpty) {
      _selectedParcelStudentId = null;
      _selectedVisitorStudentId = null;
      return;
    }
    _selectedParcelStudentId ??= students.first.id;
    _selectedVisitorStudentId ??= students.first.id;
    if (!students.any((AppUser user) => user.id == _selectedParcelStudentId)) {
      _selectedParcelStudentId = students.first.id;
    }
    if (!students.any((AppUser user) => user.id == _selectedVisitorStudentId)) {
      _selectedVisitorStudentId = students.first.id;
    }
  }

  Future<void> _createParcel() async {
    if (!_parcelFormKey.currentState!.validate()) {
      return;
    }
    final String? studentId = _selectedParcelStudentId;
    if (studentId == null) {
      showAppMessage(context, 'Select a resident.', isError: true);
      return;
    }
    try {
      await context.read<AppState>().createParcel(
            userId: studentId,
            carrier: _carrierController.text,
            trackingCode: _trackingController.text,
            note: _parcelNoteController.text,
          );
      if (!mounted) {
        return;
      }
      _carrierController.clear();
      _trackingController.clear();
      _parcelNoteController.clear();
      showAppMessage(context, 'Parcel recorded.');
    } on HostelRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, 'Unable to record parcel.', isError: true);
    }
  }

  Future<void> _markCollected(String parcelId) async {
    try {
      await context.read<AppState>().markParcelCollected(parcelId);
      if (!mounted) {
        return;
      }
      showAppMessage(context, 'Parcel marked as collected.');
    } on HostelRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, 'Unable to update parcel.', isError: true);
    }
  }

  Future<void> _createVisitorEntry() async {
    if (!_visitorFormKey.currentState!.validate()) {
      return;
    }
    final String? studentId = _selectedVisitorStudentId;
    if (studentId == null) {
      showAppMessage(context, 'Select a resident.', isError: true);
      return;
    }
    try {
      await context.read<AppState>().createVisitorEntry(
            studentId: studentId,
            visitorName: _visitorNameController.text,
            relation: _relationController.text,
            note: _visitorNoteController.text,
          );
      if (!mounted) {
        return;
      }
      _visitorNameController.clear();
      _relationController.clear();
      _visitorNoteController.clear();
      showAppMessage(context, 'Visitor logged.');
    } on HostelRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, 'Unable to log visitor.', isError: true);
    }
  }

  Future<void> _checkOutVisitor(String visitorId) async {
    try {
      await context.read<AppState>().checkOutVisitor(visitorId);
      if (!mounted) {
        return;
      }
      showAppMessage(context, 'Visitor checked out.');
    } on HostelRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, 'Unable to update visitor log.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final AppUser? user = state.currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: SizedBox.shrink(),
      );
    }

    final bool canManage = user.canManageFrontDesk;
    final List<AppUser> students = List<AppUser>.from(state.students)
      ..sort((AppUser a, AppUser b) => a.fullName.compareTo(b.fullName));
    _syncStudents(students);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: buildAppBar(context, canManage ? 'Parcel Desk' : 'Parcels'),
      body: AppScreenBackground(
        child: ListView(
          padding:
              appPagePadding(context, horizontal: 14, top: 8, bottomExtra: 18),
          children: canManage
              ? <Widget>[
                  _DeskSummary(
                    title: 'Front desk',
                    firstLabel: 'Pending parcels',
                    firstValue: state.pendingParcelCount.toString(),
                    secondLabel: 'Active visitors',
                    secondValue: state.activeVisitorCount.toString(),
                  ),
                  heightSpacer(12),
                  _ParcelFormSection(
                    formKey: _parcelFormKey,
                    students: students,
                    carrierOptions: state.adminCatalog.parcelCarriers,
                    selectedStudentId: _selectedParcelStudentId,
                    onStudentChanged: (String? value) {
                      setState(() {
                        _selectedParcelStudentId = value;
                      });
                    },
                    carrierController: _carrierController,
                    trackingController: _trackingController,
                    noteController: _parcelNoteController,
                    onSubmit: _createParcel,
                  ),
                  heightSpacer(12),
                  _VisitorFormSection(
                    formKey: _visitorFormKey,
                    students: students,
                    selectedStudentId: _selectedVisitorStudentId,
                    onStudentChanged: (String? value) {
                      setState(() {
                        _selectedVisitorStudentId = value;
                      });
                    },
                    visitorNameController: _visitorNameController,
                    relationController: _relationController,
                    noteController: _visitorNoteController,
                    onSubmit: _createVisitorEntry,
                  ),
                  heightSpacer(12),
                  _ParcelListSection(
                    title: 'Parcel log',
                    parcels: state.visibleParcels,
                    state: state,
                    onCollect: _markCollected,
                    showResident: true,
                  ),
                  heightSpacer(12),
                  _VisitorListSection(
                    title: 'Visitor log',
                    entries: state.visibleVisitorEntries,
                    state: state,
                    onCheckOut: _checkOutVisitor,
                    showResident: true,
                  ),
                ]
              : <Widget>[
                  _DeskSummary(
                    title: 'Front desk updates',
                    firstLabel: 'Pending parcels',
                    firstValue: state.pendingParcelCount.toString(),
                    secondLabel: 'Visitor entries',
                    secondValue: state.visibleVisitorEntries.length.toString(),
                  ),
                  heightSpacer(12),
                  _ParcelListSection(
                    title: 'My parcels',
                    parcels: state.visibleParcels,
                    state: state,
                    showResident: false,
                  ),
                  heightSpacer(12),
                  _VisitorListSection(
                    title: 'Visitor log',
                    entries: state.visibleVisitorEntries,
                    state: state,
                    showResident: false,
                  ),
                ],
        ),
      ),
    );
  }
}
