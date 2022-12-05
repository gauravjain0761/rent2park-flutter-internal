import 'package:equatable/equatable.dart';

import '../../data/meta_data.dart';


class SecureCheckoutScreenState extends Equatable {
  final String vehicleError;
  final DataEvent vehicleEvent;
  final String paymentError;
  final DataEvent paymentEvent;
  final bool isPersonalDetailEditable;
  final bool isTwentyFourCheckEnable;
  final bool isOneHourCheck;
  final String termsConditionCheckError;

  SecureCheckoutScreenState(
      {required this.vehicleError,
      required this.vehicleEvent,
      required this.isPersonalDetailEditable,
      required this.paymentError,
      required this.paymentEvent,
      required this.isTwentyFourCheckEnable,
      required this.isOneHourCheck,
      required this.termsConditionCheckError});

  SecureCheckoutScreenState.initial()
      : this(
            vehicleError: '',
            vehicleEvent: Initial(),
            isPersonalDetailEditable: false,
            paymentError: '',
            paymentEvent: Initial(),
            isTwentyFourCheckEnable: false,
            isOneHourCheck: false,
            termsConditionCheckError: '');

  SecureCheckoutScreenState copyWith(
          {String? vehicleError,
          DataEvent? vehicleEvent,
          bool? isPersonalDetailEditable,
          DataEvent? paymentEvent,
          String? paymentError,
          bool? isTwentyFourCheckEnable,
          bool? isOneHourCheck,
          String? termsConditionCheckError}) =>
      SecureCheckoutScreenState(
          vehicleError: vehicleError ?? this.vehicleError,
          vehicleEvent: vehicleEvent ?? this.vehicleEvent,
          isPersonalDetailEditable:
              isPersonalDetailEditable ?? this.isPersonalDetailEditable,
          paymentEvent: paymentEvent ?? this.paymentEvent,
          paymentError: paymentError ?? this.paymentError,
          isTwentyFourCheckEnable:
              isTwentyFourCheckEnable ?? this.isTwentyFourCheckEnable,
          isOneHourCheck: isOneHourCheck ?? this.isOneHourCheck,
          termsConditionCheckError:
              termsConditionCheckError ?? this.termsConditionCheckError);

  @override
  List<Object> get props => [
        vehicleError,
        vehicleEvent,
        isPersonalDetailEditable,
        paymentEvent,
        paymentError,
        isTwentyFourCheckEnable,
        isOneHourCheck,
        termsConditionCheckError
      ];
}
