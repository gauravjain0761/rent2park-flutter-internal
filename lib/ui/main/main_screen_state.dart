import 'package:equatable/equatable.dart';
import 'package:location/location.dart';


import '../../data/meta_data.dart';
import '../../data/user_type.dart';

class MainScreenState extends Equatable {
  final UserType userType;
  final int pageIndex;
  final int reservations;
  final int messageCount;
  final DataEvent userEvent;
  int? index;

  MainScreenState(
      {required this.userType,
      required this.pageIndex,
      required this.reservations,
      required this.messageCount,
      required this.userEvent,

      this.index});

  MainScreenState.initial()
      : this(
            userType: UserType.none,
            pageIndex: 0,
            reservations: 0,
            messageCount: 0,
            userEvent: Initial(),
  index: 0
  );

  MainScreenState copyWith(
      {UserType? type,
      int? pageIndex,
      int? reservations,
      int? messageCount,
      LocationData? locationData,
      DataEvent? userEvent,
      int? index
      }) {
    return MainScreenState(
        userType: type ?? this.userType,
        pageIndex: pageIndex ?? this.pageIndex,
        reservations: reservations ?? this.reservations,
        messageCount: messageCount ?? this.messageCount,
        userEvent: userEvent ?? this.userEvent,
    index: this.index
    );
  }

  @override
  List<Object?> get props =>
      [userType, pageIndex, reservations, messageCount, userEvent,index];

  @override
  bool get stringify => true;
}
