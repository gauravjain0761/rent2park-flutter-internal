import 'package:flutter_bloc/flutter_bloc.dart';

import '../../backend/shared_web-services.dart';


class ForgotPasswordBloc extends Cubit<String> {
  final SharedWebService _sharedWebService = SharedWebService.instance;

  ForgotPasswordBloc() : super('');

  void updateError(String error) => emit(error);

  Future<String?> forgotPassword(String email) async {
    try {
      final response = await _sharedWebService.forgotPassword(email);
      if (!response.status) return response.message;
      return '';
    } catch (_) {
      return null;
    }
  }
}
