part of '../screens/room_change_request_screen.dart';

class _StudentRoomRequestView extends StatelessWidget {
  const _StudentRoomRequestView({
    required this.formKey,
    required this.reasonController,
    required this.selectedBlock,
    required this.selectedRoomId,
    required this.onBlockChanged,
    required this.onRoomChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController reasonController;
  final String? selectedBlock;
  final String? selectedRoomId;
  final ValueChanged<String?> onBlockChanged;
  final ValueChanged<String?> onRoomChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final AppUser user = state.currentUser!;
    final HostelRoom? currentRoom = state.currentRoom;
    final List<HostelBlock> blocks = state.blocks
        .where(
          (HostelBlock block) =>
              state.availableRoomsFor(block: block.code).isNotEmpty,
        )
        .toList(growable: false);
    final List<HostelRoom> destinationRooms = state
        .availableRoomsFor(block: selectedBlock)
        .where((HostelRoom room) => room.id != currentRoom?.id)
        .toList(growable: false);
    final bool hasPendingRequest = state.visibleRoomRequests.any(
      (RoomChangeRequest request) => request.status.isPending,
    );

    if (currentRoom == null) {
      return const AppEmptyState(
        icon: Icons.swap_horiz_outlined,
        title: 'No room assigned',
        message: 'A room assignment is required before you can request a move.',
      );
    }

    return ListView(
      padding:
          appPagePadding(context, horizontal: 18, top: 12, bottomExtra: 18),
      children: <Widget>[
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Current assignment',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              heightSpacer(16),
              _DetailRow(label: 'Resident', value: user.fullName),
              _DetailRow(label: 'Room', value: currentRoom.label),
              _DetailRow(label: 'Type', value: currentRoom.roomType),
              _DetailRow(
                label: 'Occupancy',
                value: '${currentRoom.occupiedBeds}/${currentRoom.capacity}',
              ),
            ],
          ),
        ),
        AppSectionCard(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Request a room change',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                heightSpacer(8),
                Text(
                  hasPendingRequest
                      ? 'You already have a pending request. Resolve it before sending another one.'
                      : 'Choose a different room with available capacity and explain why you need the move.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                heightSpacer(18),
                Text('Block', style: AppTextTheme.kLabelStyle),
                heightSpacer(10),
                AppDropdownField<String>(
                  initialValue: selectedBlock,
                  items: blocks
                      .map(
                        (HostelBlock block) => DropdownMenuItem<String>(
                          value: block.code,
                          child: Text(block.label),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: hasPendingRequest ? null : onBlockChanged,
                  hintText: 'Select a destination block',
                  validator: (String? value) =>
                      AppValidators.requiredField(value, 'Block'),
                ),
                heightSpacer(14),
                Text('Destination room', style: AppTextTheme.kLabelStyle),
                heightSpacer(10),
                AppDropdownField<String>(
                  initialValue: selectedRoomId,
                  items: destinationRooms
                      .map(
                        (HostelRoom room) => DropdownMenuItem<String>(
                          value: room.id,
                          child: Text(
                            '${room.label} • ${room.availableBeds} bed(s) left',
                          ),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: hasPendingRequest ? null : onRoomChanged,
                  hintText: 'Select the room you want',
                  validator: (String? value) =>
                      AppValidators.requiredField(value, 'Destination room'),
                ),
                heightSpacer(14),
                Text('Reason', style: AppTextTheme.kLabelStyle),
                heightSpacer(10),
                CustomTextField(
                  controller: reasonController,
                  inputHint: 'Explain why the room change is required.',
                  validator: (String? value) =>
                      AppValidators.requiredField(value, 'Reason'),
                  minLines: 4,
                  maxLines: 5,
                  readOnly: hasPendingRequest,
                  inputCapitalization: TextCapitalization.sentences,
                ),
                heightSpacer(24),
                CustomButton(
                  buttonText: 'Submit Request',
                  onTap: hasPendingRequest ? null : onSubmit,
                ),
              ],
            ),
          ),
        ),
        Text(
          'Request history',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        heightSpacer(12),
        if (state.visibleRoomRequests.isEmpty)
          const AppSectionCard(
            child: AppEmptyState(
              icon: Icons.swap_calls_outlined,
              title: 'No room requests yet',
              message:
                  'When you request a room change, the status timeline will appear here.',
            ),
          )
        else
          ...state.visibleRoomRequests.map(
            (RoomChangeRequest request) => _RoomRequestCard(request: request),
          ),
      ],
    );
  }
}
