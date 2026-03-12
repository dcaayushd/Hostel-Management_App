import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../app/app_chrome.dart';
import '../../../common/app_bar.dart';
import '../../../common/spacing.dart';
import '../../../core/models/app_user.dart';
import '../../../core/models/hostel_block.dart';
import '../../../core/models/hostel_room.dart';
import '../../../core/services/hostel_repository.dart';
import '../../../core/state/app_state.dart';
import '../../../core/utils/feedback.dart';
import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_screen_background.dart';
import '../../../core/widgets/app_section_card.dart';
import '../../../core/widgets/app_top_info_surface.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../features/auth/widgets/custom_button.dart';
import '../../../theme/colors.dart';

part 'resident_directory_screen_parts.dart';
part '../widgets/resident_directory_screen_room_assignment_sheet.dart';
part '../widgets/resident_directory_screen_directory_stat_tile.dart';
part '../widgets/resident_directory_screen_detail_row.dart';

class ResidentDirectoryScreen extends StatelessWidget {
  const ResidentDirectoryScreen({super.key});

  Future<void> _showRoomAssignmentSheet(
    BuildContext context,
    AppUser resident,
  ) async {
    final String? assignedRoomLabel = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return _RoomAssignmentSheet(resident: resident);
      },
    );

    if (!context.mounted || assignedRoomLabel == null) {
      return;
    }
    showAppMessage(
      context,
      '${resident.fullName} is now assigned to $assignedRoomLabel.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    final AppUser? currentUser = state.currentUser;
    final bool canViewResidents = currentUser?.canViewResidents ?? false;

    if (!canViewResidents) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: buildAppBar(context, 'Residents'),
        body: const AppScreenBackground(
          child: AppEmptyState(
            icon: Icons.lock_outline,
            title: 'Access restricted',
            message: 'Only admin and staff accounts can view residents.',
          ),
        ),
      );
    }

    final List<AppUser> residents = state.students;
    if (residents.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: buildAppBar(context, 'Residents'),
        body: const AppScreenBackground(
          child: AppEmptyState(
            icon: Icons.groups_outlined,
            title: 'No residents found',
            message: 'Students will appear here once they are registered.',
          ),
        ),
      );
    }

    final int assignedResidents =
        residents.where((AppUser resident) => resident.roomId != null).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: buildAppBar(context, 'Residents'),
      body: AppScreenBackground(
        child: RefreshIndicator(
          onRefresh: state.refreshData,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: appPagePadding(
              context,
              horizontal: 18,
              top: 12,
              bottomExtra: 18,
            ),
            children: <Widget>[
              AppTopInfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 10.h,
                      children: <Widget>[
                        _DirectoryStatTile(
                          label: 'Residents',
                          value: residents.length.toString(),
                          icon: Icons.groups_2_outlined,
                        ),
                        _DirectoryStatTile(
                          label: 'Assigned',
                          value: assignedResidents.toString(),
                          icon: Icons.home_work_outlined,
                        ),
                        _DirectoryStatTile(
                          label: 'Open beds',
                          value: state.rooms
                              .fold<int>(
                                0,
                                (int total, HostelRoom room) =>
                                    total + room.availableBeds,
                              )
                              .toString(),
                          icon: Icons.bed_outlined,
                        ),
                      ],
                    ),
                    heightSpacer(14),
                    Text(
                      'Assign and move residents directly from the directory.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.78),
                          ),
                    ),
                  ],
                ),
              ),
              heightSpacer(10),
              ...residents.map((AppUser resident) {
                final HostelRoom? room = resident.roomId == null
                    ? null
                    : state.findRoom(resident.roomId!);
                final bool hasRoom = room != null;

                return AppSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CircleAvatar(
                            radius: 24.r,
                            backgroundColor: AppColors.kSoftSurfaceColor,
                            child: Text(
                              '${resident.firstName.characters.first}${resident.lastName.characters.first}'
                                  .toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppColors.kGreenColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                          widthSpacer(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  resident.fullName,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                heightSpacer(4),
                                Text(
                                  room?.label ?? 'Room not assigned',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          StatusChip(
                            label: room?.roomType ?? 'Unassigned',
                            color: hasRoom
                                ? AppColors.kGreenColor
                                : const Color(0xFFB54708),
                          ),
                        ],
                      ),
                      heightSpacer(16),
                      _DetailRow(label: 'Email', value: resident.email),
                      _DetailRow(label: 'Phone', value: resident.phoneNumber),
                      _DetailRow(
                        label: 'Beds',
                        value: room == null
                            ? '--'
                            : '${room.occupiedBeds}/${room.capacity}',
                      ),
                      _DetailRow(
                        label: 'Availability',
                        value: room == null
                            ? 'Select a room to activate resident services.'
                            : '${room.availableBeds} bed(s) open in ${room.label}',
                      ),
                      heightSpacer(8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              hasRoom
                                  ? 'Manual assignment also closes any pending room request for this resident.'
                                  : 'Assign a room to unlock fee tracking and room change requests.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.mutedTextFor(
                                      Theme.of(context).brightness,
                                    ),
                                    height: 1.4,
                                  ),
                            ),
                          ),
                          widthSpacer(12),
                          OutlinedButton.icon(
                            onPressed: state.isLoading
                                ? null
                                : () =>
                                    _showRoomAssignmentSheet(context, resident),
                            icon: Icon(
                              hasRoom
                                  ? Icons.swap_horiz_rounded
                                  : Icons.add_home_work_outlined,
                              size: 18.sp,
                            ),
                            label: Text(
                              hasRoom ? 'Change room' : 'Assign room',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
