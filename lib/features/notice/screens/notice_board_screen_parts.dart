part of 'notice_board_screen.dart';

class _NoticeBoardScreenState extends State<NoticeBoardScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String? _selectedFilter;
  String? _selectedCategory;
  bool _isPinned = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _publishNotice() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final String? category = _selectedCategory;
    if (category == null || category.trim().isEmpty) {
      showAppMessage(context, 'Select a notice category.', isError: true);
      return;
    }
    final NoticeProvider noticeProvider = context.read<NoticeProvider>();
    final AppState appState = context.read<AppState>();

    try {
      await noticeProvider.createNotice(
        title: _titleController.text,
        message: _messageController.text,
        category: category,
        isPinned: _isPinned,
      );
      if (!mounted) {
        return;
      }
      await appState.refreshActivityFeed();
      if (!mounted) {
        return;
      }
      _titleController.clear();
      _messageController.clear();
      setState(() {
        _selectedCategory = null;
        _isPinned = false;
      });
      showAppMessage(context, 'Notice published.');
    } on HostelRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, 'Unable to publish notice.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final NoticeProvider noticeProvider = context.watch<NoticeProvider>();
    final Brightness brightness = Theme.of(context).brightness;
    final Color primaryText = AppColors.primaryTextFor(brightness);
    final Color mutedText = AppColors.mutedTextFor(brightness);
    final bool canManageNotices = state.currentUser?.canManageNotices ?? false;
    final List<NoticeItem> allNotices = noticeProvider.notices;
    final String? noticeError = noticeProvider.lastFailure?.message;
    final List<String> categories = state.adminCatalog.noticeCategories.isEmpty
        ? allNotices
            .map((NoticeItem item) => item.category)
            .where((String value) => value.trim().isNotEmpty)
            .toSet()
            .toList(growable: false)
        : state.adminCatalog.noticeCategories;
    if (_selectedCategory == null && categories.isNotEmpty) {
      _selectedCategory = categories.first;
    } else if (_selectedCategory != null &&
        !categories.contains(_selectedCategory)) {
      _selectedCategory = categories.isEmpty ? null : categories.first;
    }
    final List<NoticeItem> notices = allNotices
        .where(
          (NoticeItem notice) =>
              _selectedFilter == null || notice.category == _selectedFilter,
        )
        .toList(growable: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: buildAppBar(context, 'Notice Board'),
      body: AppScreenBackground(
        child: RefreshIndicator(
          onRefresh: () => context.read<NoticeProvider>().loadNotices(),
          child: ListView(
            padding: appPagePadding(context,
                horizontal: 14, top: 8, bottomExtra: 18),
            children: <Widget>[
              AppTopInfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Hostel updates',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              heightSpacer(4),
                              Text(
                                'Announcements, event alerts, and important rules.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.78),
                                      height: 1.45,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (canManageNotices)
                          const AppTopInfoStatusChip(label: 'Admin'),
                      ],
                    ),
                    heightSpacer(12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          _FilterChip(
                            label: 'All',
                            selected: _selectedFilter == null,
                            onTap: () {
                              setState(() {
                                _selectedFilter = null;
                              });
                            },
                          ),
                          ...categories.map(
                            (String category) => Padding(
                              padding: EdgeInsets.only(left: 8.w),
                              child: _FilterChip(
                                label: normalizeNoticeCategoryLabel(category),
                                selected: _selectedFilter == category,
                                onTap: () {
                                  setState(() {
                                    _selectedFilter = category;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              heightSpacer(10),
              if (canManageNotices)
                AppSectionCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Post Notice',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: primaryText,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        if (state
                            .adminCatalog.alertPresets.isNotEmpty) ...<Widget>[
                          heightSpacer(10),
                          Text(
                            'Quick alerts',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: mutedText,
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                          heightSpacer(8),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: state.adminCatalog.alertPresets
                                .map(
                                  (AdminAlertPreset preset) => ActionChip(
                                    label: Text(preset.title),
                                    onPressed: () {
                                      setState(() {
                                        _titleController.text = preset.title;
                                        _messageController.text =
                                            preset.message;
                                        if (categories
                                            .contains(preset.category)) {
                                          _selectedCategory = preset.category;
                                        }
                                      });
                                    },
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        ],
                        heightSpacer(12),
                        CustomTextField(
                          controller: _titleController,
                          inputHint: 'Title',
                          validator: (String? value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Title is required';
                            }
                            return null;
                          },
                        ),
                        heightSpacer(6),
                        CustomTextField(
                          controller: _messageController,
                          inputHint: 'Write the notice',
                          maxLines: 4,
                          minLines: 4,
                          inputCapitalization: TextCapitalization.sentences,
                          validator: (String? value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Message is required';
                            }
                            return null;
                          },
                        ),
                        heightSpacer(10),
                        AppDropdownField<String>(
                          initialValue: _selectedCategory,
                          items: categories
                              .map(
                                (String category) => DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(
                                    normalizeNoticeCategoryLabel(category),
                                  ),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (String? value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                        ),
                        heightSpacer(10),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.softSurfaceFor(brightness),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: AppColors.borderFor(brightness),
                            ),
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Pin notice',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: primaryText,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    Text(
                                      'Pinned notices stay above all other updates.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: mutedText,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: _isPinned,
                                activeTrackColor: AppColors.kGreenColor
                                    .withValues(alpha: 0.45),
                                activeThumbColor: AppColors.kGreenColor,
                                onChanged: (bool value) {
                                  setState(() {
                                    _isPinned = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        heightSpacer(12),
                        CustomButton(
                          buttonText: 'Publish Notice',
                          onTap: _publishNotice,
                        ),
                      ],
                    ),
                  ),
                ),
              if (noticeProvider.isLoading && notices.isEmpty)
                const AppSectionCard(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              else if (notices.isEmpty)
                AppSectionCard(
                  child: AppEmptyState(
                    icon: AppIcons.notice,
                    title: noticeError == null
                        ? 'No notices found'
                        : 'Unable to load notices',
                    message: noticeError ??
                        'Updates will appear here once something is posted.',
                  ),
                )
              else
                ...notices.map(
                  (NoticeItem notice) => _NoticeCard(notice: notice),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
