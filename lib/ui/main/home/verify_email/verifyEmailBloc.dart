import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../backend/shared_web-services.dart';
import '../../../../data/backend_responses.dart';
import '../../../../helper/shared_pref_helper.dart';

class VerifyEmailScreenBloc extends Cubit<String> {
  final SharedPreferenceHelper _sharedPrefHelper =
      SharedPreferenceHelper.instance;
  final SharedWebService _sharedWebService = SharedWebService.instance;

  VerifyEmailScreenBloc() : super('');

  void updateError(String error) => emit(error);

  Future<bool> sendOTPEmail(String email) async {
    final user = await _sharedPrefHelper.user();
    if (user == null) return false;
    try {
      var response =  await _sharedWebService.sendOTPEmail(
          email: email,
          userId: user.id.toString(),
          accessToken: user.accessToken);
      return response.status;
    } catch (_) {
      return false;
    }
  }
}
