import 'package:flutter_bloc/flutter_bloc.dart';

import 'custom_date_timer_picker_screen_state.dart';


class CustomDateTimePickerScreenBloc
    extends Cubit<CustomDateTimePickerScreenState> {
  final DateTime minDateTime;
  final DateTime lastSelectionDatetime;

  CustomDateTimePickerScreenBloc(
      {required this.minDateTime, required this.lastSelectionDatetime})
      : super(CustomDateTimePickerScreenState(
            currentDateTime: lastSelectionDatetime));

  void handleDateSelection(DateTime selectedDate) {
    final previousDateTime = state.currentDateTime;
    final newDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        previousDateTime.hour,
        previousDateTime.minute,
        previousDateTime.second);
    emit(state.copyWith(currentDateTime: newDateTime));
  }

  void handleTimeSelection(DateTime selectedTime) {
    final previousDateTime = state.currentDateTime;
    final newDateTime = DateTime(
        previousDateTime.year,
        previousDateTime.month,
        previousDateTime.day,
        selectedTime.hour,
        selectedTime.minute,
        selectedTime.second);
    emit(state.copyWith(currentDateTime: newDateTime));
  }
}
