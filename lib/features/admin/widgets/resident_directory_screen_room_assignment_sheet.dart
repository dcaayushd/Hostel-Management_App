part of '../screens/resident_directory_screen.dart';

class _RoomAssignmentSheet extends StatefulWidget {
  const _RoomAssignmentSheet({
    required this.resident,
  });

  final AppUser resident;

  @override
  State<_RoomAssignmentSheet> createState() => _RoomAssignmentSheetState();
}
