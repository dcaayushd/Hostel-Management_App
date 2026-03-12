part of 'chat_screen.dart';

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();
  String? _selectedPartnerId;
  String? _lastMarkedPartnerId;
  bool _didApplyRouteSelection = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate() || _selectedPartnerId == null) {
      return;
    }
    try {
      await context.read<AppState>().sendChatMessage(
            recipientId: _selectedPartnerId!,
            message: _messageController.text,
          );
      if (!mounted) {
        return;
      }
      _messageController.clear();
    } on HostelRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    }
  }

  String _partnerLabel(AppUser user, bool isResident) {
    final String secondary =
        isResident ? (user.jobTitle ?? user.accessLabel) : user.accessLabel;
    return '${user.fullName} • $secondary';
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final AppUser? currentUser = state.currentUser;
    final Brightness brightness = Theme.of(context).brightness;
    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    final bool isResident =
        currentUser.role.isStudent || currentUser.role.isGuest;
    final List<AppUser> recipients = isResident
        ? state.staffMembers
        : <AppUser>[...state.students, ...state.guests];
    final String? requestedPartnerId = widget.routeArgs?.partnerId;
    if (!_didApplyRouteSelection &&
        requestedPartnerId != null &&
        recipients.any((AppUser user) => user.id == requestedPartnerId)) {
      _selectedPartnerId = requestedPartnerId;
      _didApplyRouteSelection = true;
    }
    if (_selectedPartnerId == null && recipients.isNotEmpty) {
      _selectedPartnerId = recipients.first.id;
    }
    if (_selectedPartnerId != null &&
        !recipients.any((AppUser user) => user.id == _selectedPartnerId)) {
      _selectedPartnerId = recipients.isEmpty ? null : recipients.first.id;
    }

    final List<ChatMessage> thread =
        state.chatMessages.where((ChatMessage item) {
      if (_selectedPartnerId == null) {
        return false;
      }
      final bool matchesCurrent =
          item.senderId == currentUser.id || item.recipientId == currentUser.id;
      final bool matchesPartner = item.senderId == _selectedPartnerId ||
          item.recipientId == _selectedPartnerId;
      return matchesCurrent && matchesPartner;
    }).toList(growable: false);

    if (_selectedPartnerId != null &&
        _lastMarkedPartnerId != _selectedPartnerId) {
      _lastMarkedPartnerId = _selectedPartnerId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AppState>().markChatThreadRead(_selectedPartnerId!);
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: buildAppBar(
        context,
        isResident ? 'Chat With Staff' : 'Resident Chat',
      ),
      body: AppScreenBackground(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Conversation',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    heightSpacer(10),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPartnerId,
                      isExpanded: true,
                      items: recipients
                          .map(
                            (AppUser user) => DropdownMenuItem<String>(
                              value: user.id,
                              child: Text(
                                _partnerLabel(user, isResident),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(growable: false),
                      selectedItemBuilder: (BuildContext context) {
                        return recipients
                            .map(
                              (AppUser user) => Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _partnerLabel(user, isResident),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(growable: false);
                      },
                      onChanged: (String? value) {
                        setState(() {
                          _selectedPartnerId = value;
                          _lastMarkedPartnerId = null;
                          _didApplyRouteSelection = true;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Select conversation',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: recipients.isEmpty
                  ? const Center(
                      child: AppEmptyState(
                        icon: AppIcons.chat,
                        title: 'No chat contacts',
                        message: 'Available conversations will appear here.',
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
                      itemCount: thread.length,
                      separatorBuilder: (_, __) => heightSpacer(8),
                      itemBuilder: (BuildContext context, int index) {
                        final ChatMessage item = thread[index];
                        final bool isMine = item.senderId == currentUser.id;
                        final AppUser? sender = state.findUser(item.senderId);
                        return Align(
                          alignment: isMine
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 280.w),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: isMine
                                    ? AppColors.kGreenColor
                                    : AppColors.surfaceColor(brightness),
                                borderRadius: BorderRadius.circular(18.r),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: brightness == Brightness.dark
                                        ? const Color(0x22000000)
                                        : const Color(0x10173C32),
                                    blurRadius: 10,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 10.h,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      sender?.fullName ?? 'Unknown',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: isMine
                                                ? Colors.white70
                                                : AppColors.mutedTextFor(
                                                    brightness,
                                                  ),
                                          ),
                                    ),
                                    heightSpacer(4),
                                    Text(
                                      item.message,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: isMine
                                                ? Colors.white
                                                : AppColors.primaryTextFor(
                                                    brightness,
                                                  ),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                16.w,
                0,
                16.w,
                MediaQuery.of(context).padding.bottom + 16.h,
              ),
              child: AppSectionCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      CustomTextField(
                        controller: _messageController,
                        inputHint: 'Type a message',
                        validator: (String? value) =>
                            AppValidators.requiredField(value, 'Message'),
                        maxLines: 3,
                      ),
                      heightSpacer(12),
                      CustomButton(
                        buttonText: 'Send',
                        onTap: recipients.isEmpty ? null : _sendMessage,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
