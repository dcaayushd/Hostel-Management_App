part of 'room_change_request_screen.dart';

class _RoomChangeRequestScreenState extends State<RoomChangeRequestScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();

  String? _selectedBlock;
  String? _selectedRoomId;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedRoomId == null) {
      showAppMessage(context, 'Select a destination room.', isError: true);
      return;
    }

    try {
      await context.read<AppState>().createRoomChangeRequest(
            desiredRoomId: _selectedRoomId!,
            reason: _reasonController.text,
          );
      if (!mounted) {
        return;
      }
      _reasonController.clear();
      setState(() {
        _selectedBlock = null;
        _selectedRoomId = null;
      });
      showAppMessage(context, 'Room change request submitted.');
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
        'Something went wrong while sending the request.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final AppUser? user = state.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: buildAppBar(
        context,
        user.canManageRoomRequests
            ? 'Room Change Requests'
            : 'My Room Requests',
      ),
      body: AppScreenBackground(
        child: user.canManageRoomRequests
            ? _AdminRoomRequestView(
                state: state,
                routeArgs: widget.routeArgs,
              )
            : _StudentRoomRequestView(
                formKey: _formKey,
                reasonController: _reasonController,
                selectedBlock: _selectedBlock,
                selectedRoomId: _selectedRoomId,
                onBlockChanged: (String? value) {
                  setState(() {
                    _selectedBlock = value;
                    final List<HostelRoom> rooms = state
                        .availableRoomsFor(block: value)
                        .where(
                          (HostelRoom room) => room.id != state.currentRoom?.id,
                        )
                        .toList(growable: false);
                    final bool validSelection = rooms.any(
                      (HostelRoom room) => room.id == _selectedRoomId,
                    );
                    if (!validSelection) {
                      _selectedRoomId = null;
                    }
                  });
                },
                onRoomChanged: (String? value) {
                  setState(() {
                    _selectedRoomId = value;
                  });
                },
                onSubmit: _submitRequest,
              ),
      ),
    );
  }
}
