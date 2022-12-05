import 'package:flutter_bloc/flutter_bloc.dart';

import '../../backend/shared_web-services.dart';
import '../../backend/stripe_web_service.dart';
import '../../data/backend_responses.dart';
import '../../data/exception.dart';
import '../../data/meta_data.dart';
import '../../helper/shared_pref_helper.dart';
import '../../util/app_strings.dart';

class CheckoutEarningScreenBloc extends Cubit<DataEvent> {
  final SharedWebService _sharedWebService = SharedWebService.instance;
  final StripeWebService _stripeWebService = StripeWebService.instance();
  final SharedPreferenceHelper _sharedPrefHelper = SharedPreferenceHelper.instance;

  CheckoutEarningScreenBloc() : super(Initial()) {
    getCurrentBalance();
  }

  Future<void> getCurrentBalance() async {
    emit(Loading());
    final user = await _sharedPrefHelper.user();
    if (user == null) {
      emit(Error(exception: Exception('')));
      return;
    }
    try {
      final response = await _sharedWebService.getBalance(user.id);
      emit(Data(data: response));
    } catch (_) {
      emit(Error(exception: NoInternetConnectException()));
    }
  }

  Future<BankAccount?> getBankAccount() async {
    final user = await _sharedPrefHelper.user();
    if (user == null) throw Exception(AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF);
    final connectAccountId = user.connectAccountId;
    if (connectAccountId == null) return null;
    try {
      return await _stripeWebService.getConnectAccount(connectAccountId);
    } catch (_) {
      return null;
    }
  }

  Future<void> withdraw() async {
    final user = await _sharedPrefHelper.user();
    if (user == null) throw NoInternetConnectException();
    await _sharedWebService.hostWithdraw(user.id);
    emit(Data(data: StatusMessageResponse(true, '0.00')));
  }
}
