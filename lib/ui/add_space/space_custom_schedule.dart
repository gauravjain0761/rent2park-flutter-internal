class SpaceCustomSchedule {
  final String weekDayName;
  final bool is24Hours;
  final bool isAvailable;
  final List<SpaceScheduleSlot> slots;

  SpaceCustomSchedule(
      {required this.weekDayName,
      required this.is24Hours,
      required this.isAvailable,
      required this.slots});

  SpaceCustomSchedule.initial(String dayName)
      : this(
            weekDayName: dayName,
            is24Hours: true,
            isAvailable: true,
            slots: []);

  SpaceCustomSchedule copyWith(
          {bool? is24Hours,
          bool? isAvailable,
          List<SpaceScheduleSlot>? slots}) =>
      SpaceCustomSchedule(
          weekDayName: weekDayName,
          is24Hours: is24Hours ?? this.is24Hours,
          isAvailable: isAvailable ?? this.isAvailable,
          slots: slots ?? this.slots);

  @override
  String toString() {
    return 'SpaceCustomSchedule{weekDayName: $weekDayName, is24Hours: $is24Hours, isAvailable: $isAvailable, slots: $slots}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is SpaceCustomSchedule &&
          runtimeType == other.runtimeType &&
          weekDayName == other.weekDayName &&
          is24Hours == other.is24Hours &&
          isAvailable == other.isAvailable &&
          slots == other.slots;

  @override
  int get hashCode =>
      super.hashCode ^
      weekDayName.hashCode ^
      is24Hours.hashCode ^
      isAvailable.hashCode ^
      slots.hashCode;
}

class SpaceScheduleSlot {
  final DateTime start;
  final DateTime end;
  final String id;

  SpaceScheduleSlot({required this.start, required this.end, required this.id});

  SpaceScheduleSlot.initial(String id)
      : this(start: DateTime.now(), end: DateTime.now(), id: id);

  SpaceScheduleSlot copyWith({DateTime? start, DateTime? end}) =>
      SpaceScheduleSlot(
          start: start ?? this.start, end: end ?? this.end, id: id);

  @override
  String toString() {
    return 'SpaceScheduleSlot{start: $start, end: $end, id: $id}';
  }
}
