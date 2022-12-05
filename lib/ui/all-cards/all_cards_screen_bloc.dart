import 'package:flutter_bloc/flutter_bloc.dart';

import '../../backend/stripe_web_service.dart';
import '../../data/meta_data.dart';
import '../../helper/shared_pref_helper.dart';
import '../../util/app_strings.dart';


class AllCardsScreenBloc extends Cubit<DataEvent> {
  final StripeWebService _stripeWebService = StripeWebService.instance();
  final SharedPreferenceHelper _sharedPrefHelper =
      SharedPreferenceHelper.instance;

  final bool isForSelection;

  AllCardsScreenBloc({required this.isForSelection}) : super(Initial()) {
    getBankAccount();
    myCards();
  }

  Future<void> myCards() async {
    emit(Loading());

    final user = await _sharedPrefHelper.user();
    if (user == null) {

      emit(Error(exception: Exception(AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF)));

      return;
    }
    var customerId = user.customerId.toString();
    if (customerId.isEmpty||customerId.length<2) {
      emit(Data(data: <dynamic>['AddNewCard']));
      return;
    }

    try {
      final paymentMethods = await _stripeWebService.retrieveCards(customerId);
      final updatedPaymentMethods = paymentMethods.map((e) => e as dynamic).toList();
      updatedPaymentMethods.add('AddNewCard');
      emit(Data(data: updatedPaymentMethods));
    } catch (_) {
      emit(Error(exception: Exception(_)));
    }
  }

  Future<void> getBankAccount() async {
    emit(Loading());
    final user = await _sharedPrefHelper.user();
    if (user == null) {
      emit(Error(
          exception: Exception(AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF)));
      return;
    }
    final customerId = user.customerId;
    try {
      final bankAccount = await _stripeWebService.getBankAccount(customerId!);
      emit(Data(data: bankAccount));
    } catch (_) {
      emit(Error(exception: Exception('')));
    }
  }

}
