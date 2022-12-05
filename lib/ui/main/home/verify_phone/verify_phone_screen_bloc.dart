import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:twilio_flutter/twilio_flutter.dart';

import '../../../../backend/shared_web-services.dart';
import '../../../../helper/shared_pref_helper.dart';
import '../../../../util/app_strings.dart';
import '../../../../util/constants.dart';

class VerifyPhoneScreenBloc extends Cubit<String> {
  final SharedPreferenceHelper _sharedPrefHelper = SharedPreferenceHelper.instance;

  final SharedWebService _sharedWebService = SharedWebService.instance;

  
  final TwilioFlutter twilio = TwilioFlutter(
      accountSid: Constants.TWILIO_ACCOUNT_SID,
      authToken: Constants.TWILIO_ACCOUNT_AUTH_TOKEN,
      twilioNumber: Constants.TWILIO_ACCOUNT_NUMBER);
  final random = Random();

  String get otpCode => List.generate(4, (_) => random.nextInt(10)).join();

  VerifyPhoneScreenBloc() : super('');

  void updateError(String error) => emit(error);

  /*Future<String?> sendOtpCode(String phoneNumber) async {
    final String otpCode = this.otpCode;
    try {
      final statusCode = await twilio.sendSMS(toNumber: phoneNumber, messageBody: otpCode);
      if (statusCode == 201) return otpCode;
      return AppText.ERROR_OCCURRED_WHILE_SENDING_CODE;
    } catch (_) {
      return null;
    }
  }*/
  Future<bool> sendOtpCode(String phoneNumber) async {
    final user = await _sharedPrefHelper.user();

    // final String otpCode = this.otpCode;
    try {
      final response = await _sharedWebService.sendOTPMobile(phoneNumber,user?.id.toString(),user?.accessToken);
      return response.status;
    } catch (_) {
      return false;
    }
  }
}
