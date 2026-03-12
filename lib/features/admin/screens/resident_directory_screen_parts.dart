part of 'resident_directory_screen.dart';

class _RoomAssignmentSheetState extends State<_RoomAssignmentSheet> {
  String? _selectedBlock;
  String? _selectedRoomId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final AppState state = context.read<AppState>();
    final HostelRoom? currentRoom = widget.resident.roomId == null
        ? null
        : state.findRoom(widget.resident.roomId!);
    _selectedBlock = currentRoom?.block ??
        (state.blocks.isNotEmpty ? state.blocks.first.code : null);
    final List<HostelRoom> rooms = _roomOptions(state);
    if (widget.resident.roomId != null &&
        rooms.any((HostelRoom room) => room.id == widget.resident.roomId)) {
      _selectedRoomId = widget.resident.roomId;
    } else if (rooms.isNotEmpty) {
      _selectedRoomId = rooms.first.id;
    }
  }

  List<HostelRoom> _roomOptions(AppState state) {
    return state.availableRoomsFor(
      block: _selectedBlock,
      includeRoomId: widget.resident.roomId,
    );
  }

  Future<void> _saveAssignment(
    AppState state,
    HostelRoom selectedRoom,
  ) async {
    setState(() {
      _isSaving = true;
    });

    try {
      await state.assignResidentRoom(
        userId: widget.resident.id,
        roomId: selectedRoom.id,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(selectedRoom.label);
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
        'Unable to update the room assignment.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final Brightness brightness = Theme.of(context).brightness;
    final List<HostelRoom> availableRooms = _roomOptions(state);
    final HostelRoom? currentRoom = widget.resident.roomId == null
        ? null
        : state.findRoom(widget.resident.roomId!);
    final String? resolvedRoomId = availableRooms.any(
      (HostelRoom room) => room.id == _selectedRoomId,
    )
        ? _selectedRoomId
        : (widget.resident.roomId != null &&
                availableRooms.any(
                  (HostelRoom room) => room.id == widget.resident.roomId,
                )
            ? widget.resident.roomId
            : (availableRooms.isNotEmpty ? availableRooms.first.id : null));
    final HostelRoom? selectedRoom = resolvedRoomId == null
        ? null
        : availableRooms
            .firstWhere((HostelRoom room) => room.id == resolvedRoomId);
    final bool canSubmit = !_isSaving &&
        selectedRoom != null &&
        selectedRoom.id != widget.resident.roomId;
    final Future<void> Function()? onSubmit;
    if (canSubmit) {
      onSubmit = () => _saveAssignment(state, selectedRoom);
    } else {
      onSubmit = null;
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            18.w,
            14.h,
            18.w,
            20.h + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(brightness),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            border: Border.all(color: AppColors.borderFor(brightness)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 44.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: AppColors.outlineFor(brightness),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
              heightSpacer(16),
              Text(
                'Assign room',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              heightSpacer(6),
              Text(
                widget.resident.fullName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.kSecondaryColor,
                    ),
              ),
              heightSpacer(4),
              Text(
                currentRoom == null
                    ? 'No current room assignment'
                    : 'Current room: ${currentRoom.label}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              heightSpacer(18),
              if (state.blocks.isEmpty)
                const AppEmptyState(
                  icon: Icons.apartment_outlined,
                  title: 'No blocks available',
                  message: 'Create a block and room inventory first.',
                )
              else ...<Widget>[
                Text(
                  'Block',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                heightSpacer(8),
                AppDropdownField<String>(
                  key: ValueKey<String?>('block-$_selectedBlock'),
                  initialValue: _selectedBlock,
                  items: state.blocks
                      .map(
                        (HostelBlock block) => DropdownMenuItem<String>(
                          value: block.code,
                          child: Text(block.label),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: _isSaving
                      ? null
                      : (String? value) {
                          final List<HostelRoom> nextRooms =
                              state.availableRoomsFor(
                            block: value,
                            includeRoomId: widget.resident.roomId,
                          );
                          setState(() {
                            _selectedBlock = value;
                            if (widget.resident.roomId != null &&
                                nextRooms.any((HostelRoom room) =>
                                    room.id == widget.resident.roomId)) {
                              _selectedRoomId = widget.resident.roomId;
                            } else {
                              _selectedRoomId =
                                  nextRooms.isEmpty ? null : nextRooms.first.id;
                            }
                          });
                        },
                  hintText: 'Select a block',
                ),
                heightSpacer(14),
                Text(
                  'Room',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                heightSpacer(8),
                if (availableRooms.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: AppColors.tonalSurfaceFor(brightness),
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: AppColors.outlineFor(brightness),
                      ),
                    ),
                    child: Text(
                      'No available rooms found in this block.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                else
                  AppDropdownField<String>(
                    key: ValueKey<String?>(
                      'room-${_selectedBlock ?? 'all'}-$resolvedRoomId',
                    ),
                    initialValue: resolvedRoomId,
                    items: availableRooms
                        .map(
                          (HostelRoom room) => DropdownMenuItem<String>(
                            value: room.id,
                            child: Text(
                              '${room.label} • ${room.availableBeds} bed(s) open',
                            ),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: _isSaving
                        ? null
                        : (String? value) {
                            setState(() {
                              _selectedRoomId = value;
                            });
                          },
                    hintText: 'Select a room',
                  ),
                if (selectedRoom != null) ...<Widget>[
                  heightSpacer(14),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: AppColors.tonalSurfaceFor(brightness),
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: AppColors.outlineFor(brightness),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          selectedRoom.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        heightSpacer(4),
                        Text(
                          '${selectedRoom.roomType} • ${selectedRoom.occupiedBeds}/${selectedRoom.capacity} occupied',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
                heightSpacer(18),
                CustomButton(
                  buttonText:
                      currentRoom == null ? 'Assign Room' : 'Update Room',
                  isLoading: _isSaving,
                  onTap: onSubmit,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
