import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent2park/extension/collection_extension.dart';
import 'package:rent2park/ui/main/reservation/reservation_navigation_screen_state.dart';

import '../../../backend/shared_web-services.dart';
import '../../../data/backend_responses.dart';
import '../../../data/meta_data.dart';
import '../../../helper/shared_pref_helper.dart';
import '../../../util/app_strings.dart';


class ReservationNavigationScreenBloc
    extends Cubit<ReservationNavigationScreenState> {
  final SharedWebService _sharedWebService = SharedWebService.instance;
  final SharedPreferenceHelper _sharedPrefHelper =
      SharedPreferenceHelper.instance;

  Future<User?> get _user async => await _sharedPrefHelper.user();

  ReservationNavigationScreenBloc()
      : super(ReservationNavigationScreenState.initial());

  void updateTabIndex(int index) => emit(state.copyWith(tabIndex: index));

  void requestDriverInProgressBooking(bool isForProgress) async {
    if (isForProgress) emit(state.copyWith(inProgressDataEvent: Loading()));
    final User? user = await _user;
    if (user == null) {
      emit(state.copyWith(
          inProgressDataEvent:
              Empty(message: AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF)));
      return;
    }
    try {
      final response =
          await _sharedWebService.driverInProgressBookings(user.id);
      if (response.spaceBookings.isNotEmpty)
        emit(state.copyWith(
            inProgressDataEvent: Data(data: response.spaceBookings),
            inProgressSwipeRefreshState: !state.inProgressSwipeRefreshState));
      else {
        emit(state.copyWith(
            inProgressDataEvent:
                Empty(message: AppText.NO_IN_PROGRESS_BOOKING_FOUND),
            inProgressSwipeRefreshState: !state.inProgressSwipeRefreshState));
      }
    } catch (e) {
      if (isForProgress)
        emit(state.copyWith(
            inProgressDataEvent: Error(exception: Exception(e.toString()))));
      else
        emit(state.copyWith(
            inProgressSwipeRefreshState: !state.inProgressSwipeRefreshState));
    }
  }

  void requestHostInProgressBooking(bool isForProgress) async {
    if (isForProgress) emit(state.copyWith(inProgressDataEvent: Loading()));
    final User? user = await _user;
    if (user == null) {
      emit(state.copyWith(
          inProgressDataEvent:
              Empty(message: AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF)));
      return;
    }
    try {
      final response = await _sharedWebService.hostInProgressBookings(user.id);
      if (response.spaceBookings.isNotEmpty)
        emit(state.copyWith(
            inProgressDataEvent: Data(data: response.spaceBookings),
            inProgressSwipeRefreshState: !state.inProgressSwipeRefreshState));
      else
        emit(state.copyWith(
            inProgressDataEvent:
                Empty(message: AppText.NO_IN_PROGRESS_BOOKING_FOUND),
            inProgressSwipeRefreshState: !state.inProgressSwipeRefreshState));
    } catch (e) {
      if (isForProgress)
        emit(state.copyWith(
            inProgressDataEvent: Error(exception: Exception(e.toString()))));
      else
        emit(state.copyWith(
            inProgressSwipeRefreshState: !state.inProgressSwipeRefreshState));
    }
  }

  void requestDriverUpcomingBooking(bool isForProgress) async {
    if (isForProgress) emit(state.copyWith(upcomingDataEvent: Loading()));
    final User? user = await _user;
    if (user == null) {
      emit(state.copyWith(
          upcomingDataEvent:
              Empty(message: AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF)));
      return;
    }
    try {
      final response = await _sharedWebService.driverUpcomingBookings(user.id);
      print('Response --> $response');
      if (response.spaceBookings.isNotEmpty)
        emit(state.copyWith(
            upcomingDataEvent: Data(data: response.spaceBookings),
            upcomingSwipeRefreshState: !state.upcomingSwipeRefreshState));
      else
        emit(state.copyWith(
            upcomingDataEvent:
                Empty(message: AppText.NO_UPCOMING_BOOKING_FOUND),
            upcomingSwipeRefreshState: !state.upcomingSwipeRefreshState));
    } catch (e) {
      if (isForProgress)
        emit(state.copyWith(
            upcomingDataEvent: Error(exception: Exception(e.toString()))));
      else
        emit(state.copyWith(
            upcomingSwipeRefreshState: !state.upcomingSwipeRefreshState));
    }
  }

  void requestHostUpcomingBooking(bool isForProgress) async {
    if (isForProgress) emit(state.copyWith(upcomingDataEvent: Loading()));
    final User? user = await _user;
    if (user == null) {
      emit(state.copyWith(
          upcomingDataEvent:
              Empty(message: AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF)));
      return;
    }
    try {
      final response = await _sharedWebService.hostUpcomingBookings(user.id);
      if (response.spaceBookings.isNotEmpty)
        emit(state.copyWith(
            upcomingDataEvent: Data(data: response.spaceBookings),
            upcomingSwipeRefreshState: !state.upcomingSwipeRefreshState));
      else
        emit(state.copyWith(
            upcomingDataEvent:
                Empty(message: AppText.NO_UPCOMING_BOOKING_FOUND),
            upcomingSwipeRefreshState: !state.upcomingSwipeRefreshState));
    } catch (e) {
      if (isForProgress)
        emit(state.copyWith(
            upcomingDataEvent: Error(exception: Exception(e.toString()))));
      else
        emit(state.copyWith(
            upcomingSwipeRefreshState: !state.upcomingSwipeRefreshState));
    }
  }

  void requestDriverPastBooking(bool isForProgress) async {
    if (isForProgress) emit(state.copyWith(pastDataEvent: Loading()));
    final User? user = await _user;
    if (user == null) {
      emit(state.copyWith(
          pastDataEvent:
              Empty(message: AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF)));
      return;
    }
    try {
      final response = await _sharedWebService.driverPastBookings(user.id);
      if (response.spaceBookings.isNotEmpty)
        emit(state.copyWith(
            pastDataEvent: Data(data: response.spaceBookings),
            pastSwipeRefreshState: !state.pastSwipeRefreshState));
      else
        emit(state.copyWith(
            pastDataEvent: Empty(message: AppText.NO_PAST_BOOKING_FOUND),
            pastSwipeRefreshState: !state.pastSwipeRefreshState));
    } catch (e) {
      if (isForProgress)
        emit(state.copyWith(
            pastDataEvent: Error(exception: Exception(e.toString()))));
      else
        emit(state.copyWith(
            pastSwipeRefreshState: !state.pastSwipeRefreshState));
    }
  }

  void requestHostPastBooking(bool isForProgress) async {
    if (isForProgress) emit(state.copyWith(pastDataEvent: Loading()));
    final User? user = await _user;
    if (user == null) {
      emit(state.copyWith(
          pastDataEvent:
              Empty(message: AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF)));
      return;
    }
    try {
      final response = await _sharedWebService.hostPastBookings(user.id);
      if (response.spaceBookings.isNotEmpty)
        emit(state.copyWith(
            pastDataEvent: Data(data: response.spaceBookings),
            pastSwipeRefreshState: !state.pastSwipeRefreshState));
      else
        emit(state.copyWith(
            pastDataEvent: Empty(message: AppText.NO_PAST_BOOKING_FOUND),
            pastSwipeRefreshState: !state.pastSwipeRefreshState));
    } catch (e) {
      if (isForProgress)
        emit(state.copyWith(
            pastDataEvent: Error(exception: Exception(e.toString()))));
      else
        emit(state.copyWith(
            pastSwipeRefreshState: !state.pastSwipeRefreshState));
    }
  }

  void deleteSpaceBooking(int id) {
    final upcomingProgressDataEvent = state.upcomingDataEvent;
    final inProgressDataEvent = state.inProgressDataEvent;
    if (state.tabIndex == 0 && inProgressDataEvent is Data) {
      final inProgressBookings = inProgressDataEvent.data as List<SpaceBooking>;
      final booking =
          inProgressBookings.firstWhereOrNull((element) => element.id == id);
      if (booking == null) return;
      inProgressBookings.remove(booking);
      emit(state.copyWith(inProgressDataEvent: Data(data: inProgressBookings)));
    } else if (state.tabIndex == 1 && upcomingProgressDataEvent is Data) {
      final upcomingBookings =
          upcomingProgressDataEvent.data as List<SpaceBooking>;
      final booking =
          upcomingBookings.firstWhereOrNull((element) => element.id == id);
      if (booking == null) return;
      upcomingBookings.remove(booking);
      emit(state.copyWith(upcomingDataEvent: Data(data: upcomingBookings)));
    }
  }

  void updateDriverVehicleForBooking(Vehicle vehicle, int bookingId) {
    if (state.tabIndex == 1) {
      final upcomingProgressDataEvent = state.upcomingDataEvent;
      if (upcomingProgressDataEvent is Data) {
        final upcomingBookings =
            upcomingProgressDataEvent.data as List<SpaceBooking>;
        final bookingIndex =
            upcomingBookings.indexWhere((element) => element.id == bookingId);
        if (bookingIndex == -1) return;
        final newBooking =
            upcomingBookings[bookingIndex].copyWith(vehicle: vehicle);
        upcomingBookings.removeAt(bookingIndex);
        upcomingBookings.insert(bookingIndex, newBooking);
        emit(state.copyWith(upcomingDataEvent: Data(data: upcomingBookings)));
      }
    }
  }

  void updateLeavingTime(String leavingTime, int id) {
    final Function(List<SpaceBooking>) bookingUpdateClosure = (bookings) {
      final booking = bookings.firstWhereOrNull((element) => element.id == id);
      if (booking == null) return;
      final bookingIndex = bookings.indexOf(booking);
      final updatedBooking = booking.copyWith(leaving: leavingTime);
      bookings.removeAt(bookingIndex);
      bookings.insert(bookingIndex, updatedBooking);
      emit(state.copyWith(inProgressDataEvent: Data(data: bookings)));
    };

    if (state.tabIndex == 0) {
      final inProgressDataEvent = state.inProgressDataEvent;
      if (inProgressDataEvent is Data) {
        final inProgressBookings =
            inProgressDataEvent.data as List<SpaceBooking>;
        bookingUpdateClosure(inProgressBookings);
      }
    } else if (state.tabIndex == 1) {
      final upcomingDataEvent = state.upcomingDataEvent;
      if (upcomingDataEvent is Data) {
        final upcomingBookings = upcomingDataEvent.data as List<SpaceBooking>;
        bookingUpdateClosure(upcomingBookings);
      }
    } else if (state.tabIndex == 2) {
      final pastDataEvent = state.pastDataEvent;
      if (pastDataEvent is Data) {
        final pastBookings = pastDataEvent.data as List<SpaceBooking>;
        bookingUpdateClosure(pastBookings);
      }
    }
  }
}
