import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent2park/ui/secure_checkout/secure_checkout_screen_state.dart';

import '../../backend/shared_web-services.dart';
import '../../data/backend_responses.dart';
import '../../data/meta_data.dart';
import '../../helper/shared_pref_helper.dart';
import '../../util/app_strings.dart';


class SecureCheckoutScreenBloc extends Cubit<SecureCheckoutScreenState> {
  final SharedPreferenceHelper _sharedPrefHelper =
      SharedPreferenceHelper.instance;
  final SharedWebService _sharedWebService = SharedWebService.instance;

  SecureCheckoutScreenBloc() : super(SecureCheckoutScreenState.initial());

  void handlePaymentCard(PaymentCard paymentCard) => emit(
      state.copyWith(paymentEvent: Data(data: paymentCard), paymentError: ''));

  void handleSelectedVehicle(Vehicle vehicle) =>
      emit(state.copyWith(vehicleEvent: Data(data: vehicle), vehicleError: ''));

  void updateVehicleError(String error) =>
      emit(state.copyWith(vehicleError: error));

  void updatePaymentError(String error) =>
      emit(state.copyWith(paymentError: error));

  void togglePersonalDetailFlag() => emit(state.copyWith(
      isPersonalDetailEditable: !state.isPersonalDetailEditable));

  void updateTwentyFourCheck(bool value) => emit(state.copyWith(
      isTwentyFourCheckEnable: value, termsConditionCheckError: ''));

  void updateOneHourCheck(bool value) =>
      emit(state.copyWith(isOneHourCheck: value, termsConditionCheckError: ''));

  void updateTermsConditionError(String error) =>
      emit(state.copyWith(termsConditionCheckError: error));

  Future<BaseResponse?> bookASpace(
      DateTime parkingFrom,
      DateTime parkingUntil,
      String parkingSpaceId,
      String billAmount,
      String driverName,
      String driverEmail,
      String driverPhone) async {
    final User? user = await _sharedPrefHelper.user();
    if (user == null)
      return StatusMessageResponse(
          false, AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF);
    final vehicleDataEvent = state.vehicleEvent;
    if (vehicleDataEvent is! Data) return null;
    final Vehicle vehicle = vehicleDataEvent.data as Vehicle;

    final paymentDataEvent = state.paymentEvent;
    if (paymentDataEvent is! Data) return null;
    final paymentCard = paymentDataEvent.data as PaymentCard;

    try {
      return await _sharedWebService.bookASpace(
          parkingSpaceId,
          user.id,
          parkingFrom,
          parkingUntil,
          vehicle.id,
          billAmount,
          driverName,
          driverEmail,
          driverPhone,
          paymentCard.id);
    } catch (_) {
      return null;
    }
  }
}
