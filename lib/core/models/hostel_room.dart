class HostelRoom {
  const HostelRoom({
    required this.id,
    required this.block,
    required this.number,
    required this.capacity,
    required this.roomType,
    required this.residentIds,
  });

  final String id;
  final String block;
  final String number;
  final int capacity;
  final String roomType;
  final List<String> residentIds;

  String get label => '$block-$number';

  int get occupiedBeds => residentIds.length;

  int get availableBeds => capacity - occupiedBeds;

  bool get hasAvailability => availableBeds > 0;

  HostelRoom copyWith({
    String? id,
    String? block,
    String? number,
    int? capacity,
    String? roomType,
    List<String>? residentIds,
  }) {
    return HostelRoom(
      id: id ?? this.id,
      block: block ?? this.block,
      number: number ?? this.number,
      capacity: capacity ?? this.capacity,
      roomType: roomType ?? this.roomType,
      residentIds: residentIds ?? this.residentIds,
    );
  }
}
