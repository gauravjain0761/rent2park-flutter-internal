import 'package:equatable/equatable.dart';

import '../../../data/meta_data.dart';


class ReservationNavigationScreenState extends Equatable {
  final int tabIndex;
  final DataEvent inProgressDataEvent;
  final DataEvent upcomingDataEvent;
  final DataEvent pastDataEvent;
  final bool inProgressSwipeRefreshState;
  final bool upcomingSwipeRefreshState;
  final bool pastSwipeRefreshState;

  ReservationNavigationScreenState(
      {required this.tabIndex,
      required this.inProgressDataEvent,
      required this.inProgressSwipeRefreshState,
      required this.upcomingDataEvent,
      required this.upcomingSwipeRefreshState,
      required this.pastDataEvent,
      required this.pastSwipeRefreshState});

  ReservationNavigationScreenState.initial()
      : this(
            tabIndex: 0,
            inProgressDataEvent: Initial(),
            inProgressSwipeRefreshState: false,
            upcomingDataEvent: Initial(),
            upcomingSwipeRefreshState: false,
            pastDataEvent: Initial(),
            pastSwipeRefreshState: false);

  ReservationNavigationScreenState copyWith(
      {int? tabIndex,
      DataEvent? inProgressDataEvent,
      bool? inProgressSwipeRefreshState,
      DataEvent? upcomingDataEvent,
      bool? upcomingSwipeRefreshState,
      DataEvent? pastDataEvent,
      bool? pastSwipeRefreshState}) {
    return ReservationNavigationScreenState(
        tabIndex: tabIndex ?? this.tabIndex,
        inProgressDataEvent: inProgressDataEvent ?? this.inProgressDataEvent,
        inProgressSwipeRefreshState:
            inProgressSwipeRefreshState ?? this.inProgressSwipeRefreshState,
        upcomingDataEvent: upcomingDataEvent ?? this.upcomingDataEvent,
        upcomingSwipeRefreshState:
            upcomingSwipeRefreshState ?? this.upcomingSwipeRefreshState,
        pastDataEvent: pastDataEvent ?? this.pastDataEvent,
        pastSwipeRefreshState:
            pastSwipeRefreshState ?? this.pastSwipeRefreshState);
  }

  @override
  List<Object> get props => [
        tabIndex,
        inProgressDataEvent,
        inProgressSwipeRefreshState,
        upcomingDataEvent,
        upcomingSwipeRefreshState,
        pastDataEvent,
        pastSwipeRefreshState
      ];
}
