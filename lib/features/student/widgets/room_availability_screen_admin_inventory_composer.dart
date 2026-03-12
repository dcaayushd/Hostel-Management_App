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
                color: Color(0xFF155EEF),
              ),
            ],
          ),
          heightSpacer(14),
          Form(
            key: blockFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Add block',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                heightSpacer(10),
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
          heightSpacer(18),
          Form(
            key: roomFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Add room',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                heightSpacer(10),
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
        ],
      ),
    );
  }
}
