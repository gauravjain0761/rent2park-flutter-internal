import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../backend/shared_web-services.dart';
import '../../../../data/backend_responses.dart';
import '../../../../data/meta_data.dart';
import '../../../../helper/shared_pref_helper.dart';
import '../../profile/profile_state.dart';

class VerifyOtpScreenBloc extends Cubit<String> {
  final SharedPreferenceHelper _sharedPrefHelper = SharedPreferenceHelper.instance;
  final SharedWebService _sharedWebService = SharedWebService.instance;

  VerifyOtpScreenBloc() : super('');

  void updateError(String error) => emit(error);

  /* Future<BaseResponse?> verifyPhoneNumber(String phoneNumber) async {
    final user = await _sharedPrefHelper.user();
    if (user == null) return null;
    try {
      return await _sharedWebService.verifyPhoneNumber(user.id, phoneNumber);
    } catch (_) {
      return null;
    }
  }*/
  Future<AuthenticationResponse?> verifyPhoneNumber(String otp) async {
    final user = await _sharedPrefHelper.user();
    if (user == null) return null;
    try {
      final authResponse =  await _sharedWebService.verifyOTPMobile(user.id.toString(), user.accessToken, otp);

      if (authResponse.status && authResponse.user != null) {
        await  _sharedPrefHelper.insertUser(authResponse.user!);
      }

      return authResponse;
    } catch (_) {
      return null;
    }
  }

  Future<AuthenticationResponse?> verifyEmail(String otp) async {
    final user = await _sharedPrefHelper.user();
    if (user == null) return null;
    try {
      final authResponse =  await _sharedWebService.verifyEmailOTP(userId: user.id.toString(), accessToken: user.accessToken, otp: otp);
      if (authResponse.status && authResponse.user != null) {
        await _sharedPrefHelper.insertUser(authResponse.user!);
      }

      return authResponse;
    } catch (_) {
      return null;
    }
  }
}
