import 'package:equatable/equatable.dart';

class CustomDateTimePickerScreenState extends Equatable {
  final DateTime currentDateTime;

  CustomDateTimePickerScreenState({required this.currentDateTime});

  CustomDateTimePickerScreenState copyWith({DateTime? currentDateTime}) =>
      CustomDateTimePickerScreenState(
          currentDateTime: currentDateTime ?? this.currentDateTime);

  @override
  List<Object> get props => [currentDateTime];
}
