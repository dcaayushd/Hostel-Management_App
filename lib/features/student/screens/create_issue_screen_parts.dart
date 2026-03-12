part of 'create_issue_screen.dart';

class _StudentCreateIssueScreenState extends State<StudentCreateIssueScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _commentController = TextEditingController();

  String? _selectedIssue;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitIssue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await context.read<AppState>().createIssue(
            category: _selectedIssue!,
            comment: _commentController.text,
          );
      if (!mounted) {
        return;
      }
      _commentController.clear();
      setState(() {
        _selectedIssue = null;
      });
      showAppMessage(context, 'Issue submitted successfully.');
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
        'Something went wrong while creating the issue.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final user = state.currentUser;
    final room = state.currentRoom;
    final List<String> issueTypes = state.adminCatalog.issueCategories;
    if (_selectedIssue == null && issueTypes.isNotEmpty) {
      _selectedIssue = issueTypes.first;
    } else if (_selectedIssue != null && !issueTypes.contains(_selectedIssue)) {
      _selectedIssue = issueTypes.isEmpty ? null : issueTypes.first;
    }

    if (user == null || !user.role.isStudent) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: buildAppBar(context, 'Issue Center'),
        body: const AppScreenBackground(
          child: AppEmptyState(
            icon: Icons.report_problem_outlined,
            title: 'Issue center unavailable',
            message:
                'Only students with an active room assignment can create issues.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: buildAppBar(context, 'Issue Center'),
      body: AppScreenBackground(
        child: ListView(
          padding:
              appPagePadding(context, horizontal: 18, top: 12, bottomExtra: 18),
          children: <Widget>[
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Resident details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  heightSpacer(16),
                  _InfoRow(label: 'Name', value: user.fullName),
                  _InfoRow(label: 'Room', value: room?.label ?? 'Not assigned'),
                  _InfoRow(label: 'Email', value: user.email),
                  _InfoRow(label: 'Phone', value: user.phoneNumber),
                ],
              ),
            ),
            AppSectionCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Create a new issue',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    heightSpacer(18),
                    Text(
                      'Issue type',
                      style: AppTextTheme.kLabelStyle,
                    ),
                    heightSpacer(10),
                    AppDropdownField<String>(
                      initialValue: _selectedIssue,
                      items: issueTypes
                          .map(
                            (String issue) => DropdownMenuItem<String>(
                              value: issue,
                              child: Text(issue),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedIssue = value;
                        });
                      },
                      hintText: 'Select an issue category',
                      validator: (String? value) =>
                          AppValidators.requiredField(value, 'Issue type'),
                    ),
                    heightSpacer(16),
                    Text(
                      'Description',
                      style: AppTextTheme.kLabelStyle,
                    ),
                    heightSpacer(10),
                    CustomTextField(
                      controller: _commentController,
                      inputHint:
                          'Describe the problem clearly for the hostel team.',
                      validator: (String? value) =>
                          AppValidators.requiredField(value, 'Description'),
                      minLines: 4,
                      maxLines: 5,
                      inputCapitalization: TextCapitalization.sentences,
                    ),
                    heightSpacer(22),
                    CustomButton(
                      buttonText: 'Submit Issue',
                      onTap: _submitIssue,
                    ),
                  ],
                ),
              ),
            ),
            Text(
              'Recent issues',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            heightSpacer(12),
            if (state.visibleIssues.isEmpty)
              const AppSectionCard(
                child: AppEmptyState(
                  icon: Icons.inbox_outlined,
                  title: 'No issues yet',
                  message:
                      'Create your first issue and it will appear here for tracking.',
                ),
              )
            else
              ...state.visibleIssues.map(
                (IssueTicket issue) => AppSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              issue.category,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          StatusChip(
                            label: issue.status.label,
                            color: _issueColor(issue.status),
                          ),
                        ],
                      ),
                      heightSpacer(12),
                      Text(
                        issue.comment,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      heightSpacer(10),
                      Text(
                        AppDateFormatter.short(issue.createdAt),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _issueColor(IssueStatus status) {
    switch (status) {
      case IssueStatus.open:
        return const Color(0xFFB54708);
      case IssueStatus.inProgress:
        return const Color(0xFF155EEF);
      case IssueStatus.resolved:
        return AppColors.kGreenColor;
    }
  }
}
