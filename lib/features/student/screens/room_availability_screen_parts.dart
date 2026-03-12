part of 'room_availability_screen.dart';

class _RoomAvailabilityScreenState extends State<RoomAvailabilityScreen> {
  final GlobalKey<FormState> _blockFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _roomFormKey = GlobalKey<FormState>();
  final TextEditingController _blockCodeController = TextEditingController();
  final TextEditingController _blockNameController = TextEditingController();
  final TextEditingController _roomNumberController = TextEditingController();
  final TextEditingController _roomCapacityController =
      TextEditingController(text: '2');
  final Map<String, GlobalKey> _roomCardKeys = <String, GlobalKey>{};

  String? _selectedBlock;
  String? _roomBlockCode;
  String? _highlightedRoomId;
  String _selectedRoomType = _roomTypes[1];
  bool _showOnlyAvailable = false;
  bool _requestedInitialRefresh = false;
  bool _autoScrolledToHighlight = false;

  @override
  void initState() {
    super.initState();
    final RoomAvailabilityRouteArgs? routeArgs = widget.routeArgs;
    _selectedBlock = routeArgs?.blockCode;
    _highlightedRoomId = routeArgs?.roomId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requestedInitialRefresh) {
      return;
    }
    _requestedInitialRefresh = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final AppState state = context.read<AppState>();
      if (state.blocks.isEmpty ||
          state.rooms.isEmpty ||
          state.lastError != null) {
        _refreshInventory(showErrorFeedback: false);
      }
    });
  }

  @override
  void dispose() {
    _blockCodeController.dispose();
    _blockNameController.dispose();
    _roomNumberController.dispose();
    _roomCapacityController.dispose();
    super.dispose();
  }

  GlobalKey _roomCardKeyFor(String roomId) {
    return _roomCardKeys.putIfAbsent(roomId, GlobalKey.new);
  }

  void _focusHighlightedRoom(List<HostelRoom> rooms) {
    final String? roomId = _highlightedRoomId;
    if (_autoScrolledToHighlight || roomId == null) {
      return;
    }
    if (!rooms.any((HostelRoom room) => room.id == roomId)) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final BuildContext? roomContext = _roomCardKeys[roomId]?.currentContext;
      if (roomContext == null) {
        return;
      }
      Scrollable.ensureVisible(
        roomContext,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      );
      _autoScrolledToHighlight = true;
    });
  }

  Future<void> _createBlock() async {
    if (!_blockFormKey.currentState!.validate()) {
      return;
    }

    try {
      await context.read<AppState>().createBlock(
            code: _blockCodeController.text,
            name: _blockNameController.text,
          );
      if (!mounted) {
        return;
      }
      final String code = _blockCodeController.text.trim().toUpperCase();
      _blockFormKey.currentState!.reset();
      _blockCodeController.clear();
      _blockNameController.clear();
      setState(() {
        _roomBlockCode ??= code;
        _selectedBlock ??= code;
      });
      showAppMessage(context, 'Block $code added.');
    } on HostelRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, 'Unable to create the block.', isError: true);
    }
  }

  Future<void> _createRoom() async {
    if (!_roomFormKey.currentState!.validate()) {
      return;
    }
    if (_roomBlockCode == null) {
      showAppMessage(context, 'Select a block for the room.', isError: true);
      return;
    }

    final int? capacity = int.tryParse(_roomCapacityController.text.trim());
    if (capacity == null || capacity < 1) {
      showAppMessage(context, 'Capacity must be a valid positive number.',
          isError: true);
      return;
    }

    try {
      await context.read<AppState>().createRoom(
            block: _roomBlockCode!,
            number: _roomNumberController.text,
            capacity: capacity,
            roomType: _selectedRoomType,
          );
      if (!mounted) {
        return;
      }
      _roomFormKey.currentState!.reset();
      _roomNumberController.clear();
      _roomCapacityController.text = '2';
      setState(() {
        _selectedBlock = _roomBlockCode;
        _selectedRoomType = _roomTypes[1];
      });
      showAppMessage(context, 'Room added to block $_roomBlockCode.');
    } on HostelRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      showAppMessage(context, 'Unable to create the room.', isError: true);
    }
  }

  Future<void> _refreshInventory({
    bool showErrorFeedback = true,
  }) async {
    try {
      await context.read<AppState>().refreshData();
    } on HostelRepositoryException catch (error) {
      if (!mounted || !showErrorFeedback) {
        return;
      }
      showAppMessage(context, error.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final bool canManageInventory =
        state.currentUser?.canManageInventory ?? false;
    final bool canRequestRoomChange =
        state.currentUser?.role.isStudent ?? false;
    final List<HostelBlock> blocks = state.blocks;
    final List<HostelRoom> visibleRooms = state.rooms.where((HostelRoom room) {
      final bool matchesBlock =
          _selectedBlock == null || room.block == _selectedBlock;
      final bool matchesAvailability =
          !_showOnlyAvailable || room.hasAvailability;
      return matchesBlock && matchesAvailability;
    }).toList(growable: false);
    final int totalOpenBeds = state.rooms.fold<int>(
      0,
      (int sum, HostelRoom room) => sum + room.availableBeds,
    );
    String selectedBlockLabel = 'All blocks visible';
    for (final HostelBlock block in blocks) {
      if (block.code == _selectedBlock) {
        selectedBlockLabel = 'Browsing ${block.label}';
        break;
      }
    }

    _roomBlockCode ??= blocks.isNotEmpty ? blocks.first.code : null;
    _focusHighlightedRoom(visibleRooms);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: buildAppBar(
        context,
        canManageInventory ? 'Rooms & Blocks' : 'Room Availability',
      ),
      body: AppScreenBackground(
        child: RefreshIndicator(
          onRefresh: _refreshInventory,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: appPagePadding(context,
                horizontal: 16, top: 10, bottomExtra: 18),
            children: <Widget>[
              AppTopInfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Live inventory overview',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              heightSpacer(6),
                              Text(
                                canManageInventory
                                    ? 'Track blocks, rooms, and open beds in one place while inventory changes sync live.'
                                    : 'Review live capacity before choosing your next room.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.82,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        widthSpacer(10),
                        AppTopInfoStatusChip(
                          label:
                              canManageInventory ? 'Admin mode' : 'Live view',
                          accentColor: AppColors.kGreenColor,
                        ),
                      ],
                    ),
                    heightSpacer(16),
                    LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        final double spacing = 12.w;
                        final int columns =
                            constraints.maxWidth >= 290.w ? 3 : 2;
                        final double tileWidth =
                            (constraints.maxWidth - (spacing * (columns - 1))) /
                                columns;
                        return Wrap(
                          spacing: spacing,
                          runSpacing: 12.h,
                          children: <Widget>[
                            SizedBox(
                              width: tileWidth,
                              child: AppTopInfoStatTile(
                                label: 'Blocks',
                                value: blocks.length.toString(),
                                icon: Icons.apartment_rounded,
                                padding: EdgeInsets.all(14.w),
                                borderRadius: 22,
                                showBorder: true,
                              ),
                            ),
                            SizedBox(
                              width: tileWidth,
                              child: AppTopInfoStatTile(
                                label: 'Rooms',
                                value: state.rooms.length.toString(),
                                icon: Icons.meeting_room_outlined,
                                padding: EdgeInsets.all(14.w),
                                borderRadius: 22,
                                showBorder: true,
                              ),
                            ),
                            SizedBox(
                              width: tileWidth,
                              child: AppTopInfoStatTile(
                                label: 'Open beds',
                                value: totalOpenBeds.toString(),
                                icon: Icons.bed_outlined,
                                padding: EdgeInsets.all(14.w),
                                borderRadius: 22,
                                showBorder: true,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    heightSpacer(14),
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 10.h,
                      children: <Widget>[
                        AppTopInfoIconPill(
                          icon: Icons.sync_rounded,
                          label: canManageInventory
                              ? 'Blocks and rooms update live'
                              : 'Inventory updates live',
                          showBorder: true,
                        ),
                        AppTopInfoIconPill(
                          icon: Icons.travel_explore_rounded,
                          label: selectedBlockLabel,
                          showBorder: true,
                        ),
                      ],
                    ),
                    if (canRequestRoomChange) ...<Widget>[
                      heightSpacer(16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(AppRoutes.roomChangeRequests);
                          },
                          icon: const Icon(Icons.swap_horiz_rounded),
                          label: const Text('Open room requests'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              heightSpacer(10),
              if (canManageInventory)
                _AdminInventoryComposer(
                  blockFormKey: _blockFormKey,
                  roomFormKey: _roomFormKey,
                  blocks: blocks,
                  blockCodeController: _blockCodeController,
                  blockNameController: _blockNameController,
                  roomNumberController: _roomNumberController,
                  roomCapacityController: _roomCapacityController,
                  selectedRoomType: _selectedRoomType,
                  roomBlockCode: _roomBlockCode,
                  onRoomTypeChanged: (String? value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _selectedRoomType = value;
                    });
                  },
                  onRoomBlockChanged: (String? value) {
                    setState(() {
                      _roomBlockCode = value;
                    });
                  },
                  onCreateBlock: _createBlock,
                  onCreateRoom: _createRoom,
                ),
              if (blocks.isNotEmpty) ...<Widget>[
                AppSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Browse inventory',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      heightSpacer(6),
                      Text(
                        'Filter by block or focus on rooms with beds available.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.mutedTextFor(
                                Theme.of(context).brightness,
                              ),
                            ),
                      ),
                      heightSpacer(12),
                      Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children: <Widget>[
                          ChoiceChip(
                            label: const Text('All Blocks'),
                            selected: _selectedBlock == null,
                            onSelected: (_) {
                              setState(() {
                                _selectedBlock = null;
                              });
                            },
                          ),
                          ...blocks.map(
                            (HostelBlock block) => ChoiceChip(
                              label: Text(block.label),
                              selected: _selectedBlock == block.code,
                              onSelected: (_) {
                                setState(() {
                                  _selectedBlock = block.code;
                                });
                              },
                            ),
                          ),
                          FilterChip(
                            label: const Text('Only available'),
                            selected: _showOnlyAvailable,
                            onSelected: (bool value) {
                              setState(() {
                                _showOnlyAvailable = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              if (state.rooms.isEmpty && blocks.isEmpty)
                AppSectionCard(
                  child: AppEmptyState(
                    icon: Icons.meeting_room_outlined,
                    title: state.lastError == null
                        ? 'No rooms found'
                        : 'Unable to load inventory',
                    message: state.lastError ??
                        (canManageInventory
                            ? 'Create the first block and room inventory below.'
                            : 'Hostel rooms will appear here once inventory is available.'),
                  ),
                )
              else if (visibleRooms.isEmpty)
                const AppSectionCard(
                  child: AppEmptyState(
                    icon: Icons.search_off_outlined,
                    title: 'No matching rooms',
                    message:
                        'Try another block or disable the availability filter.',
                  ),
                )
              else
                ...visibleRooms.map(
                  (HostelRoom room) => KeyedSubtree(
                    key: _roomCardKeyFor(room.id),
                    child: _RoomInventoryCard(
                      room: room,
                      highlighted: room.id == _highlightedRoomId,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
