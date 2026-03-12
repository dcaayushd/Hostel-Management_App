part of '../screens/room_availability_screen.dart';

class _AdminInventoryComposer extends StatelessWidget {
  const _AdminInventoryComposer({
    required this.blockFormKey,
    required this.roomFormKey,
    required this.blocks,
    required this.blockCodeController,
    required this.blockNameController,
    required this.roomNumberController,
    required this.roomCapacityController,
    required this.selectedRoomType,
    required this.roomBlockCode,
    required this.onRoomTypeChanged,
    required this.onRoomBlockChanged,
    required this.onCreateBlock,
    required this.onCreateRoom,
  });

  final GlobalKey<FormState> blockFormKey;
  final GlobalKey<FormState> roomFormKey;
  final List<HostelBlock> blocks;
  final TextEditingController blockCodeController;
  final TextEditingController blockNameController;
  final TextEditingController roomNumberController;
  final TextEditingController roomCapacityController;
  final String selectedRoomType;
  final String? roomBlockCode;
  final ValueChanged<String?> onRoomTypeChanged;
  final ValueChanged<String?> onRoomBlockChanged;
  final Future<void> Function() onCreateBlock;
  final Future<void> Function() onCreateRoom;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Inventory controls',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const StatusChip(
                label: 'Admin only',
                color: AppColors.kGreenColor,
              ),
            ],
          ),
          heightSpacer(6),
          Text(
            'Add blocks and publish new rooms without leaving this screen.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedTextFor(brightness),
                ),
          ),
          heightSpacer(14),
          _InventoryFormPanel(
            icon: Icons.apartment_rounded,
            title: 'Add block',
            subtitle:
                'Create the block code and display name used across the app.',
            child: Form(
              key: blockFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CustomTextField(
                    controller: blockCodeController,
                    inputHint: 'Code',
                    validator: (String? value) =>
                        AppValidators.requiredField(value, 'Block code'),
                    inputCapitalization: TextCapitalization.characters,
                  ),
                  CustomTextField(
                    controller: blockNameController,
                    inputHint: 'Name',
                    validator: (String? value) =>
                        AppValidators.requiredField(value, 'Block name'),
                    inputCapitalization: TextCapitalization.words,
                  ),
                  heightSpacer(6),
                  CustomButton(
                    buttonText: 'Add Block',
                    onTap: onCreateBlock,
                  ),
                ],
              ),
            ),
          ),
          heightSpacer(18),
          _InventoryFormPanel(
            icon: Icons.meeting_room_outlined,
            title: 'Add room',
            subtitle: blocks.isEmpty
                ? 'Create a block first, then attach new rooms to it.'
                : 'Assign the room to a block, set capacity, and publish it instantly.',
            child: Form(
              key: roomFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AppDropdownField<String>(
                    initialValue: roomBlockCode,
                    items: blocks
                        .map(
                          (HostelBlock block) => DropdownMenuItem<String>(
                            value: block.code,
                            child: Text(block.label),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: onRoomBlockChanged,
                    hintText: 'Select a block',
                    validator: (String? value) =>
                        AppValidators.requiredField(value, 'Block'),
                  ),
                  heightSpacer(10),
                  CustomTextField(
                    controller: roomNumberController,
                    inputHint: 'Room number',
                    validator: (String? value) =>
                        AppValidators.requiredField(value, 'Room number'),
                    inputCapitalization: TextCapitalization.characters,
                  ),
                  CustomTextField(
                    controller: roomCapacityController,
                    inputHint: 'Capacity',
                    inputKeyBoardType: TextInputType.number,
                    validator: (String? value) =>
                        AppValidators.requiredField(value, 'Capacity'),
                  ),
                  AppDropdownField<String>(
                    initialValue: selectedRoomType,
                    items: _roomTypes
                        .map(
                          (String roomType) => DropdownMenuItem<String>(
                            value: roomType,
                            child: Text(roomType),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: onRoomTypeChanged,
                    hintText: 'Choose room type',
                  ),
                  heightSpacer(6),
                  CustomButton(
                    buttonText: 'Add Room',
                    onTap: blocks.isEmpty ? null : onCreateRoom,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryFormPanel extends StatelessWidget {
  const _InventoryFormPanel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.tonalSurfaceFor(brightness),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.outlineFor(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 42.h,
                width: 42.w,
                decoration: BoxDecoration(
                  color: AppColors.iconSurfaceFor(
                    brightness,
                    lightColor: AppColors.kGreenColor,
                    lightAlpha: 0.12,
                    darkAlpha: 0.14,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  icon,
                  color: AppColors.iconColorFor(brightness),
                ),
              ),
              widthSpacer(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    heightSpacer(4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.mutedTextFor(brightness),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          heightSpacer(14),
          child,
        ],
      ),
    );
  }
}
