import 'package:flutter_bloc/flutter_bloc.dart';
import '../../backend/shared_web-services.dart';
import '../../data/backend_responses.dart';
import '../../helper/shared_pref_helper.dart';
import '../../util/app_strings.dart';
import 'change_password_state.dart';

class ChangePasswordBloc extends Cubit<ChangePasswordState> {
  final SharedPreferenceHelper _sharedPrefHelper =
      SharedPreferenceHelper.instance;
  final SharedWebService _sharedWebService = SharedWebService.instance;

  ChangePasswordBloc() : super(ChangePasswordState.init());

  void updateOldPasswordError(String oldPassword) {
    emit(state.copyWith(oldPassword: oldPassword));
  }

  void updateNewPasswordError(String newPassword) {
    emit(state.copyWith(newPassword: newPassword));
  }

  Future<BaseResponse?> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = await _sharedPrefHelper.user();
    if (user == null)
      return StatusMessageResponse(
          false, AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF);
    try {
      final baseResponse = await _sharedWebService.changePassword(
        oldPassword: oldPassword, newPassword: newPassword,
        token: user.accessToken!,
        // id: user.id
      );
      return baseResponse;
    } catch (e) {
      return null;
    }
  }
}
